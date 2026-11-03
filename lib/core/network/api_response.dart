/// Model representing pagination metadata returned by API endpoints.
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int totalActivities;
  final int totalPeers;
  final bool hasMore;
  final String unitLabel;

  const PaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.totalActivities = 0,
    this.totalPeers = 0,
    this.hasMore = false,
    this.unitLabel = 'Activities',
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: int.tryParse(json['current_page']?.toString() ?? json['page']?.toString() ?? '') ?? 1,
      lastPage: int.tryParse(json['last_page']?.toString() ?? json['total_pages']?.toString() ?? '') ?? 1,
      perPage: int.tryParse(json['per_page']?.toString() ?? '') ?? 20,
      total: int.tryParse(json['total']?.toString() ?? json['total_count']?.toString() ?? '') ?? 0,
      totalActivities: int.tryParse(json['total_activities']?.toString() ?? '') ?? 0,
      totalPeers: int.tryParse(json['total_peers']?.toString() ?? '') ?? 0,
      hasMore: json['has_more'] == true || (json['has_more']?.toString() == 'true'),
      unitLabel: json['unit_label']?.toString() ?? 'Activities',
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'total_activities': totalActivities,
        'total_peers': totalPeers,
        'has_more': hasMore,
        'unit_label': unitLabel,
      };
}

/// Standard JSON Response Envelope adhering to backend contract:
/// {
///   "success": true,
///   "message": "...",
///   "meta": { "current_page": 1, "last_page": 2, "per_page": 20, "total": 32 },
///   "data": [ ... ]
/// }
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final PaginationMeta? meta;
  final int? unreadCount;
  final int? totalCount;
  final Map<String, dynamic>? rawJson;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    this.meta,
    this.unreadCount,
    this.totalCount,
    this.rawJson,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final isSuccess = (json['success'] as bool?) ??
        (json['status'] is bool ? json['status'] as bool : null) ??
        json.containsKey('data');
    final rawData = json['data'];
    final message = json['message'] as String?;
    final errorCode = json['error_code'] as String?;

    final unreadCount = (json['unread_count'] as num?)?.toInt() ??
        (json['data'] is Map ? (json['data']['unread_count'] as num?)?.toInt() : null);
    final totalCount = (json['total_count'] as num?)?.toInt() ??
        (json['data'] is Map ? (json['data']['total_count'] as num?)?.toInt() : null) ??
        (json['total'] as num?)?.toInt();

    PaginationMeta? meta;
    if (json['meta'] is Map<String, dynamic>) {
      meta = PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>);
    } else if (json['meta'] is Map) {
      meta = PaginationMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map),
      );
    } else if (json['pagination'] is Map) {
      meta = PaginationMeta.fromJson(
        Map<String, dynamic>.from(json['pagination'] as Map),
      );
    }

    T? parsedData;
    if (rawData != null && fromJsonT != null) {
      parsedData = fromJsonT(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    } else if (json is T) {
      parsedData = json as T;
    }

    return ApiResponse<T>(
      success: isSuccess,
      data: parsedData,
      message: message,
      errorCode: errorCode,
      meta: meta,
      unreadCount: unreadCount,
      totalCount: totalCount ?? meta?.total,
      rawJson: json,
    );
  }
}
