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

  /// Fetches summary metrics for the active circle or regional scope.
  Future<ApiResponse<DashboardMetricsModel>> getMetrics({String? circleId}) async {
    final params = <String, String>{};
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
          return json.map((item) => ImpacterModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <ImpacterModel>[];
      },
    );
  }
}
