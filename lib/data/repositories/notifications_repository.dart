import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/notifications/model/notification_model.dart';
import '../datasources/remote/notifications_remote_datasource.dart';

abstract class NotificationsRepository {
  Future<ApiResponse<List<NotificationModel>>> getNotifications();
  Future<ApiResponse<Map<String, dynamic>>> markAsRead({List<String>? notificationIds});
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  NotificationsRepositoryImpl({
    NotificationsRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? NotificationsRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    const cacheKey = 'notifications_all';
    try {
      final response = await _remoteDataSource.getNotifications();
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<NotificationModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> markAsRead({List<String>? notificationIds}) async {
    return _remoteDataSource.markAsRead(notificationIds: notificationIds);
  }
}
