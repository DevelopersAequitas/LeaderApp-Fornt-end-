import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/reports/model/report_download_model.dart';
import '../../features/reports/model/report_model.dart';
import '../datasources/remote/reports_remote_datasource.dart';

abstract class ReportsRepository {
  Future<ApiResponse<List<ReportModel>>> getReports({String? circleId, String? type, String? status});
  Future<ApiResponse<ReportModel>> getReportDetails(String id);
  Future<ApiResponse<Map<String, dynamic>>> submitReport({
    required String circleId,
    required String type,
    required String period,
    required String content,
  });
  Future<ApiResponse<List<ReportsChartPoint>>> getAttendanceTrend({String? circleId});
  Future<ApiResponse<Map<String, dynamic>>> exportReports({required String format, String? circleId});
  Future<ApiResponse<ReportDownloadModel>> getReportDownloadUrl(String reportId);
}

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remoteDataSource;
  final HiveCacheService _cacheService;

  ReportsRepositoryImpl({
    ReportsRemoteDataSource? remoteDataSource,
    HiveCacheService? cacheService,
  })  : _remoteDataSource = remoteDataSource ?? ReportsRemoteDataSource(),
        _cacheService = cacheService ?? HiveCacheService();

  @override
  Future<ApiResponse<ReportModel>> getReportDetails(String id) async {
    return _remoteDataSource.getReportDetails(id);
  }

  @override
  Future<ApiResponse<List<ReportModel>>> getReports({

    String? circleId,
    String? type,
    String? status,
  }) async {
    final cacheKey = 'reports_list_${circleId ?? "all"}_${type ?? "all"}';
    try {
      final response = await _remoteDataSource.getReports(
        circleId: circleId,
        type: type,
        status: status,
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
            .map((item) => ReportModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<ReportModel>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> submitReport({
    required String circleId,
    required String type,
    required String period,
    required String content,
  }) async {
    return _remoteDataSource.submitReport(
      circleId: circleId,
      type: type,
      period: period,
      content: content,
    );
  }

  @override
  Future<ApiResponse<List<ReportsChartPoint>>> getAttendanceTrend({String? circleId}) async {
    final cacheKey = 'reports_trend_${circleId ?? "all"}';
    try {
      final response = await _remoteDataSource.getAttendanceTrend(circleId: circleId);
      if (response.success && response.data != null) {
        final listJson = response.data!.map((x) => x.toJson()).toList();
        await _cacheService.put(cacheKey, listJson);
      }
      return response;
    } catch (e) {
      final cachedList = _cacheService.get(cacheKey);
      if (cachedList is List) {
        final cachedData = cachedList
            .map((item) => ReportsChartPoint.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        return ApiResponse<List<ReportsChartPoint>>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> exportReports({
    required String format,
    String? circleId,
  }) async {
    return _remoteDataSource.exportReports(format: format, circleId: circleId);
  }

  @override
  Future<ApiResponse<ReportDownloadModel>> getReportDownloadUrl(String reportId) async {
    return _remoteDataSource.getReportDownloadUrl(reportId);
  }
}
