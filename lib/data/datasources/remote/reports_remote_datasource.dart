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
    String? reportType,
    String? status,
    String? districtId,
    int? page,
    int? perPage,
  }) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!.trim();
    if (reportType != null && reportType.isNotEmpty && reportType.toLowerCase() != 'all') {
      params['report_type'] = reportType;
    }
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      params['status'] = status;
    }
    if (_isValidUuid(districtId)) params['district_id'] = districtId!.trim();
    if (page != null && page > 0) params['page'] = page.toString();
    if (perPage != null && perPage > 0) params['per_page'] = perPage.toString();

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

  /// Fetches single report details including peer breakdown.
  Future<ApiResponse<ReportModel>> getReportDetails(String id) async {
    return _apiClient.get<ReportModel>(
      ApiEndpoints.reportById(id),
      fromJsonT: (json) => ReportModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Submits a new performance report for higher leadership routing.
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
    final body = <String, dynamic>{
      'circle_id': circleId,
      'report_type': reportType,
      'period': period,
      'summary_text': summaryText,
      'included_sections': includedSections ?? const [
        'attendance',
        'financials',
        'peer_roster',
        'p2p_meetings',
        'action_items'
      ],
      'peers_roster': peersRoster ?? <Map<String, dynamic>>[],
    };
    if (attendancePercentage != null) body['attendance_percentage'] = attendancePercentage;
    if (dealsClosedValue != null && dealsClosedValue.isNotEmpty) {
      body['deals_closed_value'] = dealsClosedValue;
    }
    if (totalRevenue != null && totalRevenue.isNotEmpty) {
      body['total_revenue'] = totalRevenue;
    }
    if (highlights != null && highlights.isNotEmpty) {
      body['highlights'] = highlights;
    }
    if (challengesFaced != null && challengesFaced.isNotEmpty) {
      body['challenges_faced'] = challengesFaced;
    }
    if (actionItems != null && actionItems.isNotEmpty) {
      body['action_items'] = actionItems;
    }

    return _apiClient.post<ReportSubmitResponse>(
      ApiEndpoints.reports,
      body: body,
      fromJsonT: (json) => ReportSubmitResponse.fromJson(json as Map<String, dynamic>),
    );
  }


  /// Fetches attendance trend chart points.
  Future<ApiResponse<List<ReportsChartPoint>>> getAttendanceTrend({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!.trim();

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
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!.trim();

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
