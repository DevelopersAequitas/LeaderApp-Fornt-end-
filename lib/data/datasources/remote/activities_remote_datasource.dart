import '../../../core/constants/api_endpoints.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/business_deals/model/business_deal_model.dart';
import '../../../features/impacts/model/impact_model.dart';
import '../../../features/p2p_meetings/model/p2p_meeting_model.dart';
import '../../../features/peers_by_coins/model/coin_balance_model.dart';
import '../../../features/referrals/model/referral_model.dart';
import '../../../features/requirements/model/requirement_model.dart';
import '../../../features/testimonials/model/testimonial_model.dart';
import '../../../features/leader_activities/model/leader_activity_item_model.dart';

/// Remote Data Source for all 7 Activity Endpoints.
class ActivitiesRemoteDataSource {
  final ApiClient _apiClient;

  ActivitiesRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str.trim());
  }

  // --- 1. Impacts (Life Impact) ---
  Future<ApiResponse<List<ImpactModel>>> getImpacts({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<ImpactModel>>(
      ApiEndpoints.impacts,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => ImpactModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <ImpactModel>[];
      },
    );
  }

  Future<ApiResponse<ImpactModel>> createImpact({
    required String beneficiaryUserId,
    required String impactType,
    required String title,
    required String description,
  }) async {
    return _apiClient.post<ImpactModel>(
      ApiEndpoints.impacts,
      body: {
        'beneficiary_user_id': beneficiaryUserId,
        'impact_type': impactType,
        'title': title,
        'description': description,
      },
      fromJsonT: (json) => ImpactModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 2. P2P Meetings ---
  Future<ApiResponse<List<P2PMeetingModel>>> getP2PMeetings({
    String? circleId,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<P2PMeetingModel>>(
      ApiEndpoints.p2pMeetings,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    P2PMeetingModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <P2PMeetingModel>[];
      },
    );
  }

  Future<ApiResponse<P2PMeetingModel>> createP2PMeeting({
    required String peerUserId,
    required String scheduledAt,
    String mode = 'online',
    String location = 'Google Meet',
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'peer_user_id': peerUserId,
      'scheduled_at': scheduledAt,
      'mode': mode,
      'location': location,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    return _apiClient.post<P2PMeetingModel>(
      ApiEndpoints.p2pMeetings,
      body: body,
      fromJsonT: (json) =>
          P2PMeetingModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 3. Business Deals ---
  Future<ApiResponse<List<BusinessDealModel>>> getBusinessDeals({
    String? circleId,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<BusinessDealModel>>(
      ApiEndpoints.businessDeals,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    BusinessDealModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <BusinessDealModel>[];
      },
    );
  }

  Future<ApiResponse<BusinessDealModel>> createBusinessDeal({
    required String withPeerId,
    required dynamic amount,
    String currency = 'INR',
    String dealType = 'closed',
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'with_peer_id': withPeerId,
      'amount': amount,
      'currency': currency,
      'deal_type': dealType,
    };
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;

    return _apiClient.post<BusinessDealModel>(
      ApiEndpoints.businessDeals,
      body: body,
      fromJsonT: (json) =>
          BusinessDealModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 4. Referrals ---
  Future<ApiResponse<List<ReferralModel>>> getReferrals({
    String? circleId,
    String? status,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;
    if (status != null && status != 'All') params['status'] = status;

    return _apiClient.get<List<ReferralModel>>(
      ApiEndpoints.referrals,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) => ReferralModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <ReferralModel>[];
      },
    );
  }

  // --- 5. Testimonials ---
  Future<ApiResponse<List<TestimonialModel>>> getTestimonials({
    String? circleId,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<TestimonialModel>>(
      ApiEndpoints.testimonials,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    TestimonialModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <TestimonialModel>[];
      },
    );
  }

  Future<ApiResponse<TestimonialModel>> createTestimonial({
    required String toPeerId,
    required String content,
    int rating = 5,
  }) async {
    return _apiClient.post<TestimonialModel>(
      ApiEndpoints.testimonials,
      body: {'to_peer_id': toPeerId, 'content': content, 'rating': rating},
      fromJsonT: (json) =>
          TestimonialModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // --- 6. Peers by Coins ---
  Future<ApiResponse<List<CoinBalanceModel>>> getPeersByCoins({
    String? circleId,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<CoinBalanceModel>>(
      ApiEndpoints.peersByCoins,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is Map && json['leaderboard'] is List) {
          return (json['leaderboard'] as List)
              .map(
                (item) =>
                    CoinBalanceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (json is List) {
          return json
              .map(
                (item) =>
                    CoinBalanceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <CoinBalanceModel>[];
      },
    );
  }

  // --- 7. Requirements ---
  Future<ApiResponse<List<RequirementModel>>> getRequirements({
    String? circleId,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<RequirementModel>>(
      ApiEndpoints.requirements,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    RequirementModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <RequirementModel>[];
      },
    );
  }

  // --- 8. Unified Leader Activities by Type ---
  Future<ApiResponse<List<LeaderActivityItemModel>>> getActivitiesByType({
    required String type,
    String? circleId,
    String? search,
  }) async {
    final payloadRes = await getActivitiesPayloadByType(
      type: type,
      circleId: circleId,
      search: search,
    );
    return ApiResponse<List<LeaderActivityItemModel>>(
      success: payloadRes.success,
      message: payloadRes.message,
      data: payloadRes.data?.items ?? const <LeaderActivityItemModel>[],
    );
  }

  Future<ApiResponse<LeaderActivitiesPayload>> getActivitiesPayloadByType({
    required String type,
    String? circleId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    final config = LeaderActivityCategoryConfig.fromType(type);

    final res = await _apiClient.get<LeaderActivitiesPayload>(
      ApiEndpoints.leaderActivitiesByType(type),
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        final peers = <LeaderRankedPeerModel>[];
        final items = <LeaderActivityItemModel>[];

        if (json is Map) {
          if (json['peers'] is List) {
            final rawPeers = json['peers'] as List;
            for (var i = 0; i < rawPeers.length; i++) {
              final raw = rawPeers[i];
              if (raw is Map) {
                peers.add(
                  LeaderRankedPeerModel.fromJson(
                    Map<String, dynamic>.from(raw),
                    fallbackRank: i + 1,
                    defaultLabel: config.unitLabel,
                  ),
                );
              }
            }
          } else if (json['leaderboard'] is List) {
            final rawPeers = json['leaderboard'] as List;
            for (var i = 0; i < rawPeers.length; i++) {
              final raw = rawPeers[i];
              if (raw is Map) {
                peers.add(
                  LeaderRankedPeerModel.fromJson(
                    Map<String, dynamic>.from(raw),
                    fallbackRank: i + 1,
                    defaultLabel: config.unitLabel,
                  ),
                );
              }
            }
          }

          if (json['items'] is List) {
            for (final raw in (json['items'] as List)) {
              if (raw is Map) {
                items.add(
                  LeaderActivityItemModel.fromJson(
                    Map<String, dynamic>.from(raw),
                  ),
                );
              }
            }
          }
        } else if (json is List) {
          for (final raw in json) {
            if (raw is Map) {
              items.add(
                LeaderActivityItemModel.fromJson(
                  Map<String, dynamic>.from(raw),
                ),
              );
            }
          }
        }

        return LeaderActivitiesPayload(peers: peers, items: items);
      },
    );

    final meta = res.meta;
    if (res.data != null) {
      final peers = res.data!.peers;
      final items = res.data!.items;
      final sumPeerMetrics = peers.fold<int>(0, (sum, p) => sum + p.metricCount);
      final totalActivities = meta != null && meta.totalActivities > 0
          ? meta.totalActivities
          : (sumPeerMetrics > 0 ? sumPeerMetrics : (meta?.total ?? items.length));
      final totalPeers = meta != null && meta.totalPeers > 0
          ? meta.totalPeers
          : peers.length;
      final total = meta != null && meta.total > 0
          ? meta.total
          : items.length;
      final unitLabel = meta != null && meta.unitLabel.isNotEmpty
          ? meta.unitLabel
          : config.unitLabel;
      final hasMore = meta?.hasMore ?? (items.length >= limit);

      final populatedPayload = LeaderActivitiesPayload(
        peers: peers,
        items: items,
        totalActivities: totalActivities,
        totalPeers: totalPeers,
        total: total,
        page: page,
        perPage: limit,
        hasMore: hasMore,
        unitLabel: unitLabel,
      );

      return ApiResponse<LeaderActivitiesPayload>(
        success: res.success,
        message: res.message,
        errorCode: res.errorCode,
        meta: res.meta,
        data: populatedPayload,
      );
    }

    return res;
  }

  /// Live fallback fetcher for extended user-input activities when `/leader/activities/{type}`
  /// has not yet been deployed to the remote server.
  Future<List<LeaderActivityItemModel>> getExtendedActivitiesFallback({
    required String normalizedType,
    String? circleId,
  }) async {
    try {
      // 0. Status-based ask views (All / Open / In Progress / Fulfilled) built from all 3 flows
      if (normalizedType == 'all-asks' ||
          normalizedType == 'open-asks' ||
          normalizedType == 'in-progress-asks' ||
          normalizedType == 'fulfilled-asks') {
        final combined = <LeaderActivityItemModel>[];
        for (final flowType in const [
          'collaboration-asks',
          'referral-asks',
          'help-asks',
        ]) {
          combined.addAll(
            await getExtendedActivitiesFallback(
              normalizedType: flowType,
              circleId: circleId,
            ),
          );
        }
        bool matches(String status) {
          final s = status.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
          switch (normalizedType) {
            case 'open-asks':
              return s == 'published' || s == 'open' || s == 'active';
            case 'in-progress-asks':
              return s.contains('progress');
            case 'fulfilled-asks':
              return s.contains('fulfill') || s == 'completed';
            default:
              return true;
          }
        }

        return combined.where((item) => matches(item.status)).toList();
      }

      // 1. Collaboration, Referral, Help Asks -> `/leader/asks/{flow}/global`
      if (normalizedType == 'collaboration-asks' ||
          normalizedType == 'referral-asks' ||
          normalizedType == 'help-asks') {
        final flow = normalizedType.replaceAll('-asks', '');
        final res = await _apiClient.get<List<LeaderActivityItemModel>>(
          ApiEndpoints.leaderAsksGlobal(flow),
          fromJsonT: (json) {
            List<dynamic> list = [];
            if (json is List) {
              list = json;
            } else if (json is Map) {
              if (json['items'] is List) {
                list = json['items'] as List;
              } else if (json['asks'] is List) {
                list = json['asks'] as List;
              } else if (json['data'] is List) {
                list = json['data'] as List;
              }
            }
            return list.whereType<Map>().map((raw) {
              final map = Map<String, dynamic>.from(raw);
              final user = map['user'] is Map
                  ? Map<String, dynamic>.from(map['user'] as Map)
                  : <String, dynamic>{};
              final peerName =
                  (map['peer_name'] ??
                          map['creator'] ??
                          user['display_name'] ??
                          user['name'] ??
                          '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}')
                      .toString()
                      .trim();
              return LeaderActivityItemModel(
                id: (map['id'] ?? '').toString(),
                type: normalizedType,
                title: (map['title'] ?? map['subject'] ?? 'Peer Ask')
                    .toString(),
                subtitle:
                    (map['type_name'] ??
                            (map['type'] is Map
                                ? map['type']['name']
                                : map['type']) ??
                            flow.toUpperCase())
                        .toString(),
                description: (map['description'] ?? map['details'] ?? '')
                    .toString(),
                status: (map['status'] ?? 'Published').toString(),
                date: (map['created_at'] ?? '').toString().length > 10
                    ? (map['created_at'] ?? '').toString().substring(0, 10)
                    : (map['created_at'] ?? '').toString(),
                peerId: (map['user_id'] ?? user['id'] ?? '').toString(),
                peerName: peerName.isNotEmpty ? peerName : 'Peer Member',
                avatarUrl:
                    (user['avatar'] ??
                            user['profile_photo_url'] ??
                            map['avatar_url'])
                        ?.toString(),
                city: (user['city'] ?? map['city'] ?? '').toString(),
                designation:
                    (user['designation'] ?? map['designation'] ?? 'Member')
                        .toString(),
                company: (user['company_name'] ?? map['company'] ?? '')
                    .toString(),
                category:
                    (user['business_category'] ?? map['category'] ?? 'Business')
                        .toString(),
                circleName: (map['circle_name'] ?? '').toString(),
              );
            }).toList();
          },
        );
        return res.data ?? <LeaderActivityItemModel>[];
      }

      // Everything below relies on platform-wide admin endpoints. Circle-scoped roles
      // (Circle Director, Founder, Chairs, DED, Industry Director) must not see data
      // outside their scope, so only global roles may use these fallbacks.
      final fallbackRole = SessionManager().currentSession.role;
      if (fallbackRole != UserRole.superAdmin &&
          fallbackRole != UserRole.countryDirector) {
        return <LeaderActivityItemModel>[];
      }

      // 2. Timeline Posts & Activity Creatives -> `/admin/posts`
      if (normalizedType == 'posts' || normalizedType == 'creatives') {
        final res = await _apiClient.get<List<LeaderActivityItemModel>>(
          ApiEndpoints.adminPosts,
          queryParameters: {
            'per_page': '50',
            if (_isValidUuid(circleId)) 'circle_id': circleId!,
          },
          fromJsonT: (json) {
            List<dynamic> list = [];
            if (json is List) {
              list = json;
            } else if (json is Map && json['items'] is List) {
              list = json['items'] as List;
            }
            return list
                .whereType<Map>()
                .where((raw) {
                  if (normalizedType != 'creatives') return true;
                  final pType = (raw['post_type'] ?? '')
                      .toString()
                      .toLowerCase();
                  final hasMedia =
                      raw['media_url'] != null ||
                      raw['image_url'] != null ||
                      (raw['media'] is List &&
                          (raw['media'] as List).isNotEmpty);
                  return pType.contains('creative') ||
                      pType.contains('impact') ||
                      pType.contains('celebration') ||
                      hasMedia;
                })
                .map((raw) {
                  final map = Map<String, dynamic>.from(raw);
                  final user = map['user'] is Map
                      ? Map<String, dynamic>.from(map['user'] as Map)
                      : <String, dynamic>{};
                  final peerName =
                      (user['display_name'] ??
                              '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}')
                          .toString()
                          .trim();
                  return LeaderActivityItemModel(
                    id: (map['id'] ?? '').toString(),
                    type: normalizedType,
                    title:
                        (map['title'] ??
                                map['post_type'] ??
                                (normalizedType == 'creatives'
                                    ? 'Activity Creative'
                                    : 'Timeline Post'))
                            .toString(),
                    subtitle:
                        (map['post_type'] ??
                                (normalizedType == 'creatives'
                                    ? 'Creative Poster'
                                    : 'Community Post'))
                            .toString(),
                    description:
                        (map['content_text'] ?? map['description'] ?? '')
                            .toString(),
                    status: (map['status'] ?? 'Active').toString(),
                    date: (map['created_at'] ?? '').toString().length > 10
                        ? (map['created_at'] ?? '').toString().substring(0, 10)
                        : (map['created_at'] ?? '').toString(),
                    peerId: (map['user_id'] ?? user['id'] ?? '').toString(),
                    peerName: peerName.isNotEmpty ? peerName : 'Peer Member',
                    avatarUrl: user['profile_photo_url']?.toString(),
                    city: (user['city'] ?? '').toString(),
                    designation: (user['designation'] ?? 'Member').toString(),
                    company: (user['company_name'] ?? '').toString(),
                    category: 'Community',
                    circleName:
                        (map['circle'] is Map
                                ? map['circle']['name']
                                : (user['circle'] is Map
                                      ? user['circle']['name']
                                      : ''))
                            .toString(),
                  );
                })
                .toList();
          },
        );
        return res.data ?? <LeaderActivityItemModel>[];
      }

      // 2b. Official Circulars -> `/circulars`
      if (normalizedType == 'circulars') {
        final res = await _apiClient.get<List<LeaderActivityItemModel>>(
          ApiEndpoints.circulars,
          fromJsonT: (json) {
            List<dynamic> list = [];
            if (json is List) {
              list = json;
            } else if (json is Map) {
              if (json['items'] is List) {
                list = json['items'] as List;
              } else if (json['circulars'] is List) {
                list = json['circulars'] as List;
              } else if (json['data'] is List) {
                list = json['data'] as List;
              }
            }
            return list.whereType<Map>().map((raw) {
              final map = Map<String, dynamic>.from(raw);
              final author =
                  (map['author_name'] ??
                          map['published_by'] ??
                          map['creator_name'] ??
                          'Peers Global Leadership')
                      .toString()
                      .trim();
              final createdAt = (map['published_at'] ?? map['created_at'] ?? '')
                  .toString();
              return LeaderActivityItemModel(
                id: (map['id'] ?? '').toString(),
                type: 'circulars',
                title: (map['title'] ?? map['subject'] ?? 'Official Circular')
                    .toString(),
                subtitle: (map['category'] ?? map['audience'] ?? 'All Circles')
                    .toString(),
                description:
                    (map['content'] ?? map['description'] ?? map['body'] ?? '')
                        .toString(),
                status: (map['status'] ?? 'Published').toString(),
                date: createdAt.length > 10
                    ? createdAt.substring(0, 10)
                    : createdAt,
                peerId: (map['user_id'] ?? map['author_id'] ?? '').toString(),
                peerName: author.isNotEmpty
                    ? author
                    : 'Peers Global Leadership',
                city: '',
                designation: 'Leadership',
                company: 'Peers Global Unity',
                category: 'Official Circular',
                circleName: (map['circle_name'] ?? 'All Circles').toString(),
              );
            }).toList();
          },
        );
        return res.data ?? <LeaderActivityItemModel>[];
      }

      // 3. Pending / Moderation Streams (Pending Requests, Visitor Registrations, Coin Claims, Event Registrations/Attendance, Peer Recommendations, Introduced Peers, Certifications)
      const pendingCategoryMap = <String, String>{
        'pending-requests': 'all',
        'visitor-registrations': 'visitor_registrations',
        'coin-claims': 'coin_claims',
        'event-registrations': 'event_joining_requests',
        'event-attendance': 'event_joining_requests',
        'peer-recommendations': 'circle_peer_referrals',
        'introduced-peers': 'introduction_requests',
        'certifications': 'certifications',
        'entrepreneur-certifications': 'certifications',
      };
      if (pendingCategoryMap.containsKey(normalizedType)) {
        final categorySlug = pendingCategoryMap[normalizedType]!;
        final statusFilter = normalizedType == 'event-attendance'
            ? 'approved'
            : (normalizedType == 'pending-requests' ? 'pending' : 'all');
        Future<List<LeaderActivityItemModel>> fetchPendingWithStatus(
          String statusVal,
        ) async {
          final res = await _apiClient.get<List<LeaderActivityItemModel>>(
            ApiEndpoints.adminPendingRequests,
            queryParameters: {
              'category': categorySlug,
              'status': statusVal,
              'per_page': '100',
            },
            fromJsonT: (json) {
              List<dynamic> list = [];
              if (json is List) {
                list = json;
              } else if (json is Map) {
                if (json['data'] is List) {
                  list = json['data'] as List;
                } else if (json['items'] is List) {
                  list = json['items'] as List;
                }
              }
              return list.whereType<Map>().map((raw) {
                final map = Map<String, dynamic>.from(raw);
                final name =
                    (map['applicant_name'] ??
                            map['peer_name'] ??
                            map['name'] ??
                            'Peer Member')
                        .toString()
                        .trim();
                final company =
                    (map['company_name'] ??
                            map['business_name'] ??
                            map['company'] ??
                            '')
                        .toString();
                final targetEntity =
                    (map['target_entity'] ?? map['category_label'] ?? '')
                        .toString();
                final submittedAt =
                    (map['submitted_at'] ?? map['created_at'] ?? '').toString();
                return LeaderActivityItemModel(
                  id: (map['id'] ?? '').toString(),
                  type: normalizedType,
                  title: targetEntity.isNotEmpty
                      ? targetEntity
                      : (map['category_label'] ?? name).toString(),
                  subtitle: company.isNotEmpty ? company : name,
                  description: (map['details'] ?? map['description'] ?? '')
                      .toString(),
                  status: (map['status'] ?? 'Submitted').toString(),
                  date: submittedAt.length > 10
                      ? submittedAt.substring(0, 10)
                      : submittedAt,
                  amount:
                      normalizedType == 'coin-claims' &&
                          targetEntity.toLowerCase().contains('coin')
                      ? targetEntity
                      : null,
                  peerId: (map['user_id'] ?? map['peer_id'] ?? '').toString(),
                  peerName: name.isNotEmpty ? name : 'Peer Member',
                  city: (map['city'] ?? '').toString(),
                  designation: 'Member',
                  company: company,
                  category: (map['category_label'] ?? 'Community').toString(),
                  circleName: '',
                  requestCategory:
                      (map['category'] ??
                              (categorySlug != 'all' ? categorySlug : ''))
                          .toString(),
                );
              }).toList();
            },
          );
          return List<LeaderActivityItemModel>.from(
            res.data ?? const <LeaderActivityItemModel>[],
          );
        }

        var items = await fetchPendingWithStatus(statusFilter);
        if (items.isEmpty && statusFilter != 'all') {
          items = await fetchPendingWithStatus('all');
        }

        // For certifications / entrepreneur-certifications, also include certification leads if any
        if (normalizedType == 'certifications' ||
            normalizedType == 'entrepreneur-certifications') {
          final leadSlugs = normalizedType == 'entrepreneur-certifications'
              ? const ['entrepreneur_certification']
              : const [
                  'entrepreneur_certification',
                  'leadership_certification',
                ];
          for (final leadSlug in leadSlugs) {
            try {
              final leadRes = await _apiClient
                  .get<List<LeaderActivityItemModel>>(
                    ApiEndpoints.adminLeadsByType(leadSlug),
                    fromJsonT: (json) =>
                        _parseLeadItems(json, normalizedType: normalizedType),
                  );
              if (leadRes.data != null && leadRes.data!.isNotEmpty) {
                items.addAll(leadRes.data!);
              }
            } catch (_) {}
          }
        }

        if (items.isNotEmpty) {
          return items;
        }
      }

      // 4. Leads endpoints (Stories, Leadership Interests, Leadership/Entrepreneur Certifications, Mentors, Speakers, Partners)
      const leadsMap = <String, String>{
        'stories': 'story_submissions',
        'leadership-interests': 'leadership_certification',
        'leadership-certifications': 'leadership_certification',
        'entrepreneur-certifications': 'entrepreneur_certification',
        'mentor-applications': 'become_mentor',
        'speaker-applications': 'become_speaker',
        'partner-inquiries': 'partner_with_us',
        'certifications': 'entrepreneur_certification',
      };
      if (leadsMap.containsKey(normalizedType)) {
        final leadSlug = leadsMap[normalizedType]!;
        final res = await _apiClient.get<List<LeaderActivityItemModel>>(
          ApiEndpoints.adminLeadsByType(leadSlug),
          fromJsonT: (json) =>
              _parseLeadItems(json, normalizedType: normalizedType),
        );
        return res.data ?? <LeaderActivityItemModel>[];
      }
    } catch (_) {}

    return const <LeaderActivityItemModel>[];
  }

  List<LeaderActivityItemModel> _parseLeadItems(
    dynamic json, {
    required String normalizedType,
  }) {
    List<dynamic> list = [];
    if (json is List) {
      list = json;
    } else if (json is Map) {
      if (json['items'] is List) {
        list = json['items'] as List;
      } else if (json['data'] is List) {
        list = json['data'] as List;
      }
    }
    return list.whereType<Map>().map((raw) {
      final map = Map<String, dynamic>.from(raw);
      final name =
          (map['full_name'] ??
                  map['name'] ??
                  '${map['first_name'] ?? ''} ${map['last_name'] ?? ''}')
              .toString()
              .trim();
      final company =
          (map['business_name'] ??
                  map['company_name'] ??
                  map['brand_or_company_name'] ??
                  '')
              .toString();
      return LeaderActivityItemModel(
        id: (map['id'] ?? '').toString(),
        type: normalizedType,
        title: name.isNotEmpty ? name : 'Peer Submission',
        subtitle: company.isNotEmpty ? company : normalizedType,
        description:
            (map['notes'] ??
                    map['topics_to_speak_on'] ??
                    map['brief_bio'] ??
                    map['email'] ??
                    '')
                .toString(),
        status: (map['status'] ?? 'Submitted').toString(),
        date: (map['created_at'] ?? '').toString().length > 10
            ? (map['created_at'] ?? '').toString().substring(0, 10)
            : (map['created_at'] ?? '').toString(),
        peerId: (map['user_id'] ?? '').toString(),
        peerName: name.isNotEmpty ? name : 'Peer Member',
        city: (map['city'] ?? '').toString(),
        designation: 'Member',
        company: company,
        category: (map['industry'] ?? 'Business').toString(),
        circleName: '',
        requestCategory:
            normalizedType == 'certifications' ||
                normalizedType == 'entrepreneur-certifications' ||
                normalizedType == 'leadership-certifications'
            ? 'certifications'
            : null,
      );
    }).toList();
  }

  Map<String, dynamic> _asMap(dynamic json) => json is Map<String, dynamic>
      ? json
      : (json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{});

  /// Runs the request against each candidate URL in order and returns the first success.
  /// Leader-scoped endpoints come first so circle/category scope is enforced by the backend;
  /// the admin endpoints stay as a fallback for servers that haven't deployed the leader routes.
  Future<ApiResponse<Map<String, dynamic>>> _postFirstSuccess(
    List<String> urls,
    Map<String, dynamic> body,
  ) async {
    ApiResponse<Map<String, dynamic>>? last;
    for (final url in urls) {
      try {
        final res = await _apiClient.post<Map<String, dynamic>>(
          url,
          body: body,
          fromJsonT: _asMap,
        );
        if (res.success) return res;
        last = res;
        // Only fall back to the next URL when the route itself is missing. Real business
        // answers (403 scope guard, 422 wrong stage, 500 server error) must be shown as-is
        // instead of being retried through the admin route.
        final message = (res.message ?? '').toLowerCase();
        final routeMissing =
            message.isEmpty ||
            message.contains('could not be found') ||
            message.contains('route') && message.contains('not');
        if (!routeMissing) return res;
      } catch (_) {
        // try next candidate
      }
    }
    return last ??
        const ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Unable to complete the request',
        );
  }

  /// Approve a pending request item across any supported category.
  Future<ApiResponse<Map<String, dynamic>>> approvePendingRequest({
    required String id,
    String? category,
  }) async {
    final cleanCategory = category?.trim();
    final body = <String, dynamic>{
      'id': id,
      if (cleanCategory != null && cleanCategory.isNotEmpty)
        'category': cleanCategory,
    };
    final hasCategory = cleanCategory != null && cleanCategory.isNotEmpty;

    return _postFirstSuccess([
      if (hasCategory)
        ApiEndpoints.leaderApprovePendingRequest(id, category: cleanCategory),
      ApiEndpoints.leaderApprovePendingRequest(id),
      if (hasCategory)
        ApiEndpoints.adminApprovePendingRequest(id, category: cleanCategory),
      ApiEndpoints.adminApprovePendingRequest(id),
    ], body);
  }

  /// Reject a pending request item across any supported category.
  Future<ApiResponse<Map<String, dynamic>>> rejectPendingRequest({
    required String id,
    String? category,
    String? reason,
  }) async {
    final cleanCategory = category?.trim();
    final body = <String, dynamic>{
      'id': id,
      if (cleanCategory != null && cleanCategory.isNotEmpty)
        'category': cleanCategory,
      'reason': (reason != null && reason.trim().isNotEmpty)
          ? reason.trim()
          : 'Declined by Leader',
    };
    final hasCategory = cleanCategory != null && cleanCategory.isNotEmpty;

    return _postFirstSuccess([
      if (hasCategory)
        ApiEndpoints.leaderRejectPendingRequest(id, category: cleanCategory),
      ApiEndpoints.leaderRejectPendingRequest(id),
      if (hasCategory)
        ApiEndpoints.adminRejectPendingRequest(id, category: cleanCategory),
      ApiEndpoints.adminRejectPendingRequest(id),
    ], body);
  }
}
