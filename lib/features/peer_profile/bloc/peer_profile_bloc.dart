import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/peers_repository.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';
import '../presenter/peer_profile_presenter.dart';
import 'peer_profile_event.dart';
import 'peer_profile_state.dart';

/// Business Logic Component for managing Peer Profile details dynamically.
class PeerProfileBloc extends Bloc<PeerProfileEvent, PeerProfileState> {
  final PeersRepository _peersRepository;

  PeerProfileBloc({PeersRepository? peersRepository})
      : _peersRepository = peersRepository ?? PeersRepositoryImpl(),
        super(const PeerProfileState()) {
    on<LoadPeerProfile>(_onLoadPeerProfile);
    on<ChangeProfileSubTab>(_onChangeProfileSubTab);
    on<SelectPeerProfileSection>(_onSelectPeerProfileSection);
    on<FilterPeerProfileImpacts>(_onFilterPeerProfileImpacts);
    on<DeletePeerPost>(_onDeletePeerPost);
    on<DeletePeerCreative>(_onDeletePeerCreative);
  }

  Future<void> _onDeletePeerPost(
    DeletePeerPost event,
    Emitter<PeerProfileState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, errorMessage: '', successMessage: ''));
    try {
      var res = await _peersRepository.deleteMemberPost(event.memberId, event.postId);
      if (!res.success) {
        final creativeRes = await _peersRepository.deleteMemberCreative(event.memberId, event.postId);
        if (creativeRes.success) {
          res = creativeRes;
        }
      }

      if (res.success) {
        final currentPosts = state.details?.posts ?? [];
        final updatedPosts = currentPosts.where((p) => p.id != event.postId).toList();
        final updatedDetails = state.details?.copyWith(posts: updatedPosts);
        emit(
          state.copyWith(
            isDeleting: false,
            details: updatedDetails,
            successMessage: (res.message != null && res.message!.isNotEmpty)
                ? res.message!
                : 'Item deleted successfully.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isDeleting: false,
            errorMessage: (res.message != null && res.message!.isNotEmpty)
                ? res.message!
                : 'Failed to delete item.',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isDeleting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeletePeerCreative(
    DeletePeerCreative event,
    Emitter<PeerProfileState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true, errorMessage: '', successMessage: ''));
    try {
      var res = await _peersRepository.deleteMemberCreative(event.memberId, event.creativeId);
      if (!res.success) {
        final postRes = await _peersRepository.deleteMemberPost(event.memberId, event.creativeId);
        if (postRes.success) {
          res = postRes;
        }
      }

      if (res.success) {
        final currentPosts = state.details?.posts ?? [];
        final updatedPosts = currentPosts.where((p) => p.id != event.creativeId).toList();
        final updatedDetails = state.details?.copyWith(posts: updatedPosts);
        emit(
          state.copyWith(
            isDeleting: false,
            details: updatedDetails,
            successMessage: (res.message != null && res.message!.isNotEmpty)
                ? res.message!
                : 'Item deleted successfully.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isDeleting: false,
            errorMessage: (res.message != null && res.message!.isNotEmpty)
                ? res.message!
                : 'Failed to delete item.',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isDeleting: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadPeerProfile(
    LoadPeerProfile event,
    Emitter<PeerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    var currentPeer = event.peer;
    PeerProfileDetailModel details = PeerProfileDetailModel(
      bio: currentPeer.bio ?? '',
      birthday: currentPeer.birthday ?? '',
      anniversary: currentPeer.anniversary ?? '',
      joinedDate: currentPeer.joinedDate ?? '',
      dealsClosed: currentPeer.dealsFormatted,
      dealsGiven: currentPeer.dealsGiven ?? '₹0',
      dealsReceived: currentPeer.dealsReceived ?? '₹0',
      referralsGiven: currentPeer.referralsGiven ?? 0,
      referralsReceived: currentPeer.referralsReceived ?? 0,
      p2pSessions: currentPeer.p2pMeetings ?? 0,
      coinsEarned: currentPeer.coins,
      attendanceRate: currentPeer.attendance,
      impactCount: currentPeer.impactCount,
      introducedPeersCount: 0,
      tags: currentPeer.tags.isNotEmpty ? currentPeer.tags.split(' · ') : const [],
      phone: currentPeer.phone,
      email: currentPeer.email,
      whatsapp: currentPeer.whatsapp,
      linkedin: currentPeer.linkedin,
    );

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    final hasValidId = currentPeer.id.trim().isNotEmpty &&
        uuidRegex.hasMatch(currentPeer.id.trim());

    String loadError = '';

    if (hasValidId) {
      try {
        final profileDetailRes =
            await _peersRepository.getPeerProfileDetail(currentPeer.id.trim());
        if (profileDetailRes.success && profileDetailRes.data != null) {
          details = profileDetailRes.data!;
          final idHeader = details.identity;
          if (idHeader != null && idHeader.fullName.isNotEmpty) {
            currentPeer = PeerModel(
              id: currentPeer.id,
              initials: currentPeer.initials,
              name: idHeader.fullName,
              avatarUrl: idHeader.profilePhotoUrl ?? currentPeer.avatarUrl,
              company: idHeader.companyName.isNotEmpty
                  ? idHeader.companyName
                  : currentPeer.company,
              circle: idHeader.circleName.isNotEmpty
                  ? idHeader.circleName
                  : currentPeer.circle,
              circleId: idHeader.circleId.isNotEmpty
                  ? idHeader.circleId
                  : currentPeer.circleId,
              location: idHeader.city.isNotEmpty
                  ? idHeader.city
                  : currentPeer.location,
              tags: currentPeer.tags,
              impactCount: details.impactCount > 0
                  ? details.impactCount
                  : currentPeer.impactCount,
              dealsFormatted: details.dealsClosed.isNotEmpty
                  ? details.dealsClosed
                  : currentPeer.dealsFormatted,
              coins: details.coinsEarned > 0
                  ? details.coinsEarned
                  : currentPeer.coins,
              attendance: details.attendanceRate.isNotEmpty
                  ? details.attendanceRate
                  : currentPeer.attendance,
              status: idHeader.accountStatus.isNotEmpty
                  ? idHeader.accountStatus
                  : currentPeer.status,
              industry: idHeader.primaryCategory.isNotEmpty
                  ? idHeader.primaryCategory
                  : currentPeer.industry,
              level4Category: idHeader.level4Category.isNotEmpty
                  ? idHeader.level4Category
                  : currentPeer.level4Category,
              phone: idHeader.phone ?? currentPeer.phone,
              email: idHeader.email ?? currentPeer.email,
              designation: idHeader.designation.isNotEmpty
                  ? idHeader.designation
                  : currentPeer.designation,
              joinedDate: details.joinedDate.isNotEmpty
                  ? details.joinedDate
                  : currentPeer.joinedDate,
              isVerified: idHeader.isVerified || currentPeer.isVerified,
              introVideoUrl: currentPeer.introVideoUrl,
              bio: details.bio.isNotEmpty ? details.bio : currentPeer.bio,
              birthday: details.birthday.isNotEmpty
                  ? details.birthday
                  : currentPeer.birthday,
              anniversary: details.anniversary.isNotEmpty
                  ? details.anniversary
                  : currentPeer.anniversary,
              whatsapp: idHeader.whatsapp ?? currentPeer.whatsapp,
              linkedin: idHeader.linkedin ?? currentPeer.linkedin,
              dealsGiven: details.dealsGiven,
              dealsReceived: details.dealsReceived,
              referralsGiven: details.referralsGiven,
              referralsReceived: details.referralsReceived,
              p2pMeetings: details.p2pSessions,
            );
          }
        } else if ((profileDetailRes.message ?? '').trim().isNotEmpty) {
          loadError = profileDetailRes.message!.trim();
        }

        // Only call legacy getPeerDetails if structured identity section was absent
        if (details.identity == null) {
          final peerDetailsRes =
              await _peersRepository.getPeerDetails(currentPeer.id.trim());
          if (peerDetailsRes.success && peerDetailsRes.data != null) {
            currentPeer = peerDetailsRes.data!;
          }
        }

        if (details.introducedPeersCount == 0 &&
            (details.collaborationsInfo == null ||
                details.collaborationsInfo!.introducedPeersCount == 0)) {
          try {
            final introducedRes =
                await _peersRepository.getIntroducedPeers(currentPeer.id.trim());
            if (introducedRes.success &&
                introducedRes.data != null &&
                introducedRes.data!.isNotEmpty) {
              details = details.copyWith(
                introducedPeersCount: introducedRes.data!.length,
              );
            }
          } catch (_) {}
        }

        if (details.meetings.isEmpty) {
          try {
            final meetingsRes =
                await _peersRepository.getPeerMeetings(currentPeer.id.trim());
            if (meetingsRes.success && meetingsRes.data != null) {
              details = details.copyWith(meetings: meetingsRes.data!);
            }
          } catch (_) {}
        }

        // Fetch member posts & creatives
        final allItems = <PeerPostModel>[];
        try {
          final postsRes =
              await _peersRepository.getMemberPosts(currentPeer.id.trim());
          if (postsRes.success && postsRes.data != null) {
            allItems.addAll(
              postsRes.data!.map((m) => PeerPostModel.fromJson(m)),
            );
          }
        } catch (_) {}

        try {
          final creativesRes =
              await _peersRepository.getMemberCreatives(currentPeer.id.trim());
          if (creativesRes.success && creativesRes.data != null) {
            final parsedCreatives = creativesRes.data!
                .map((m) {
                  final map = Map<String, dynamic>.from(m);
                  map['is_creative'] = true;
                  return PeerPostModel.fromJson(map);
                })
                .toList();
            for (final c in parsedCreatives) {
              if (!allItems.any((existing) => existing.id == c.id)) {
                allItems.add(c);
              }
            }
          }
        } catch (_) {}

        if (allItems.isNotEmpty) {
          details = details.copyWith(posts: allItems);
        }
      } catch (e) {
        if (loadError.isEmpty) {
          loadError = e.toString();
        }
      }
    }

    emit(
      state.copyWith(
        isLoading: false,
        peer: currentPeer,
        details: details,
        errorMessage: loadError,
      ),
    );
  }

  void _onChangeProfileSubTab(
    ChangeProfileSubTab event,
    Emitter<PeerProfileState> emit,
  ) {
    final peer = state.peer;
    final sections = peer != null
        ? PeerProfilePresenter.resolveVisibleSections(peer, state.details)
        : PeerProfileSection.values;
    final clampedIdx =
        event.index.clamp(0, sections.isEmpty ? 0 : sections.length - 1);
    emit(state.copyWith(
      activeSubTab: clampedIdx,
      activeSection: sections[clampedIdx],
    ));
  }

  void _onSelectPeerProfileSection(
    SelectPeerProfileSection event,
    Emitter<PeerProfileState> emit,
  ) {
    final peer = state.peer;
    final sections = peer != null
        ? PeerProfilePresenter.resolveVisibleSections(peer, state.details)
        : PeerProfileSection.values;
    final idx = sections.indexOf(event.section);
    emit(state.copyWith(
      activeSection: event.section,
      activeSubTab: idx >= 0 ? idx : 0,
    ));
  }

  void _onFilterPeerProfileImpacts(
    FilterPeerProfileImpacts event,
    Emitter<PeerProfileState> emit,
  ) {
    emit(state.copyWith(
      impactStatusFilter: event.status,
      clearImpactStatusFilter: event.status == null,
    ));
  }
}
