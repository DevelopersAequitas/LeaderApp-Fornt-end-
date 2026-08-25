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
        }
        return <CircleTeamModel>[];
      },
    );
  }

  /// Fetches details for a single circle.
  Future<ApiResponse<CircleTeamModel>> getCircleDetails(String id) async {
    return _apiClient.get<CircleTeamModel>(
      ApiEndpoints.circleDetails(id),
      fromJsonT: (json) => CircleTeamModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches sub-industries breakdown (active and open specializations) for a circle.
  Future<ApiResponse<CircleSubIndustriesResponse>> getSubIndustries(String circleId) async {
    return _apiClient.get<CircleSubIndustriesResponse>(
      ApiEndpoints.circleSubIndustries(circleId),
      fromJsonT: (json) => CircleSubIndustriesResponse.fromJson(json as Map<String, dynamic>),
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
        }
        return <CircleEventModel>[];
      },
    );
  }

  /// Fetches the master list of industries dynamically from API.
  Future<ApiResponse<List<String>>> getIndustries() async {
    // 1. Derive dynamically from live circles API (100% supported endpoint)
    try {
      final circlesRes = await getCircles();
      if (circlesRes.success && circlesRes.data != null && circlesRes.data!.isNotEmpty) {
        final dynamicIndustries = circlesRes.data!
            .map((c) => c.category.trim())
            .where((cat) => cat.isNotEmpty)
            .toSet()
            .toList();
        if (dynamicIndustries.isNotEmpty) {
          return ApiResponse<List<String>>(
            success: true,
            data: dynamicIndustries,
            message: 'Derived dynamically from circles API',
          );
        }
      }
    } catch (_) {}

    // 2. Fallback: dedicated industries endpoint if deployed
    try {
      final res = await _apiClient.get<List<String>>(
        ApiEndpoints.teamsIndustries,
        fromJsonT: (json) {
          if (json is List) {
            return json.map((item) {
              if (item is Map) {
                return (item['name'] ?? item['title'] ?? item['category'] ?? '').toString();
              }
              return item.toString();
            }).where((s) => s.isNotEmpty).toList();
          }
          return <String>[];
        },
      );
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        return res;
      }
    } catch (_) {}

    return ApiResponse<List<String>>(
      success: true,
      data: const ['Technology'],
      message: 'Default industries',
    );
  }
}
