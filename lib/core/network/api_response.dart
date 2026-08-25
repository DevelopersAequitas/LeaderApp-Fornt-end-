/// Standard JSON Response Envelope adhering to backend contract:
/// {
///   "success": true,
///   "data": { ... },
///   "message": "..."
/// }
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final isSuccess = json['success'] as bool? ?? false;
    final rawData = json['data'];
    final message = json['message'] as String?;
    final errorCode = json['error_code'] as String?;

    T? parsedData;
    if (rawData != null && fromJsonT != null) {
      parsedData = fromJsonT(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    }

    return ApiResponse<T>(
      success: isSuccess,
      data: parsedData,
      message: message,
      errorCode: errorCode,
    );
  }
}
