import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../helpers/session_manager.dart';
import 'api_exception.dart';
import 'api_response.dart';

/// Robust HTTP Client powered by Dio implementing REST operations, automatic
/// token injection, timeouts, comprehensive request/response logging, and standardized error parsing.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  Dio get dio => _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      ),
    );

    // Add interceptor for auth token injection and detailed console logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Inject bearer token if authenticated
          final token = SessionManager().authToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            _printRequestLog(options);
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            _printResponseLog(response);
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            _printErrorLog(error);
          }
          return handler.next(error);
        },
      ),
    );
  }

  // --- Console Logging Helpers ---

  static void _printRequestLog(RequestOptions options) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 [DIO REQUEST] ➡️ ${options.method} ${options.uri}');
    debugPrint('📋 Headers: ${options.headers}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('🔍 Query Parameters: ${options.queryParameters}');
    }
    if (options.data != null) {
      final payload = options.data is Map || options.data is List
          ? jsonEncode(options.data)
          : options.data.toString();
      debugPrint('📦 Payload: $payload');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void _printResponseLog(Response response) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('✅ [DIO RESPONSE] ⬅️ [${response.statusCode}] ${response.requestOptions.method} ${response.requestOptions.uri}');
    debugPrint('📄 Data: ${response.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void _printErrorLog(DioException error) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('❌ [DIO ERROR] 💥 [${error.response?.statusCode ?? 'NO_STATUS'}] ${error.requestOptions.method} ${error.requestOptions.uri}');
    debugPrint('⚠️ Error Type: ${error.type}');
    debugPrint('💬 Message: ${error.message}');
    if (error.response?.data != null) {
      debugPrint('🛑 Server Response: ${error.response?.data}');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // --- REST HTTP Methods ---

  /// Sends a GET request.
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    return _sendRequest<T>(
      'GET',
      url,
      queryParameters: queryParameters,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  /// Sends a POST request.
  Future<ApiResponse<T>> post<T>(
    String url, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    return _sendRequest<T>(
      'POST',
      url,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  /// Sends a PUT request.
  Future<ApiResponse<T>> put<T>(
    String url, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    return _sendRequest<T>(
      'PUT',
      url,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  /// Sends a DELETE request.
  Future<ApiResponse<T>> delete<T>(
    String url, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    return _sendRequest<T>(
      'DELETE',
      url,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
      fromJsonT: fromJsonT,
    );
  }

  /// Core request dispatcher handling headers, Dio execution, response mapping, and error translation.
  Future<ApiResponse<T>> _sendRequest<T>(
    String method,
    String url, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final cleanParams = <String, dynamic>{};
      if (queryParameters != null) {
        queryParameters.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            cleanParams[key] = value;
          }
        });
      }

      final options = Options(
        method: method,
        headers: headers,
      );

      final Response response = await _dio.request(
        url,
        data: body,
        queryParameters: cleanParams.isNotEmpty ? cleanParams : null,
        options: options,
      );

      final dynamic responseData = response.data;
      final int statusCode = response.statusCode ?? 200;

      if (statusCode >= 200 && statusCode < 300) {
        if (responseData is Map<String, dynamic>) {
          return ApiResponse<T>.fromJson(responseData, fromJsonT);
        } else if (responseData is String && responseData.isNotEmpty) {
          try {
            final decoded = jsonDecode(responseData);
            if (decoded is Map<String, dynamic>) {
              return ApiResponse<T>.fromJson(decoded, fromJsonT);
            }
          } catch (_) {}
        }
        return ApiResponse<T>(
          success: true,
          data: fromJsonT != null ? fromJsonT(responseData) : responseData as T?,
        );
      }

      throw ApiException(
        message: 'Server returned HTTP status $statusCode',
        statusCode: statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  /// Translates DioException into standardized project ApiException hierarchy.
  ApiException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkConnectionException(
        message: 'Request timed out. Server took too long to respond.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkConnectionException(
        message: 'No internet connection or server unreachable.',
      );
    }

    final response = e.response;
    final statusCode = response?.statusCode;
    final dynamic responseData = response?.data;

    String errorMessage = 'An unexpected network error occurred.';
    String? errorCode;
    dynamic details;

    if (responseData is Map<String, dynamic>) {
      errorMessage = responseData['message'] as String? ?? errorMessage;
      errorCode = responseData['error_code'] as String?;
      details = responseData['details'];
    } else if (responseData is String && responseData.isNotEmpty) {
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map<String, dynamic>) {
          errorMessage = decoded['message'] as String? ?? errorMessage;
          errorCode = decoded['error_code'] as String?;
          details = decoded['details'];
        } else {
          errorMessage = responseData;
        }
      } catch (_) {
        errorMessage = responseData;
      }
    } else if (e.message != null && e.message!.isNotEmpty) {
      errorMessage = e.message!;
    }

    if (statusCode == 401) {
      return UnauthenticatedException(message: errorMessage, errorCode: errorCode);
    } else if (statusCode == 403) {
      return UnauthorizedException(message: errorMessage, errorCode: errorCode);
    } else if (statusCode == 404) {
      return NotFoundException(message: errorMessage, errorCode: errorCode);
    } else if (statusCode == 422) {
      return ValidationException(
        message: errorMessage,
        errorCode: errorCode,
        details: details,
      );
    }

    return ApiException(
      message: errorMessage,
      statusCode: statusCode,
      errorCode: errorCode,
    );
  }
}
