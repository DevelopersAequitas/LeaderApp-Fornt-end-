import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/error_formatter.dart';
import '../../../data/repositories/activities_repository.dart';
import '../../../data/repositories/peers_repository.dart';
import '../../peers/model/peer_model.dart';
import '../model/leader_activity_item_model.dart';
import '../presenter/leader_activities_presenter.dart';
import 'leader_activities_event.dart';
import 'leader_activities_state.dart';

class LeaderActivitiesBloc
    extends Bloc<LeaderActivitiesEvent, LeaderActivitiesState> {
  final ActivitiesRepository _activitiesRepository;
  final PeersRepository _peersRepository;
  final LeaderActivitiesPresenter _presenter;

  LeaderActivitiesBloc({
    ActivitiesRepository? activitiesRepository,
    PeersRepository? peersRepository,
    LeaderActivitiesPresenter? presenter,
  })  : _activitiesRepository =
            activitiesRepository ?? ActivitiesRepositoryImpl(),
        _peersRepository = peersRepository ?? PeersRepositoryImpl(),
        _presenter = presenter ?? const LeaderActivitiesPresenter(),
        super(const LeaderActivitiesState()) {
    on<LoadLeaderActivities>(_onLoadLeaderActivities);
    on<LoadMoreLeaderActivities>(_onLoadMoreLeaderActivities);
    on<SearchLeaderActivities>(_onSearchLeaderActivities);
    on<SwitchLeaderActivitiesTab>(_onSwitchLeaderActivitiesTab);
    on<ApproveLeaderActivityItem>(_onApproveLeaderActivityItem);
    on<RejectLeaderActivityItem>(_onRejectLeaderActivityItem);
  }

  Future<void> _onLoadLeaderActivities(
    LoadLeaderActivities event,
    Emitter<LeaderActivitiesState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      type: event.type,
      circleId: event.circleId,
      errorMessage: '',
    ));

    try {
      List<LeaderRankedPeerModel> rankedPeers = [];
      List<LeaderActivityItemModel> activityItems = [];
      LeaderActivitiesPayload? payload;

      // 1. Primary call to unified endpoint `/leader/activities/{type}`
      try {
        final response =
            await _activitiesRepository.getActivitiesPayloadByType(
          type: event.type,
          circleId: event.circleId,
          search: event.search,
          page: 1,
          limit: 25,
        );
        if (response.success && response.data != null) {
          payload = response.data;
          rankedPeers = payload!.peers;
          activityItems = payload.items;
        }
      } catch (_) {
        // Fallback handled below if the server hasn't deployed the unified route yet
      }

      final config = LeaderActivityCategoryConfig.fromType(event.type);

      // 2. Filter pre-ranked backend peers to only activity-specific peers first
      if (rankedPeers.isNotEmpty) {
        rankedPeers = _presenter.filterActivitySpecificPeers(
          type: config.type,
          peers: rankedPeers,
        );
      }

      // 3. If activityItems is empty, fetch from dedicated section endpoints
      if (activityItems.isEmpty) {
        activityItems = await _loadLegacyActivityItemsFallback(
          config.type,
          event.circleId,
        );
        // Ensure rankedPeers matches the fallback activityItems rather than stale server peers
        if (activityItems.isNotEmpty &&
            config.type != 'peers' &&
            config.type != 'impacts' &&
            config.type != 'coins' &&
            config.type != 'top-contributors') {
          rankedPeers = [];
        }
      }

      // 4. Build activity-specific ranked peers list if empty
      if (rankedPeers.isEmpty) {
        List<PeerModel> basePeers = [];
        try {
          final peersRes = await _peersRepository.getPeers(
            circleId: event.circleId,
            perPage: 200,
          );
          if (peersRes.success && peersRes.data != null) {
            basePeers = peersRes.data!;
          }
        } catch (_) {}

        if ((config.type == 'coins' || config.type == 'top-contributors') &&
            basePeers.every((p) => p.coins <= 0)) {
          try {
            final coinsRes = await _activitiesRepository.getPeersByCoins(
              circleId: event.circleId,
            );
            if (coinsRes.success &&
                coinsRes.data != null &&
                coinsRes.data!.isNotEmpty) {
              basePeers =
                  coinsRes.data!.map((c) => c.toPeerModel()).toList();
            }
          } catch (_) {}
        }

        rankedPeers = _presenter.buildRankedPeersFallback(
          type: config.type,
          basePeers: basePeers,
          activityItems: activityItems,
        );
      }

      // 5. If rankedPeers is populated but activityItems is still empty, synthesize records from rankedPeers
      if (activityItems.isEmpty && rankedPeers.isNotEmpty) {
        activityItems = rankedPeers
            .map(
              (rp) => LeaderActivityItemModel(
                id: rp.peer.id,
                type: config.type,
                title: rp.peer.name,
                subtitle: rp.peer.company.isNotEmpty
                    ? rp.peer.company
                    : config.title,
                description: '${rp.metricDisplay} ${rp.metricLabel}',
                status: rp.peer.status.isNotEmpty ? rp.peer.status : 'Active',
                date: '',
                amount: rp.metricDisplay,
                peerId: rp.peer.id,
                peerName: rp.peer.name,
                avatarUrl: rp.peer.avatarUrl,
                city: rp.peer.location,
                designation: rp.peer.designation ?? 'Member',
                company: rp.peer.company,
                category: rp.peer.level4Category ?? rp.peer.tags,
                circleName: rp.peer.circle,
                isVerified: rp.peer.isVerified,
              ),
            )
            .toList();
      }

      // 6. Enrich activity items with resolved peerId/avatar/company from rankedPeers so tapping any record opens Peer Details
      if (activityItems.isNotEmpty && rankedPeers.isNotEmpty) {
        final peerByName = <String, PeerModel>{};
        for (final rp in rankedPeers) {
          final nKey = rp.peer.name.trim().toLowerCase();
          if (nKey.isNotEmpty) {
            peerByName[nKey] = rp.peer;
          }
        }
        activityItems = activityItems.map((item) {
          if (item.peerId.trim().isNotEmpty) return item;
          final matched = peerByName[item.peerName.trim().toLowerCase()];
          if (matched == null || matched.id.trim().isEmpty) return item;
          return item.copyWith(
            peerId: matched.id,
            avatarUrl: item.avatarUrl ?? matched.avatarUrl,
            city: item.city.isNotEmpty ? item.city : matched.location,
            designation: item.designation.isNotEmpty
                ? item.designation
                : (matched.designation ?? 'Member'),
            company: item.company.isNotEmpty ? item.company : matched.company,
            category: item.category.isNotEmpty
                ? item.category
                : (matched.level4Category ?? matched.tags),
            circleName:
                item.circleName.isNotEmpty ? item.circleName : matched.circle,
            isVerified: item.isVerified || matched.isVerified,
          );
        }).toList();
      }

      final filteredPeers =
          _presenter.filterPeers(rankedPeers, state.searchQuery);
      final filteredItems =
          _presenter.filterItems(activityItems, state.searchQuery);

      final totalActivities = payload?.totalActivities ??
          (activityItems.isNotEmpty
              ? activityItems.length
              : rankedPeers.fold<int>(0, (sum, p) => sum + p.metricCount));
      final totalPeers = payload?.totalPeers ?? rankedPeers.length;
      final total = payload?.total ?? activityItems.length;
      final unitLabel = payload?.unitLabel ?? config.unitLabel;
      final hasMore = payload?.hasMore ?? false;
      final page = payload?.page ?? 1;

      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        allPeers: rankedPeers,
        filteredPeers: filteredPeers,
        allItems: activityItems,
        filteredItems: filteredItems,
        totalActivities: totalActivities,
        totalPeers: totalPeers,
        total: total,
        unitLabel: unitLabel,
        hasMore: hasMore,
        page: page,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: ErrorFormatter.format(e),
      ));
    }
  }

  Future<void> _onLoadMoreLeaderActivities(
    LoadMoreLeaderActivities event,
    Emitter<LeaderActivitiesState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.page + 1;
      final response = await _activitiesRepository.getActivitiesPayloadByType(
        type: state.type,
        circleId: state.circleId,
        search: state.searchQuery,
        page: nextPage,
        limit: 25,
      );

      if (response.success && response.data != null) {
        final newPayload = response.data!;
        final newItems = newPayload.items;

        final combinedItems =
            List<LeaderActivityItemModel>.from(state.allItems)..addAll(newItems);

        final filteredItems = _presenter.filterItems(
          combinedItems,
          state.searchQuery,
        );

        emit(state.copyWith(
          isLoadingMore: false,
          allItems: combinedItems,
          filteredItems: filteredItems,
          page: newPayload.page > 0 ? newPayload.page : nextPage,
          hasMore: newPayload.hasMore,
          total: newPayload.total > 0 ? newPayload.total : state.total,
          totalActivities: newPayload.totalActivities > 0
              ? newPayload.totalActivities
              : state.totalActivities,
          totalPeers: newPayload.totalPeers > 0
              ? newPayload.totalPeers
              : state.totalPeers,
        ));
      } else {
        emit(state.copyWith(isLoadingMore: false, hasMore: false));
      }
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<List<LeaderActivityItemModel>> _loadLegacyActivityItemsFallback(
    String normalizedType,
    String? circleId,
  ) async {
    try {
      switch (normalizedType) {
        case 'peers':
          final res = await _peersRepository.getPeers(
            circleId: circleId,
            perPage: 200,
          );
          if (res.success && res.data != null) {
            return res.data!
                .map(
                  (p) => LeaderActivityItemModel(
                    id: p.id,
                    type: 'peers',
                    title: p.name,
                    subtitle: p.company,
                    description: p.tags,
                    status: p.status.isNotEmpty ? p.status : 'Active',
                    date: '',
                    amount: '${p.impactCount} Impact',
                    peerId: p.id,
                    peerName: p.name,
                    avatarUrl: p.avatarUrl,
                    city: p.location,
                    designation: p.designation ?? 'Member',
                    company: p.company,
                    category: p.level4Category ?? p.tags,
                    circleName: p.circle,
                    isVerified: p.isVerified,
                  ),
                )
                .toList();
          }
          break;
        case 'impacts':
          final res =
              await _activitiesRepository.getImpacts(circleId: circleId);
          if (res.success && res.data != null) {
            return res.data!
                .map(
                  (m) => LeaderActivityItemModel(
                    id: m.id,
                    type: 'impacts',
                    title: m.title,
                    subtitle: m.impactType,
                    description: m.description,
                    status: 'Approved',
                    date: m.createdAt.length > 10
                        ? m.createdAt.substring(0, 10)
                        : m.createdAt,
                    badgeLabel: m.impactType,
                    peerId: m.peerUserId,
                    peerName: m.peerName,
                    avatarUrl:
                        m.profileImage.isNotEmpty ? m.profileImage : null,
                    city: m.city,
                    designation: 'Member',
                    company: m.businessName,
                    category: m.categoryLevel4,
                    circleName: '',
                  ),
                )
                .toList();
          }
          break;
        case 'business-deals':
          final res =
              await _activitiesRepository.getBusinessDeals(circleId: circleId);
          if (res.success && res.data != null) {
            return res.data!
                .map(
                  (m) => LeaderActivityItemModel(
                    id: m.id,
                    type: 'business-deals',
                    title: 'Business Deal Closed',
                    subtitle: m.dealType,
                    description: m.notes,
                    status: 'Closed',
                    date: '',
                    amount: m.amountFormatted,
                    peerId: m.peerUserId,
                    peerName: m.peerName,
                    avatarUrl:
                        m.profileImage.isNotEmpty ? m.profileImage : null,
                    city: m.city,
                    designation: 'Member',
                    company: m.businessName,
                    category: m.categoryLevel4,
                    circleName: '',
                  ),
                )
                .toList();
          }
          break;
        case 'p2p-meetings':
          final res =
              await _activitiesRepository.getP2PMeetings(circleId: circleId);
          if (res.success && res.data != null) {
            return res.data!
                .map(
                  (m) => LeaderActivityItemModel(
                    id: m.id,
                    type: 'p2p-meetings',
                    title: m.location.isNotEmpty
                        ? 'P2P Meeting at ${m.location}'
                        : '1-on-1 P2P Meeting',
                    subtitle: m.mode.toUpperCase(),
                    description: m.notes,
                    status: m.status,
                    date: m.scheduledAt.length > 10
                        ? m.scheduledAt.substring(0, 10)
                        : m.scheduledAt,
                    peerId: m.peerUserId,
                    peerName: m.peerName,
                    avatarUrl:
                        m.profileImage.isNotEmpty ? m.profileImage : null,
                    city: m.city,
                    designation: 'Member',
                    company: m.businessName,
                    category: m.categoryLevel4,
                    circleName: '',
                  ),
                )
                .toList();
          }
          break;
        case 'referrals':
        case 'highest-givers':
          final res =
              await _activitiesRepository.getReferrals(circleId: circleId);
          if (res.success && res.data != null) {
            return res.data!
                .map(
                  (m) => LeaderActivityItemModel(
                    id: m.id,
                    type: normalizedType,
                    title: normalizedType == 'highest-givers'
                        ? 'Top Referral Contributor'
                        : 'Business Referral Shared',
                    subtitle: m.dealsCount,
                    description: 'Source: ${m.source}',
                    status: m.status,
                    date: m.createdAt.length > 10
                        ? m.createdAt.substring(0, 10)
                        : m.createdAt,
                    amount: '${m.referralCount} Refs',
                    peerId: m.peerUserId.isNotEmpty ? m.peerUserId : m.id,
                    peerName: m.name,
                    avatarUrl:
                        m.profileImage.isNotEmpty ? m.profileImage : null,
                    city: m.city,
                    designation: 'Member',
                    company: m.company,
                    category: m.categoryLevel4.isNotEmpty
                        ? m.categoryLevel4
                        : m.category,
                    circleName: '',
                  ),
                )
                .toList();
          }
          break;
        case 'coins':
        case 'top-contributors':
          final res =
              await _activitiesRepository.getPeersByCoins(circleId: circleId);
          if (res.success && res.data != null) {
            return res.data!
                .map(
                  (m) => LeaderActivityItemModel(
                    id: m.id,
                    type: normalizedType,
                    title: m.name,
                    subtitle: m.company,
                    description:
                        '${m.coins} Coins • ${m.referralsCount} Referrals • ${m.p2pCount} P2P',
                    status: m.status,
                    date: '',
                    amount: normalizedType == 'top-contributors'
                        ? '${m.lifeImpactedCount > 0 ? m.lifeImpactedCount : m.coins} Pts'
                        : '${m.coins} Coins',
                    peerId: m.peerUserId.isNotEmpty ? m.peerUserId : m.id,
                    peerName: m.name,
                    avatarUrl:
                        m.profileImage.isNotEmpty ? m.profileImage : null,
                    city: m.city,
                    designation: 'Member',
                    company: m.company,
                    category: m.categoryLevel4.isNotEmpty
                        ? m.categoryLevel4
                        : m.category,
                    circleName: m.circle,
                  ),
                )
                .toList();
          }
          break;
        case 'testimonials':
          final res =
              await _activitiesRepository.getTestimonials(circleId: circleId);
          if (res.success && res.data != null) {
            return res.data!
                .map(
                  (m) => LeaderActivityItemModel(
                    id: m.id,
                    type: 'testimonials',
                    title: 'Endorsement for ${m.targetPeerName}',
                    subtitle: m.circleName,
                    description: m.content,
                    status: 'Published',
                    date: m.date,
                    peerId: m.authorId.isNotEmpty ? m.authorId : m.targetPeerId,
                    peerName: m.authorName,
                    avatarUrl:
                        m.profileImage.isNotEmpty ? m.profileImage : null,
                    city: m.city,
                    designation: m.authorRole,
                    company: m.circleName,
                    category: m.categoryLevel4.isNotEmpty
                        ? m.categoryLevel4
                        : 'Business Services',
                    circleName: m.circleName,
                    targetPeerName: m.targetPeerName,
                  ),
                )
                .toList();
          }
          break;
        case 'requirements':
          try {
            final res = await _activitiesRepository.getRequirements(
              circleId: circleId,
            );
            if (res.success && res.data != null && res.data!.isNotEmpty) {
              return res.data!
                  .map(
                    (m) => LeaderActivityItemModel(
                      id: m.id,
                      type: 'requirements',
                      title: m.title,
                      subtitle: 'Peer Requirement',
                      description: m.description,
                      status: m.status,
                      date: '',
                      peerId: m.peerUserId,
                      peerName: m.peerName,
                      avatarUrl:
                          m.profileImage.isNotEmpty ? m.profileImage : null,
                      city: m.city,
                      designation: 'Member',
                      company: m.businessName,
                      category: m.categoryLevel4,
                      circleName: '',
                    ),
                  )
                  .toList();
            }
          } catch (_) {}
          final combinedAsks = <LeaderActivityItemModel>[];
          for (final askType in const [
            'collaboration-asks',
            'referral-asks',
            'help-asks',
          ]) {
            try {
              final flowItems =
                  await _activitiesRepository.getExtendedActivitiesFallback(
                normalizedType: askType,
                circleId: circleId,
              );
              combinedAsks.addAll(flowItems);
            } catch (_) {}
          }
          return combinedAsks;
        case 'peer-recommendations':
          final extRecs =
              await _activitiesRepository.getExtendedActivitiesFallback(
            normalizedType: normalizedType,
            circleId: circleId,
          );
          if (extRecs.isNotEmpty) return extRecs;
          // Fallback to referrals if circle_peer_referrals is empty
          final refRes =
              await _activitiesRepository.getReferrals(circleId: circleId);
          if (refRes.success && refRes.data != null) {
            return refRes.data!
                .map(
                  (m) => LeaderActivityItemModel(
                    id: m.id,
                    type: 'peer-recommendations',
                    title: 'Peer Recommendation',
                    subtitle: m.company,
                    description: 'Recommended via ${m.source}',
                    status: m.status,
                    date: m.createdAt.length > 10
                        ? m.createdAt.substring(0, 10)
                        : m.createdAt,
                    amount: '${m.referralCount} Recs',
                    peerId: m.peerUserId.isNotEmpty ? m.peerUserId : m.id,
                    peerName: m.name,
                    avatarUrl:
                        m.profileImage.isNotEmpty ? m.profileImage : null,
                    city: m.city,
                    designation: 'Member',
                    company: m.company,
                    category: m.categoryLevel4.isNotEmpty
                        ? m.categoryLevel4
                        : m.category,
                    circleName: '',
                  ),
                )
                .toList();
          }
          break;
        case 'introduced-peers':
          final extIntros =
              await _activitiesRepository.getExtendedActivitiesFallback(
            normalizedType: normalizedType,
            circleId: circleId,
          );
          if (extIntros.isNotEmpty) return extIntros;
          // Fallback to active peers introduced into the circle
          final peersRes = await _peersRepository.getPeers(
            circleId: circleId,
            perPage: 100,
          );
          if (peersRes.success && peersRes.data != null) {
            return peersRes.data!
                .map(
                  (p) => LeaderActivityItemModel(
                    id: p.id,
                    type: 'introduced-peers',
                    title: 'Introduced Peer: ${p.name}',
                    subtitle: p.company,
                    description: p.circle.isNotEmpty
                        ? 'Circle: ${p.circle}'
                        : 'Introduced to Peers Global Unity',
                    status: p.status.isNotEmpty ? p.status : 'Active',
                    date: '',
                    peerId: p.id,
                    peerName: p.name,
                    avatarUrl: p.avatarUrl,
                    city: p.location,
                    designation: p.designation ?? 'Member',
                    company: p.company,
                    category: p.level4Category ?? p.tags,
                    circleName: p.circle,
                    isVerified: p.isVerified,
                  ),
                )
                .toList();
          }
          break;
        case 'collaboration-asks':
        case 'referral-asks':
        case 'help-asks':
        case 'posts':
        case 'creatives':
        case 'coin-claims':
        case 'stories':
        case 'visitor-registrations':
        case 'pending-requests':
        case 'certifications':
        case 'entrepreneur-certifications':
        case 'leadership-certifications':
        case 'circulars':
        case 'event-registrations':
        case 'event-attendance':
        case 'leadership-interests':
        case 'mentor-applications':
        case 'speaker-applications':
        case 'partner-inquiries':
        default:
          return await _activitiesRepository.getExtendedActivitiesFallback(
            normalizedType: normalizedType,
            circleId: circleId,
          );
      }
    } catch (_) {}
    return [];
  }

  void _onSearchLeaderActivities(
    SearchLeaderActivities event,
    Emitter<LeaderActivitiesState> emit,
  ) {
    final query = event.query.trim();
    final filteredPeers = _presenter.filterPeers(state.allPeers, query);
    final filteredItems = _presenter.filterItems(state.allItems, query);
    emit(state.copyWith(
      searchQuery: query,
      filteredPeers: filteredPeers,
      filteredItems: filteredItems,
    ));
  }

  void _onSwitchLeaderActivitiesTab(
    SwitchLeaderActivitiesTab event,
    Emitter<LeaderActivitiesState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tabIndex));
  }

  String? _resolvePendingCategoryForItem(LeaderActivityItemModel item) {
    final explicit = item.requestCategory?.trim();
    if (explicit != null && explicit.isNotEmpty) {
      return explicit;
    }
    switch (item.type) {
      case 'coin-claims':
        return 'coin_claims';
      case 'visitor-registrations':
        return 'visitor_registrations';
      case 'event-registrations':
        return 'event_joining_requests';
      case 'certifications':
      case 'entrepreneur-certifications':
      case 'leadership-certifications':
        return 'certifications';
      case 'peer-recommendations':
        return 'circle_peer_referrals';
      case 'introduced-peers':
        return 'introduction_requests';
      case 'impacts':
        return 'pending_impacts';
      default:
        return null;
    }
  }

  Future<void> _onApproveLeaderActivityItem(
    ApproveLeaderActivityItem event,
    Emitter<LeaderActivitiesState> emit,
  ) async {
    final item = event.item;
    if (item.id.trim().isEmpty || state.processingItemIds.contains(item.id)) {
      return;
    }

    final nextProcessing = Set<String>.from(state.processingItemIds)
      ..add(item.id);
    emit(state.copyWith(
      processingItemIds: nextProcessing,
      actionMessage: '',
      errorMessage: '',
    ));

    try {
      final category = _resolvePendingCategoryForItem(item);
      final res = await _activitiesRepository.approvePendingRequest(
        id: item.id,
        category: category,
      );

      final doneProcessing = Set<String>.from(state.processingItemIds)
        ..remove(item.id);

      if (res.success) {
        final isPendingQueue =
            LeaderActivityCategoryConfig.fromType(state.type).type ==
                'pending-requests';
        final updatedAll = isPendingQueue
            ? state.allItems.where((e) => e.id != item.id).toList()
            : state.allItems
                .map((e) =>
                    e.id == item.id ? e.copyWith(status: 'Approved') : e)
                .toList();
        final updatedFiltered =
            _presenter.filterItems(updatedAll, state.searchQuery);

        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          allItems: updatedAll,
          filteredItems: updatedFiltered,
          processingItemIds: doneProcessing,
          actionMessage:
              msg.isNotEmpty ? msg : 'Request approved successfully',
        ));
      } else {
        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          processingItemIds: doneProcessing,
          errorMessage: msg.isNotEmpty ? msg : 'Unable to approve request',
        ));
      }
    } catch (e) {
      final doneProcessing = Set<String>.from(state.processingItemIds)
        ..remove(item.id);
      emit(state.copyWith(
        processingItemIds: doneProcessing,
        errorMessage: ErrorFormatter.format(e),
      ));
    }
  }

  Future<void> _onRejectLeaderActivityItem(
    RejectLeaderActivityItem event,
    Emitter<LeaderActivitiesState> emit,
  ) async {
    final item = event.item;
    if (item.id.trim().isEmpty || state.processingItemIds.contains(item.id)) {
      return;
    }

    final nextProcessing = Set<String>.from(state.processingItemIds)
      ..add(item.id);
    emit(state.copyWith(
      processingItemIds: nextProcessing,
      actionMessage: '',
      errorMessage: '',
    ));

    try {
      final category = _resolvePendingCategoryForItem(item);
      final res = await _activitiesRepository.rejectPendingRequest(
        id: item.id,
        category: category,
        reason: event.reason,
      );

      final doneProcessing = Set<String>.from(state.processingItemIds)
        ..remove(item.id);

      if (res.success) {
        final isPendingQueue =
            LeaderActivityCategoryConfig.fromType(state.type).type ==
                'pending-requests';
        final updatedAll = isPendingQueue
            ? state.allItems.where((e) => e.id != item.id).toList()
            : state.allItems
                .map((e) =>
                    e.id == item.id ? e.copyWith(status: 'Rejected') : e)
                .toList();
        final updatedFiltered =
            _presenter.filterItems(updatedAll, state.searchQuery);

        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          allItems: updatedAll,
          filteredItems: updatedFiltered,
          processingItemIds: doneProcessing,
          actionMessage: msg.isNotEmpty ? msg : 'Request rejected',
        ));
      } else {
        final msg = (res.message ?? '').trim();
        emit(state.copyWith(
          processingItemIds: doneProcessing,
          errorMessage: msg.isNotEmpty ? msg : 'Unable to reject request',
        ));
      }
    } catch (e) {
      final doneProcessing = Set<String>.from(state.processingItemIds)
        ..remove(item.id);
      emit(state.copyWith(
        processingItemIds: doneProcessing,
        errorMessage: ErrorFormatter.format(e),
      ));
    }
  }
}
