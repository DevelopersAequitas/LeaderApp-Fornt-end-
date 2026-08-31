import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/dashboard/model/dashboard_metrics_model.dart';
import '../../../features/dashboard/model/impacter_model.dart';

class DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str.trim());
  }

  /// Fetches summary metrics for the active circle or regional scope with optional timeframe.
  Future<ApiResponse<DashboardMetricsModel>> getMetrics({String? timeframe, String? circleId}) async {
    final params = <String, String>{};
    if (timeframe != null && timeframe.isNotEmpty) {
      params['timeframe'] = timeframe;
    }
    if (_isValidUuid(circleId)) {
      params['circle_id'] = circleId!;
    }

    return _apiClient.get<DashboardMetricsModel>(
      ApiEndpoints.dashboardMetrics,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) => DashboardMetricsModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches top 5 impacters for the active circle.
  Future<ApiResponse<List<ImpacterModel>>> getTopImpacters({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) {
      params['circle_id'] = circleId!;
    }

    return _apiClient.get<List<ImpacterModel>>(
      ApiEndpoints.dashboardTopImpacters,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.asMap().entries.map((entry) {
            final item = entry.value;
            if (item is Map<String, dynamic>) {
              return ImpacterModel.fromJson(item, defaultRank: entry.key + 1);
            } else if (item is Map) {
              return ImpacterModel.fromJson(Map<String, dynamic>.from(item), defaultRank: entry.key + 1);
            }
            return null;
          }).whereType<ImpacterModel>().toList();
        } else if (json is Map && json['data'] is List) {
          final list = json['data'] as List;
          return list.asMap().entries.map((entry) {
            final item = entry.value;
            if (item is Map<String, dynamic>) {
              return ImpacterModel.fromJson(item, defaultRank: entry.key + 1);
            } else if (item is Map) {
              return ImpacterModel.fromJson(Map<String, dynamic>.from(item), defaultRank: entry.key + 1);
            }
            return null;
          }).whereType<ImpacterModel>().toList();
        }
        return <ImpacterModel>[];
      },
    );
  }
}
