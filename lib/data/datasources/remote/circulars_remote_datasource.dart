import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/circulars/model/circular_model.dart';

class CircularsRemoteDataSource {
  final ApiClient _apiClient;

  CircularsRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetches role-targeted circulars and notices.
  Future<ApiResponse<List<CircularModel>>> getCirculars() async {
    return _apiClient.get<List<CircularModel>>(
      ApiEndpoints.circulars,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => CircularModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <CircularModel>[];
      },
    );
  }

  /// Broadcasts and publishes a new circular.
  Future<ApiResponse<Map<String, dynamic>>> publishCircular(CircularModel circular) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.circularPublish,
      body: circular.toJson(),
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}
