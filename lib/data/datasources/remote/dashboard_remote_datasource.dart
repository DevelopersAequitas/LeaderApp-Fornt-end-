import '../../../core/constants/api_endpoints.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/dashboard/model/dashboard_metrics_model.dart';
import '../../../features/dashboard/model/impacter_model.dart';

class DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str.trim());
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString().replaceAll(',', '').trim()) ?? 0;
  }

  /// Fetches summary metrics for the active circle or regional scope with optional timeframe.
  /// Also enriches extended activity counts from live endpoints if the remote server
  /// returns 0 for newer activity fields.
  Future<ApiResponse<DashboardMetricsModel>> getMetrics({
    String? timeframe,
    String? circleId,
  }) async {
    final params = <String, String>{};
    if (timeframe != null && timeframe.isNotEmpty) {
      params['timeframe'] = timeframe;
    }
    if (_isValidUuid(circleId)) {
      params['circle_id'] = circleId!;
    }

    final baseResponse = await _apiClient.get<DashboardMetricsModel>(
      ApiEndpoints.dashboardMetrics,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is Map) {
          return DashboardMetricsModel.fromJson(json);
        }
        return const DashboardMetricsModel(
          impact: 0,
          deals: '₹0.0L',
          p2pMeetings: 0,
          totalPeers: 0,
          totalPeersGrowth: 0,
          referrals: 0,
          testimonials: 0,
          coins: 0,
        );
      },
    );

    if (!baseResponse.success || baseResponse.data == null) {
      return baseResponse;
    }

    DashboardMetricsModel metrics = baseResponse.data!;

    // Circle-scoped roles (Circle Director, Founder, Chairs, DED, Industry Director) must only see
    // the backend's already-scoped metrics. The enrichment endpoints below are platform-wide
    // (admin/leader asks summary, leads, pending requests) and would leak data outside the
    // user's scope, so they are used for global roles only.
    final role = SessionManager().currentSession.role;
    final isGlobalRole =
        role == UserRole.superAdmin || role == UserRole.countryDirector;
    if (!isGlobalRole) {
      // Pending approvals count must match the scoped list the leader opens
      // (/leader/activities/pending-requests), so read it from the scoped summary.
      try {
        final summary = await _apiClient.get<Map<String, dynamic>>(
          ApiEndpoints.leaderPendingRequestsSummary,
          queryParameters: const {'status': 'pending'},
          fromJsonT: (j) =>
              j is Map ? Map<String, dynamic>.from(j) : <String, dynamic>{},
        );
        if (summary.success && summary.data != null) {
          final pending = _parseInt(
            summary.data!['total_pending'] ?? summary.data!['total'],
          );
          return ApiResponse<DashboardMetricsModel>(
            success: true,
            message: baseResponse.message,
            data: metrics.copyWith(pendingRequestsCount: pending),
          );
        }
      } catch (_) {}
      return baseResponse;
    }

    // Always enrich extended activity counts in parallel from live endpoints on dev.peersunity.com
    // so every section across the 4 Dome Tabs reflects the complete real-time count.
    try {
      final results = await Future.wait<dynamic>([
        // 0: Asks Summary (/leader/asks/summary)
        _apiClient
            .get<Map<String, dynamic>>(
              ApiEndpoints.leaderAsksSummary,
              fromJsonT: (j) =>
                  j is Map ? Map<String, dynamic>.from(j) : <String, dynamic>{},
            )
            .catchError(
              (_) => const ApiResponse<Map<String, dynamic>>(success: false),
            ),
        // 1: Leads Counts (/admin/leads/counts)
        _apiClient
            .get<Map<String, dynamic>>(
              ApiEndpoints.adminLeadsCounts,
              fromJsonT: (j) =>
                  j is Map ? Map<String, dynamic>.from(j) : <String, dynamic>{},
            )
            .catchError(
              (_) => const ApiResponse<Map<String, dynamic>>(success: false),
            ),
        // 2: Pending Requests Summary (/admin/pending-requests/summary?status=all)
        _apiClient
            .get<Map<String, dynamic>>(
              ApiEndpoints.adminPendingRequestsSummary,
              queryParameters: const {'status': 'all'},
              fromJsonT: (j) =>
                  j is Map ? Map<String, dynamic>.from(j) : <String, dynamic>{},
            )
            .catchError(
              (_) => const ApiResponse<Map<String, dynamic>>(success: false),
            ),
        // 3: Posts count (/admin/posts?per_page=50)
        _apiClient
            .get<Map<String, dynamic>>(
              ApiEndpoints.adminPosts,
              queryParameters: {
                'per_page': '50',
                if (_isValidUuid(circleId)) 'circle_id': circleId!,
              },
              fromJsonT: (j) =>
                  j is Map ? Map<String, dynamic>.from(j) : <String, dynamic>{},
            )
            .catchError(
              (_) => const ApiResponse<Map<String, dynamic>>(success: false),
            ),
        // 4: Scoped Peers (/peers?per_page=500) to aggregate total life_impacted_count across all peers in role scope
        _apiClient
            .get<List<dynamic>>(
              ApiEndpoints.peers,
              queryParameters: {
                'per_page': '500',
                if (_isValidUuid(circleId)) 'circle_id': circleId!,
              },
              fromJsonT: (j) {
                if (j is List) return j;
                if (j is Map && j['data'] is List) return j['data'] as List;
                if (j is Map && j['peers'] is List) return j['peers'] as List;
                return <dynamic>[];
              },
            )
            .catchError(
              (_) => const ApiResponse<List<dynamic>>(success: false),
            ),
        // 5: Official Circulars (/circulars)
        _apiClient
            .get<List<dynamic>>(
              ApiEndpoints.circulars,
              fromJsonT: (j) {
                if (j is List) return j;
                if (j is Map && j['data'] is List) return j['data'] as List;
                if (j is Map && j['circulars'] is List) {
                  return j['circulars'] as List;
                }
                return <dynamic>[];
              },
            )
            .catchError(
              (_) => const ApiResponse<List<dynamic>>(success: false),
            ),
        // 6: Pending Requests List (/admin/pending-requests?category=all&status=pending&per_page=100)
        _apiClient
            .get<List<dynamic>>(
              ApiEndpoints.adminPendingRequests,
              queryParameters: const {
                'category': 'all',
                'status': 'pending',
                'per_page': '100',
              },
              fromJsonT: (j) {
                if (j is List) return j;
                if (j is Map && j['data'] is List) return j['data'] as List;
                if (j is Map && j['items'] is List) return j['items'] as List;
                return <dynamic>[];
              },
            )
            .catchError(
              (_) => const ApiResponse<List<dynamic>>(success: false),
            ),
      ]);

      int totalImpact = metrics.impact;
      int pendingReviews = metrics.pendingRequestsCount;
      int collabAsks = metrics.collaborationAsks;
      int refAsks = metrics.referralAsks;
      int helpAsks = metrics.helpAsks;
      int reqs = metrics.requirements;
      int allAsks = metrics.allAsks;
      int openAsks = metrics.openAsks;
      int inProgressAsks = metrics.inProgressAsks;
      int fulfilledAsks = metrics.fulfilledAsks;
      int visitors = metrics.visitorRegistrations;
      int peerRecs = metrics.peerRecommendations;
      int introPeers = metrics.introducedPeers;
      int coinClaims = metrics.coinClaims;
      int certs = metrics.certifications;
      int entrepreneurCerts = metrics.entrepreneurCertifications;
      int leadershipCerts = metrics.leadershipCertifications;
      int circularsCount = metrics.circulars;
      int eventRegs = metrics.eventRegistrations;
      int eventAtt = metrics.eventAttendance;
      int leaderInterests = metrics.leadershipInterests;
      int mentors = metrics.mentorApplications;
      int speakers = metrics.speakerApplications;
      int partners = metrics.partnerInquiries;
      int stories = metrics.stories;
      int postsCount = metrics.posts;
      int creativesCount = metrics.creatives;

      // Parse 0: Asks Summary
      final asksRes = results[0] as ApiResponse<Map<String, dynamic>>;
      if (asksRes.success && asksRes.data != null) {
        final data = asksRes.data!;
        final breakdown = data['flows_breakdown'];
        if (breakdown is Map) {
          if (breakdown['collaboration'] is Map) {
            final c = _parseInt(breakdown['collaboration']['total_asks']);
            if (c > collabAsks) collabAsks = c;
          }
          if (breakdown['referral'] is Map) {
            final r = _parseInt(breakdown['referral']['total_asks']);
            if (r > refAsks) refAsks = r;
          }
          if (breakdown['help'] is Map) {
            final h = _parseInt(breakdown['help']['total_asks']);
            if (h > helpAsks) helpAsks = h;
          }
        }
        final tr = _parseInt(data['total_requirements']);
        if (tr > reqs) reqs = tr;
        final active = _parseInt(data['active_requirements']);
        final fulfilled = _parseInt(data['fulfilled_requirements']);
        final inProg = _parseInt(data['in_progress_asks']);
        final published = data.containsKey('published_asks')
            ? _parseInt(data['published_asks'])
            : (active - inProg).clamp(0, active);
        if (tr > allAsks) allAsks = tr;
        if (fulfilled > fulfilledAsks) fulfilledAsks = fulfilled;
        if (inProg > inProgressAsks) inProgressAsks = inProg;
        if (published > openAsks) openAsks = published;
      }

      // Parse 1: Admin Leads Counts
      final leadsRes = results[1] as ApiResponse<Map<String, dynamic>>;
      if (leadsRes.success && leadsRes.data != null) {
        final data = leadsRes.data!;
        final eCert = _parseInt(data['entrepreneur_certification']);
        final lCert = _parseInt(data['leadership_certification']);
        if (eCert > entrepreneurCerts) entrepreneurCerts = eCert;
        if (lCert > leadershipCerts) leadershipCerts = lCert;
        if (lCert > leaderInterests) leaderInterests = lCert;
        if (eCert + lCert > certs) certs = eCert + lCert;

        final pCount = _parseInt(data['partner_with_us']);
        if (pCount > partners) partners = pCount;

        final sCount = _parseInt(data['become_speaker']);
        if (sCount > speakers) speakers = sCount;

        final mCount = _parseInt(data['become_mentor']);
        if (mCount > mentors) mentors = mCount;

        final stCount = _parseInt(data['story_submissions']);
        if (stCount > stories) stories = stCount;
      }

      // Parse 2: Pending / All Requests Summary Breakdown
      final pendingRes = results[2] as ApiResponse<Map<String, dynamic>>;
      if (pendingRes.success && pendingRes.data != null) {
        final breakdown = pendingRes.data!['breakdown'];
        if (breakdown is Map) {
          final vCount = _parseInt(
            breakdown['visitor_registrations'] ?? breakdown['visitors'],
          );
          if (vCount > visitors) visitors = vCount;

          final ccCount = _parseInt(breakdown['coin_claims']);
          if (ccCount > coinClaims) coinClaims = ccCount;

          final certCount = _parseInt(breakdown['certifications']);
          if (certCount > certs) certs = certCount;
          if (entrepreneurCerts == 0 && certCount > 0) {
            entrepreneurCerts = certCount;
          }

          final erCount = _parseInt(
            breakdown['event_registrations'] ??
                breakdown['event_joining_requests'],
          );
          if (erCount > eventRegs) eventRegs = erCount;

          final prCount = _parseInt(
            breakdown['circle_peer_referrals'] ?? breakdown['peer_referrals'],
          );
          if (prCount > peerRecs) peerRecs = prCount;

          final ipCount = _parseInt(breakdown['introduction_requests']);
          if (ipCount > introPeers) introPeers = ipCount;
        }
      }

      // Parse 3: Admin Posts Pagination Total & Creatives Count
      final postsRes = results[3] as ApiResponse<Map<String, dynamic>>;
      if (postsRes.success && postsRes.data != null) {
        final data = postsRes.data!;
        int fetchedPosts = 0;
        if (data['pagination'] is Map) {
          fetchedPosts = _parseInt(data['pagination']['total']);
        } else if (data['total'] != null) {
          fetchedPosts = _parseInt(data['total']);
        } else if (data['items'] is List) {
          fetchedPosts = (data['items'] as List).length;
        }
        if (fetchedPosts > postsCount) postsCount = fetchedPosts;

        if (data['items'] is List) {
          final itemsList = data['items'] as List;
          int cCount = 0;
          for (final post in itemsList) {
            if (post is Map) {
              final pType = (post['post_type'] ?? '').toString().toLowerCase();
              final hasMedia = post['media_url'] != null ||
                  post['image_url'] != null ||
                  (post['media'] is List && (post['media'] as List).isNotEmpty);
              if (pType.contains('creative') ||
                  pType.contains('impact') ||
                  pType.contains('celebration') ||
                  hasMedia) {
                cCount++;
              }
            }
          }
          if (cCount > creativesCount) creativesCount = cCount;
        }
      }

      // Parse 4: Sum life_impacted_count & introduced peers across all peers in role scope
      final peersRes = results[4] as ApiResponse<List<dynamic>>;
      if (peersRes.success && peersRes.data != null) {
        int sumPeerImpacts = 0;
        int countIntroduced = 0;
        for (final item in peersRes.data!) {
          if (item is Map) {
            final rawImp = item['life_impacted_count'] ??
                item['lives_impacted_count'] ??
                item['life_impact'] ??
                item['impact_count'] ??
                (item['metrics'] is Map
                    ? item['metrics']['life_impacted_count']
                    : null);
            sumPeerImpacts += _parseInt(rawImp);
            if (item['introduced_by'] != null ||
                item['referred_by'] != null ||
                item['referrer_id'] != null) {
              countIntroduced++;
            }
          }
        }
        if (sumPeerImpacts > totalImpact) {
          totalImpact = sumPeerImpacts;
        }
        if (countIntroduced > introPeers) {
          introPeers = countIntroduced;
        }
      }

      // Parse 5: Official Circulars count
      final circularsRes = results[5] as ApiResponse<List<dynamic>>;
      if (circularsRes.success && circularsRes.data != null) {
        if (circularsRes.data!.length > circularsCount) {
          circularsCount = circularsRes.data!.length;
        }
      }

      // Parse 6: Pending Reviews count (/admin/pending-requests?category=all&status=pending)
      final pendingListRes = results[6] as ApiResponse<List<dynamic>>;
      if (pendingListRes.success &&
          pendingListRes.data != null &&
          pendingListRes.data!.isNotEmpty) {
        pendingReviews = pendingListRes.data!.length;
      }

      if (peerRecs == 0 && metrics.referrals > 0) {
        peerRecs = metrics.referrals;
      }
      if (eventAtt == 0 && eventRegs > 0) {
        eventAtt = eventRegs;
      }

      metrics = metrics.copyWith(
        impact: totalImpact,
        pendingRequestsCount: pendingReviews,
        collaborationAsks: collabAsks,
        referralAsks: refAsks,
        helpAsks: helpAsks,
        requirements: reqs,
        allAsks: allAsks,
        openAsks: openAsks,
        inProgressAsks: inProgressAsks,
        fulfilledAsks: fulfilledAsks,
        visitorRegistrations: visitors,
        peerRecommendations: peerRecs,
        introducedPeers: introPeers,
        coinClaims: coinClaims,
        certifications: certs,
        entrepreneurCertifications: entrepreneurCerts,
        leadershipCertifications: leadershipCerts,
        circulars: circularsCount,
        eventRegistrations: eventRegs,
        eventAttendance: eventAtt,
        leadershipInterests: leaderInterests,
        mentorApplications: mentors,
        speakerApplications: speakers,
        partnerInquiries: partners,
        stories: stories,
        posts: postsCount,
        creatives: creativesCount,
      );
    } catch (_) {}

    return ApiResponse<DashboardMetricsModel>(
      success: true,
      message: baseResponse.message,
      data: metrics,
    );
  }

  /// Fetches top 5 impacters for the active circle.
  Future<ApiResponse<List<ImpacterModel>>> getTopImpacters({
    String? circleId,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) {
      params['circle_id'] = circleId!;
    }

    return _apiClient.get<List<ImpacterModel>>(
      ApiEndpoints.dashboardTopImpacters,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .asMap()
              .entries
              .map((entry) {
                final item = entry.value;
                if (item is Map<String, dynamic>) {
                  return ImpacterModel.fromJson(
                    item,
                    defaultRank: entry.key + 1,
                  );
                } else if (item is Map) {
                  return ImpacterModel.fromJson(
                    Map<String, dynamic>.from(item),
                    defaultRank: entry.key + 1,
                  );
                }
                return null;
              })
              .whereType<ImpacterModel>()
              .toList();
        } else if (json is Map && json['data'] is List) {
          final list = json['data'] as List;
          return list
              .asMap()
              .entries
              .map((entry) {
                final item = entry.value;
                if (item is Map<String, dynamic>) {
                  return ImpacterModel.fromJson(
                    item,
                    defaultRank: entry.key + 1,
                  );
                } else if (item is Map) {
                  return ImpacterModel.fromJson(
                    Map<String, dynamic>.from(item),
                    defaultRank: entry.key + 1,
                  );
                }
                return null;
              })
              .whereType<ImpacterModel>()
              .toList();
        }
        return <ImpacterModel>[];
      },
    );
  }
}
