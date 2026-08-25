import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../features/reports/model/report_download_model.dart';
import '../../../features/reports/model/report_model.dart';

class ReportsRemoteDataSource {
  final ApiClient _apiClient;

  ReportsRemoteDataSource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  static bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(str.trim());
  }

  /// Fetches submitted reports.
  Future<ApiResponse<List<ReportModel>>> getReports({
    String? circleId,
    String? type,
    String? status,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;
    if (type != null) params['type'] = type;
    if (status != null) params['status'] = status;

    return _apiClient.get<List<ReportModel>>(
      ApiEndpoints.reports,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => ReportModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <ReportModel>[];
      },
    );
  }

  /// Submits a new report.
  Future<ApiResponse<Map<String, dynamic>>> submitReport({
    required String circleId,
    required String type,
    required String period,
    required String content,
    int? attendancePercentage,
    String? dealsClosedValue,
    String? actionItems,
  }) async {
    final body = <String, dynamic>{
      'circle_id': circleId,
      'type': type,
      'period': period,
      'content': content,
    };
    if (attendancePercentage != null) body['attendance_percentage'] = attendancePercentage;
    if (dealsClosedValue != null) body['deals_closed_value'] = dealsClosedValue;
    if (actionItems != null) body['action_items'] = actionItems;

    return _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.reports,
      body: body,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Fetches attendance trend chart points.
  Future<ApiResponse<List<ReportsChartPoint>>> getAttendanceTrend({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<List<ReportsChartPoint>>(
      ApiEndpoints.reportsAttendanceTrend,
      queryParameters: params.isNotEmpty ? params : null,
      fromJsonT: (json) {
        if (json is List) {
          return json.map((item) => ReportsChartPoint.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <ReportsChartPoint>[];
      },
    );
  }

  /// Exports report in PDF or Excel format.
  Future<ApiResponse<Map<String, dynamic>>> exportReports({
    String format = 'pdf',
    String? circleId,
  }) async {
    final params = <String, String>{'format': format};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!;

    return _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.reportsExport,
      queryParameters: params,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
  }

  /// Fetches a dynamic download URL for a generated report.
  Future<ApiResponse<ReportDownloadModel>> getReportDownloadUrl(String reportId) async {
    return _apiClient.get<ReportDownloadModel>(
      ApiEndpoints.reportDownload(reportId),
      fromJsonT: (json) => ReportDownloadModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
