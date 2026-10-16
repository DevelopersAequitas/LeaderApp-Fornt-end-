import '../../core/network/api_response.dart';
import '../../core/storage/hive_cache_service.dart';
import '../../features/reports/model/report_download_model.dart';
import '../../features/reports/model/report_model.dart';
import '../datasources/remote/reports_remote_datasource.dart';

abstract class ReportsRepository {
  Future<ApiResponse<List<ReportModel>>> getReports({
    String? circleId,
    String? reportType,
    String? status,
    String? districtId,
    int? page,
    int? perPage,
  });
  Future<ApiResponse<ReportModel>> getReportDetails(String id);
  Future<ApiResponse<ReportSubmitResponse>> submitReport({
    required String circleId,
    required String reportType,
    required String period,
    required String summaryText,
    num? attendancePercentage,
    String? dealsClosedValue,
    String? totalRevenue,
    String? highlights,
    String? challengesFaced,
    String? actionItems,
    List<String>? includedSections,
    List<Map<String, dynamic>>? peersRoster,
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
    final cacheKey = 'report_details_$id';
    try {
      final response = await _remoteDataSource.getReportDetails(id);
      if (response.success && response.data != null) {
        await _cacheService.put(cacheKey, response.data!.toJson());
      }
      return response;
    } catch (e) {
      final cached = _cacheService.get(cacheKey);
      if (cached is Map) {
        final cachedData = ReportModel.fromJson(Map<String, dynamic>.from(cached));
        return ApiResponse<ReportModel>(
          success: true,
          data: cachedData,
          message: 'Loaded from offline cache',
        );
      }
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<ReportModel>>> getReports({
    String? circleId,
    String? reportType,
    String? status,
    String? districtId,
    int? page,
    int? perPage,
  }) async {
    final cacheKey = 'reports_list_${circleId ?? "all"}_${reportType ?? "all"}_${status ?? "all"}';
    try {
      final response = await _remoteDataSource.getReports(
        circleId: circleId,
        reportType: reportType,
        status: status,
        districtId: districtId,
        page: page,
        perPage: perPage,
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
            .where((report) => !ReportModel.isDummyReport(report))
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
  Future<ApiResponse<ReportSubmitResponse>> submitReport({
    required String circleId,
    required String reportType,
    required String period,
    required String summaryText,
    num? attendancePercentage,
    String? dealsClosedValue,
    String? totalRevenue,
    String? highlights,
    String? challengesFaced,
    String? actionItems,
    List<String>? includedSections,
    List<Map<String, dynamic>>? peersRoster,
  }) async {
    return _remoteDataSource.submitReport(
      circleId: circleId,
      reportType: reportType,
      period: period,
      summaryText: summaryText,
      attendancePercentage: attendancePercentage,
      dealsClosedValue: dealsClosedValue,
      totalRevenue: totalRevenue,
      highlights: highlights,
      challengesFaced: challengesFaced,
      actionItems: actionItems,
      includedSections: includedSections,
      peersRoster: peersRoster,
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
