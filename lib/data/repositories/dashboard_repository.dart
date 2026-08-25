import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/dashboard/model/dashboard_metrics_model.dart';
import '../../features/dashboard/model/impacter_model.dart';
import '../datasources/remote/dashboard_remote_datasource.dart';

abstract class DashboardRepository {
  Future<ApiResponse<DashboardMetricsModel>> getMetrics({String? circleId});
  Future<ApiResponse<List<ImpacterModel>>> getTopImpacters({String? circleId});
}

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  DashboardRepositoryImpl({
    DashboardRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? DashboardRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<DashboardMetricsModel>> getMetrics({String? circleId}) async {
    final cacheKey = 'dashboard_metrics_${circleId ?? "all"}';
    try {
      final response = await _remoteDataSource.getMetrics(circleId: circleId);
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      // Offline fallback: load from Hive cache
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = DashboardMetricsModel.fromJson(cachedJson);
        return ApiResponse<DashboardMetricsModel>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<ImpacterModel>>> getTopImpacters({String? circleId}) async {
    final cacheKey = 'dashboard_impacters_${circleId ?? "all"}';
    try {
      final response = await _remoteDataSource.getTopImpacters(circleId: circleId);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      // Offline fallback: load from Hive cache
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => ImpacterModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<ImpacterModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }
}
