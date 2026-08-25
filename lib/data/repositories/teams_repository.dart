import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/circle_details/model/circle_event_model.dart';
import '../../features/circle_details/model/circle_sub_industry_model.dart';
import '../../features/teams/model/teams_model.dart';
import '../datasources/remote/teams_remote_datasource.dart';

abstract class TeamsRepository {
  Future<ApiResponse<TeamsSummaryModel>> getTeamsSummary();
  Future<ApiResponse<List<CircleTeamModel>>> getCircles({String? industry, String? status, String? search});
  Future<ApiResponse<CircleTeamModel>> getCircleDetails(String id);
  Future<ApiResponse<CircleSubIndustriesResponse>> getSubIndustries(String circleId);
  Future<ApiResponse<List<CircleEventModel>>> getCircleEvents(String circleId, {String? filter});
  Future<ApiResponse<List<String>>> getIndustries();
}

class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  TeamsRepositoryImpl({
    TeamsRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? TeamsRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<TeamsSummaryModel>> getTeamsSummary() async {
    const cacheKey = 'teams_summary';
    try {
      final response = await _remoteDataSource.getTeamsSummary();
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = TeamsSummaryModel.fromJson(cachedJson);
        return ApiResponse<TeamsSummaryModel>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<CircleTeamModel>>> getCircles({
    String? industry,
    String? status,
    String? search,
  }) async {
    final cacheKey = 'teams_circles_${industry ?? "all"}_${status ?? "all"}';
    try {
      final response = await _remoteDataSource.getCircles(
        industry: industry,
        status: status,
        search: search,
      );
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => CircleTeamModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<CircleTeamModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<CircleTeamModel>> getCircleDetails(String id) async {
    final cacheKey = 'circle_detail_$id';
    try {
      final response = await _remoteDataSource.getCircleDetails(id);
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = CircleTeamModel.fromJson(cachedJson);
        return ApiResponse<CircleTeamModel>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<CircleSubIndustriesResponse>> getSubIndustries(String circleId) async {
    final cacheKey = 'circle_sub_industries_$circleId';
    try {
      final response = await _remoteDataSource.getSubIndustries(circleId);
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      final cachedJson = _cacheService.get(cacheKey);
      if (cachedJson is Map<String, dynamic>) {
        final cachedData = CircleSubIndustriesResponse.fromJson(cachedJson);
        return ApiResponse<CircleSubIndustriesResponse>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<CircleEventModel>>> getCircleEvents(String circleId, {String? filter}) async {
    final cacheKey = 'circle_events_${circleId}_${filter ?? "all"}';
    try {
      final response = await _remoteDataSource.getCircleEvents(circleId, filter: filter);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => CircleEventModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<CircleEventModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<String>>> getIndustries() async {
    const cacheKey = 'teams_industries';
    try {
      final response = await _remoteDataSource.getIndustries();
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        return ApiResponse<List<String>>(
          success: true,
          data: cachedList.map((x) => x.toString()).toList(),
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }
}
