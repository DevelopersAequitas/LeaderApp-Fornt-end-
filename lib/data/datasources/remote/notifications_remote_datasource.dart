import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/notifications/model/notification_model.dart';

class NotificationsRemoteDataSource {
  final ApiClient _apiClient;

  NotificationsRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Fetches user notifications.
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    return _apiClient.get<List<NotificationModel>>(
      ApiEndpoints.notifications,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        if (json is Map<String, dynamic>) {
          final list = json['notifications'] ?? json['data'] ?? json['items'];
          if (list is List) {
            return list.map((item) => NotificationModel.fromJson(item as Map<String, dynamic>)).toList();
          }
        }
        return <NotificationModel>[];
      },
    );
  }

  /// Marks specified notifications or all as read.
  Future<ApiResponse<Map<String, dynamic>>> markAsRead({List<String>? notificationIds}) async {
    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.notificationsMarkRead,
      body: {
        'notification_ids': notificationIds ?? ['all'],
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }
}
