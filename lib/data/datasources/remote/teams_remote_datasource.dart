import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/circle_details/model/circle_event_model.dart';
import '../../../features/circle_details/model/circle_sub_industry_model.dart';
import '../../../features/peers/model/peer_model.dart';
import '../../../features/teams/model/teams_model.dart';

class TeamsRemoteDataSource {
  final ApiClient _apiClient;

  TeamsRemoteDataSource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches teams and circles summary metrics.
  Future<ApiResponse<TeamsSummaryModel>> getTeamsSummary() async {
    return _apiClient.get<TeamsSummaryModel>(
      ApiEndpoints.teamsSummary,
      fromJsonT: (json) =>
          TeamsSummaryModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches directory of circles.
  Future<ApiResponse<List<CircleTeamModel>>> getCircles({
    String? industry,
    String? status,
    String? search,
  }) async {
    return _apiClient.get<List<CircleTeamModel>>(
      ApiEndpoints.teamsCircles,
      queryParameters: {
        if (industry != null && industry != 'All Industries')
          'industry': industry,
        if (status != null && status != 'All') 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    CircleTeamModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List)
              .map(
                (item) =>
                    CircleTeamModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (json is Map && json['circles'] is List) {
          return (json['circles'] as List)
              .map(
                (item) =>
                    CircleTeamModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <CircleTeamModel>[];
      },
    );
  }

  /// Fetches details for a single circle.
  Future<ApiResponse<CircleTeamModel>> getCircleDetails(String id) async {
    return _apiClient.get<CircleTeamModel>(
      ApiEndpoints.circleDetails(id),
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          if (json['data'] is Map<String, dynamic>) {
            return CircleTeamModel.fromJson(
              json['data'] as Map<String, dynamic>,
            );
          }
          return CircleTeamModel.fromJson(json);
        }
        return const CircleTeamModel(
          name: '',
          category: '',
          location: '',
          peersCount: 0,
          healthPercentage: 0,
          revenue: '₹0.0',
          tags: [],
          founderName: '',
          directorName: '',
          chairName: '',
          status: 'Active',
        );
      },
    );
  }

  /// Fetches dedicated circle peers with pagination for Module 2: GET /api/v1/teams/circles/{circle_id}/peers
  Future<ApiResponse<List<PeerModel>>> getCirclePeers(
    String circleId, {
    String? status,
    String? search,
    String? sort,
    int? page,
    int? perPage,
  }) async {
    return _apiClient.get<List<PeerModel>>(
      ApiEndpoints.circlePeers(circleId),
      queryParameters: {
        if (status != null && status != 'All') 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        if (page != null) 'page': page.toString(),
        if (perPage != null) 'per_page': perPage.toString(),
      },
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map((item) => PeerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List)
              .map((item) => PeerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (json is Map && json['peers'] is List) {
          return (json['peers'] as List)
              .map((item) => PeerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <PeerModel>[];
      },
    );
  }

  /// Fetches sub-industries breakdown (active/closed and open specializations) for a circle.
  /// Enriches with occupant PeerModel and sector breadcrumbs if needed.
  Future<ApiResponse<CircleSubIndustriesResponse>> getSubIndustries(
    String circleId,
  ) async {
    final res = await _apiClient.get<CircleSubIndustriesResponse>(
      ApiEndpoints.circleSubIndustries(circleId),
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          if (json['data'] is Map<String, dynamic>) {
            return CircleSubIndustriesResponse.fromJson(
              json['data'] as Map<String, dynamic>,
            );
          }
          return CircleSubIndustriesResponse.fromJson(json);
        }
        return CircleSubIndustriesResponse(
          circleId: circleId,
          activeSubIndustries: const [],
          openSubIndustries: const [],
        );
      },
    );

    final data = res.data;
    if (data == null) return res;

    final needsOccupantEnrichment =
        data.activeSubIndustries.any((item) => item.occupant == null);
    final needsSectorEnrichment =
        data.openSubIndustries.any((item) => item.sectorName == null);

    if (!needsOccupantEnrichment && !needsSectorEnrichment) {
      return res;
    }

    var updatedActive = List<SubIndustryItemModel>.from(
      data.activeSubIndustries,
    );
    var updatedOpen = List<SubIndustryItemModel>.from(
      data.openSubIndustries,
    );

    try {
      if (needsOccupantEnrichment) {
        final closedRes = await _apiClient.get<List<SubIndustryItemModel>>(
          '${ApiEndpoints.baseUrl}/circles/$circleId/closed-categories',
          queryParameters: const {'per_page': '100'},
          fromJsonT: (json) {
            final list = <SubIndustryItemModel>[];
            final rawList = json is Map
                ? (json['closed_categories'] ?? json['data'])
                : json;
            if (rawList is List) {
              for (final raw in rawList) {
                if (raw is Map) {
                  list.add(
                    SubIndustryItemModel.fromJson(
                      Map<String, dynamic>.from(raw),
                    ),
                  );
                }
              }
            }
            return list;
          },
        );
        if (closedRes.success &&
            closedRes.data != null &&
            closedRes.data!.isNotEmpty) {
          updatedActive = closedRes.data!;
        } else {
          // Match with circle peers by category name if closed-categories is unavailable
          final peersRes = await getCirclePeers(circleId, perPage: 100);
          final circlePeers = peersRes.data ?? const <PeerModel>[];
          if (circlePeers.isNotEmpty) {
            updatedActive = updatedActive.map((item) {
              if (item.occupant != null) return item;
              final normalized = item.name.trim().toLowerCase();
              final matchingPeers = circlePeers.where((p) {
                final cat = (p.level4Category ?? p.tags).trim().toLowerCase();
                return cat == normalized || cat.contains(normalized);
              }).toList();
              if (matchingPeers.isNotEmpty) {
                return item.copyWith(
                  occupant: matchingPeers.first,
                  peers: matchingPeers,
                );
              }
              return item;
            }).toList();
          }
        }
      }

      if (needsSectorEnrichment) {
        final openRes = await _apiClient.get<List<SubIndustryItemModel>>(
          '${ApiEndpoints.baseUrl}/circles/$circleId/open-categories',
          queryParameters: const {'per_page': '100'},
          fromJsonT: (json) {
            final list = <SubIndustryItemModel>[];
            final rawList = json is Map
                ? (json['open_categories'] ?? json['data'])
                : json;
            if (rawList is List) {
              for (final raw in rawList) {
                if (raw is Map) {
                  final map = Map<String, dynamic>.from(raw);
                  map['is_open'] = true;
                  list.add(SubIndustryItemModel.fromJson(map));
                }
              }
            }
            return list;
          },
        );
        if (openRes.success &&
            openRes.data != null &&
            openRes.data!.isNotEmpty) {
          updatedOpen = openRes.data!;
        }
      }
    } catch (_) {}

    return ApiResponse<CircleSubIndustriesResponse>(
      success: true,
      message: res.message,
      data: CircleSubIndustriesResponse(
        circleId: data.circleId.isNotEmpty ? data.circleId : circleId,
        activeSubIndustries: updatedActive,
        openSubIndustries: updatedOpen,
      ),
    );
  }

  /// Submits a category referral for a circle (either for an existing peer or a contact).
  Future<ApiResponse<Map<String, dynamic>>> referCategory(
    String circleId,
    Map<String, dynamic> payload,
  ) async {
    final primaryRes = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.circleReferCategory(circleId),
      body: payload,
      fromJsonT: (json) => json is Map<String, dynamic>
          ? json
          : (json is Map
              ? Map<String, dynamic>.from(json)
              : <String, dynamic>{'success': true}),
    );

    if (primaryRes.success) {
      return primaryRes;
    }

    // Fallback to /forms/recommend-peer if the leader refer-category route isn't deployed yet
    final peerName = (payload['peer_name'] ?? payload['name'] ?? '').toString();
    final peerPhone =
        (payload['peer_phone'] ?? payload['phone'] ?? '').toString();
    final peerEmail =
        (payload['peer_email'] ?? payload['email'] ?? '').toString();
    final peerCity = (payload['peer_city'] ?? payload['city'] ?? '').toString();
    final peerCompany =
        (payload['peer_company'] ?? payload['company'] ?? '').toString();
    final categoryName = (payload['category_name'] ?? '').toString();
    final notes = (payload['notes'] ?? '').toString();

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.recommendPeerForm,
      body: {
        'peer_name': peerName,
        'peer_phone': peerPhone.isNotEmpty ? peerPhone : 'Not Provided',
        if (peerEmail.isNotEmpty) 'peer_email': peerEmail,
        if (peerCity.isNotEmpty) 'peer_city': peerCity,
        'how_well_known': categoryName.isNotEmpty
            ? 'Referred for $categoryName${peerCompany.isNotEmpty ? " ($peerCompany)" : ""}${notes.isNotEmpty ? " - $notes" : ""}'
            : (notes.isNotEmpty ? notes : 'Referred via Leader App'),
      },
      fromJsonT: (json) => json is Map<String, dynamic>
          ? json
          : (json is Map
              ? Map<String, dynamic>.from(json)
              : <String, dynamic>{'success': true}),
    );
  }

  /// Fetches saved/synced contacts for the 'From Contact' referral tab.
  Future<ApiResponse<List<ReferralContactModel>>> getContacts({
    String? search,
  }) async {
    final params = <String, String>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    List<ReferralContactModel> parseContacts(dynamic json) {
      final list = <ReferralContactModel>[];
      dynamic rawList = json;
      if (json is Map) {
        rawList = json['contacts'] ?? json['data'] ?? json['items'];
        if (rawList is Map) {
          rawList = rawList['contacts'] ?? rawList['data'] ?? rawList['items'];
        }
      }
      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map) {
            final model = ReferralContactModel.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (model.name.isNotEmpty || model.phone.isNotEmpty) {
              list.add(model);
            }
          }
        }
      }
      return list;
    }

    final primaryRes = await _apiClient.get<List<ReferralContactModel>>(
      ApiEndpoints.leaderContacts,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: parseContacts,
    );

    if (primaryRes.success && (primaryRes.data?.isNotEmpty ?? false)) {
      return primaryRes;
    }

    return _apiClient.get<List<ReferralContactModel>>(
      ApiEndpoints.contactPosts,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: parseContacts,
    );
  }

  /// Fetches events and assemblies for a circle.
  Future<ApiResponse<List<CircleEventModel>>> getCircleEvents(
    String circleId, {
    String? filter,
  }) async {
    final params = <String, String>{};
    if (filter != null && filter.toLowerCase() != 'all') {
      params['filter'] = filter.toLowerCase();
    }

    final res = await _apiClient.get<List<CircleEventModel>>(
      ApiEndpoints.circleEvents(circleId),
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    CircleEventModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List)
              .map(
                (item) =>
                    CircleEventModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (json is Map && json['events'] is List) {
          return (json['events'] as List)
              .map(
                (item) =>
                    CircleEventModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <CircleEventModel>[];
      },
    );

    if (res.success && res.data != null) {
      return res;
    }

    return _apiClient.get<List<CircleEventModel>>(
      '${ApiEndpoints.baseUrl}/teams/circles/$circleId/events',
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) =>
                    CircleEventModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List)
              .map(
                (item) =>
                    CircleEventModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <CircleEventModel>[];
      },
    );
  }

  /// Fetches the rich list of IndustryModel dynamically strictly from API.
  Future<ApiResponse<List<IndustryModel>>> getIndustriesList() async {
    return _apiClient.get<List<IndustryModel>>(
      ApiEndpoints.teamsIndustries,
      fromJsonT: (json) {
        if (json is List) {
          return json
              .map(
                (item) => IndustryModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List)
              .map(
                (item) => IndustryModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <IndustryModel>[];
      },
    );
  }

  /// Fetches the list of industries dynamically strictly from API.
  Future<ApiResponse<List<String>>> getIndustries() async {
    try {
      final res = await getIndustriesList();
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        final names = res.data!
            .map((i) => i.name.trim())
            .where((n) => n.isNotEmpty)
            .toList();
        return ApiResponse<List<String>>(
          success: true,
          data: names,
          message: res.message,
        );
      }
    } catch (_) {}

    return const ApiResponse<List<String>>(
      success: true,
      data: <String>[],
      message: 'No industries found',
    );
  }
}
