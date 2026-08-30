import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/circulars/model/circular_model.dart';
import '../datasources/remote/circulars_remote_datasource.dart';

abstract class CircularsRepository {
  Future<ApiResponse<List<CircularModel>>> getCirculars();
  Future<ApiResponse<Map<String, dynamic>>> publishCircular(CircularModel circular);
}

class CircularsRepositoryImpl implements CircularsRepository {
  final CircularsRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  CircularsRepositoryImpl({
    CircularsRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? CircularsRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<List<CircularModel>>> getCirculars() async {
    const cacheKey = 'official_circulars_list';
    try {
      final response = await _remoteDataSource.getCirculars();
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => CircularModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<CircularModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> publishCircular(CircularModel circular) async {
    return _remoteDataSource.publishCircular(circular);
  }
}
