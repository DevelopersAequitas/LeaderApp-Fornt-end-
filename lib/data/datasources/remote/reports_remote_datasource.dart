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

    try {
      return await _apiClient.get<List<ReportModel>>(
        ApiEndpoints.reports,
        queryParameters: params.isNotEmpty ? params : null,
        fromJsonT: _parseReportsList,
      );
    } catch (_) {
      return _apiClient.get<List<ReportModel>>(
        '${ApiEndpoints.baseUrl}/reports',
        queryParameters: params.isNotEmpty ? params : null,
        fromJsonT: _parseReportsList,
      );
    }
  }

  static List<ReportModel> _parseReportsList(dynamic json) {
    dynamic list = json;
    if (list is Map) {
      list = list['reports'] ?? list['data'] ?? list['items'] ?? list['list'] ?? list['results'];
    }
    if (list is List) {
      return list
          .whereType<Map>()
          .map((item) => ReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return <ReportModel>[];
  }

  /// Fetches single report details including peer breakdown.
  Future<ApiResponse<ReportModel>> getReportDetails(String id) async {
    ReportModel parseDetail(dynamic json) {
      if (json is Map) {
        final map = Map<String, dynamic>.from(json);
        final nested = map['data'];
        if (nested is Map) {
          return ReportModel.fromJson(Map<String, dynamic>.from(nested));
        }
        return ReportModel.fromJson(map);
      }
      return const ReportModel(
        type: 'Monthly',
        status: 'Submitted',
        date: '',
        content: '',
        author: '',
      );
    }

    try {
      return await _apiClient.get<ReportModel>(
        ApiEndpoints.reportById(id),
        fromJsonT: parseDetail,
      );
    } catch (_) {
      return _apiClient.get<ReportModel>(
        '${ApiEndpoints.baseUrl}/reports/$id',
        fromJsonT: parseDetail,
      );
    }
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

    try {
      return await _apiClient.post<ReportSubmitResponse>(
        ApiEndpoints.reports,
        body: body,
        fromJsonT: (json) {
          if (json is Map) {
            final map = Map<String, dynamic>.from(json);
            final nested = map['data'];
            if (nested is Map) {
              return ReportSubmitResponse.fromJson(Map<String, dynamic>.from(nested));
            }
            return ReportSubmitResponse.fromJson(map);
          }
          return ReportSubmitResponse.fromJson(const {});
        },
      );
    } catch (_) {
      return _apiClient.post<ReportSubmitResponse>(
        '${ApiEndpoints.baseUrl}/reports',
        body: body,
        fromJsonT: (json) {
          if (json is Map) {
            final map = Map<String, dynamic>.from(json);
            final nested = map['data'];
            if (nested is Map) {
              return ReportSubmitResponse.fromJson(Map<String, dynamic>.from(nested));
            }
            return ReportSubmitResponse.fromJson(map);
          }
          return ReportSubmitResponse.fromJson(const {});
        },
      );
    }
  }

  /// Fetches attendance trend chart points.
  Future<ApiResponse<List<ReportsChartPoint>>> getAttendanceTrend({String? circleId}) async {
    final params = <String, String>{};
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!.trim();

    List<ReportsChartPoint> parseTrend(dynamic json) {
      dynamic list = json;
      if (list is Map) {
        list = list['trend'] ?? list['attendance_trend'] ?? list['data'] ?? list['points'] ?? list['items'];
      }
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => ReportsChartPoint.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return <ReportsChartPoint>[];
    }

    try {
      return await _apiClient.get<List<ReportsChartPoint>>(
        ApiEndpoints.reportsAttendanceTrend,
        queryParameters: params.isNotEmpty ? params : null,
        fromJsonT: parseTrend,
      );
    } catch (_) {
      return _apiClient.get<List<ReportsChartPoint>>(
        '${ApiEndpoints.baseUrl}/reports/attendance-trend',
        queryParameters: params.isNotEmpty ? params : null,
        fromJsonT: parseTrend,
      );
    }
  }

  /// Exports report in PDF or Excel format.
  Future<ApiResponse<Map<String, dynamic>>> exportReports({
    String format = 'pdf',
    String? circleId,
  }) async {
    final cleanFormat = format.toLowerCase().contains('excel') || format.toLowerCase().contains('xlsx')
        ? 'excel'
        : 'pdf';
    final params = <String, String>{
      'format': cleanFormat,
      'type': cleanFormat,
    };
    if (cleanFormat == 'excel') {
      params['file_format'] = 'xlsx';
    }
    if (_isValidUuid(circleId)) params['circle_id'] = circleId!.trim();

    Map<String, dynamic> parseExport(dynamic json) {
      if (json is String && json.startsWith('http')) {
        return {'download_url': json, 'url': json};
      }
      if (json is Map) {
        final map = Map<String, dynamic>.from(json);
        final nestedData = map['data'];
        if (nestedData is String && nestedData.startsWith('http')) {
          map['download_url'] = nestedData;
          map['url'] = nestedData;
          return map;
        }
        if (nestedData is Map) {
          final nestedMap = Map<String, dynamic>.from(nestedData);
          final u = nestedMap['download_url'] ??
              nestedMap['url'] ??
              nestedMap['file_url'] ??
              nestedMap['link'] ??
              nestedMap['export_url'];
          if (u != null) {
            map['download_url'] = u.toString();
            map['url'] = u.toString();
          }
          return {...map, ...nestedMap};
        }
        final u = map['download_url'] ??
            map['url'] ??
            map['file_url'] ??
            map['link'] ??
            map['export_url'];
        if (u != null) {
          map['download_url'] = u.toString();
          map['url'] = u.toString();
        }
        return map;
      }
      return <String, dynamic>{};
    }

    try {
      return await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.reportsExport,
        queryParameters: params,
        fromJsonT: parseExport,
      );
    } catch (_) {
      return _apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.baseUrl}/reports/export',
        queryParameters: params,
        fromJsonT: parseExport,
      );
    }
  }

  /// Fetches a dynamic download URL for a generated report.
  Future<ApiResponse<ReportDownloadModel>> getReportDownloadUrl(String reportId) async {
    ReportDownloadModel parseDownload(dynamic json) {
      if (json is String && json.startsWith('http')) {
        return ReportDownloadModel(
          reportId: reportId,
          fileName: 'Report-$reportId.pdf',
          fileFormat: 'PDF',
          fileSize: '',
          downloadUrl: json,
          expiresInSeconds: 3600,
        );
      }
      if (json is Map) {
        final map = Map<String, dynamic>.from(json);
        final nested = map['data'];
        if (nested is String && nested.startsWith('http')) {
          return ReportDownloadModel(
            reportId: reportId,
            fileName: map['file_name']?.toString() ?? 'Report-$reportId.pdf',
            fileFormat: map['file_format']?.toString() ?? 'PDF',
            fileSize: map['file_size']?.toString() ?? '',
            downloadUrl: nested,
            expiresInSeconds: int.tryParse(map['expires_in_seconds']?.toString() ?? '') ?? 3600,
          );
        }
        if (nested is Map) {
          return ReportDownloadModel.fromJson(Map<String, dynamic>.from(nested));
        }
        return ReportDownloadModel.fromJson(map);
      }
      return ReportDownloadModel(
        reportId: reportId,
        fileName: 'Report-$reportId.pdf',
        fileFormat: 'PDF',
        fileSize: '',
        downloadUrl: '',
        expiresInSeconds: 3600,
      );
    }

    try {
      return await _apiClient.get<ReportDownloadModel>(
        ApiEndpoints.reportDownload(reportId),
        fromJsonT: parseDownload,
      );
    } catch (_) {
      return _apiClient.get<ReportDownloadModel>(
        '${ApiEndpoints.baseUrl}/reports/$reportId/download',
        fromJsonT: parseDownload,
      );
    }
  }
}
