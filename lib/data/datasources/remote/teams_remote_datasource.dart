import 'package:leaderapp/features/peers/model/peer_model.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/circle_details/model/circle_event_model.dart';
import '../../../features/circle_details/model/circle_sub_industry_model.dart';
import '../../../features/teams/model/teams_model.dart';

class TeamsRemoteDataSource {
  final ApiClient _apiClient;

  TeamsRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetches teams and circles summary metrics.
  Future<ApiResponse<TeamsSummaryModel>> getTeamsSummary() async {
    return _apiClient.get<TeamsSummaryModel>(
      ApiEndpoints.teamsSummary,
      fromJsonT: (json) => TeamsSummaryModel.fromJson(json as Map<String, dynamic>),
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
        if (industry != null && industry != 'All Industries') 'industry': industry,
        if (status != null && status != 'All') 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => CircleTeamModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List).map((item) => CircleTeamModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (json is Map && json['circles'] is List) {
          return (json['circles'] as List).map((item) => CircleTeamModel.fromJson(item as Map<String, dynamic>)).toList();
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
            return CircleTeamModel.fromJson(json['data'] as Map<String, dynamic>);
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

  /// Fetches dedicated circle peers for Module 2: GET /api/v1/teams/circles/{circle_id}/peers
  Future<ApiResponse<List<PeerModel>>> getCirclePeers(
    String circleId, {
    String? status,
    String? search,
    String? sort,
  }) async {
    return _apiClient.get<List<PeerModel>>(
      ApiEndpoints.circlePeers(circleId),
      queryParameters: {
        if (status != null && status != 'All') 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
      },
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => PeerModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List).map((item) => PeerModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (json is Map && json['peers'] is List) {
          return (json['peers'] as List).map((item) => PeerModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <PeerModel>[];
      },
    );
  }

  /// Fetches sub-industries breakdown (active and open specializations) for a circle.
  Future<ApiResponse<CircleSubIndustriesResponse>> getSubIndustries(String circleId) async {
    return _apiClient.get<CircleSubIndustriesResponse>(
      ApiEndpoints.circleSubIndustries(circleId),
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          if (json['data'] is Map<String, dynamic>) {
            return CircleSubIndustriesResponse.fromJson(json['data'] as Map<String, dynamic>);
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

    return _apiClient.get<List<CircleEventModel>>(
      ApiEndpoints.circleEvents(circleId),
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => CircleEventModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List).map((item) => CircleEventModel.fromJson(item as Map<String, dynamic>)).toList();
        } else if (json is Map && json['events'] is List) {
          return (json['events'] as List).map((item) => CircleEventModel.fromJson(item as Map<String, dynamic>)).toList();
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
              .map((item) => IndustryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (json is Map && json['data'] is List) {
          return (json['data'] as List)
              .map((item) => IndustryModel.fromJson(item as Map<String, dynamic>))
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
