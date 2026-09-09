import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../network/api_exception.dart';

/// Centralized utility for converting raw system errors, network failures,
/// and backend exceptions into user-friendly, readable human language.
class ErrorFormatter {
  const ErrorFormatter._();

  /// Converts any thrown error or exception into a clear, concise user-friendly message.
  static String format(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';

    if (error is ApiException) {
      return _cleanMessage(error.message);
    }

    if (error is DioException) {
      return _formatDioError(error);
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is TimeoutException) {
      return 'The request timed out. Please try again in a few moments.';
    }

    if (error is FormatException) {
      return 'Received an unexpected response from the server. Please try again.';
    }

    final rawString = error.toString();
    return _cleanMessage(rawString);
  }

  /// Translates DioException into human-friendly language.
  static String _formatDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection and try again.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final response = dioError.response;
        final statusCode = response?.statusCode;
        final dynamic data = response?.data;

        // Try extracting validation/custom message from response body
        final extracted = _extractMessageFromData(data);
        if (extracted != null && extracted.isNotEmpty) {
          return _cleanMessage(extracted);
        }

        switch (statusCode) {
          case 400:
            return 'Invalid request. Please verify the entered information.';
          case 401:
            return 'Your session has expired. Please sign in again.';
          case 403:
            return 'You do not have permission to perform this action.';
          case 404:
            return 'The requested information was not found.';
          case 422:
            return 'Please review the entered fields and correct any errors.';
          case 429:
            return 'Too many requests. Please wait a moment before trying again.';
          case 500:
          case 502:
          case 503:
          case 504:
            return 'Server is temporarily unavailable. Please try again later.';
          default:
            return 'Server returned an error ($statusCode). Please try again.';
        }

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.badCertificate:
        return 'Security certificate verification failed. Please check your network.';

      case DioExceptionType.unknown:
      default:
        if (dioError.error is SocketException) {
          return 'No internet connection. Please check your network and try again.';
        }
        return 'A network error occurred. Please try again.';
    }
  }

  /// Extracts readable error messages from standard JSON responses (e.g. Laravel validation errors).
  static String? _extractMessageFromData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // Check Laravel validation 'errors' object: { "field": ["Error 1", "Error 2"] }
      if (data['errors'] is Map) {
        final errorsMap = data['errors'] as Map;
        final List<String> messages = [];
        for (final val in errorsMap.values) {
          if (val is List && val.isNotEmpty) {
            final first = val.first.toString().trim();
            if (first.isNotEmpty) messages.add(first);
          } else if (val is String && val.trim().isNotEmpty) {
            messages.add(val.trim());
          }
        }
        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }

      if (data['message'] is String && (data['message'] as String).trim().isNotEmpty) {
        final msg = (data['message'] as String).trim();
        if (msg.toLowerCase() == 'unauthenticated' || msg.toLowerCase() == 'unauthenticated.') {
          return 'Your session has expired. Please sign in again.';
        }
        return msg;
      }

      if (data['error'] is String && (data['error'] as String).trim().isNotEmpty) {
        return (data['error'] as String).trim();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      final trimmed = data.trim();
      if (!trimmed.startsWith('{') && !trimmed.startsWith('<')) {
        return trimmed;
      }
    }

    return null;
  }

  /// Cleans raw prefixes like 'Exception: ', 'ApiException: ', etc.
  static String _cleanMessage(String raw) {
    var cleaned = raw.trim();

    // Strip common Dart exception prefixes
    final prefixes = [
      'Exception: ',
      'ApiException: ',
      'DioException: ',
      'ClientException: ',
      'FormatException: ',
      'Error: ',
    ];

    for (final prefix in prefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length).trim();
      }
    }

    // Replace generic technical messages with friendly terms
    if (cleaned.toLowerCase().contains('connection refused') ||
        cleaned.toLowerCase().contains('network is unreachable') ||
        cleaned.toLowerCase().contains('failed host lookup')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (cleaned.toLowerCase() == 'unauthenticated' || cleaned.toLowerCase() == 'unauthenticated.') {
      return 'Your session has expired. Please sign in again.';
    }

    return cleaned.isNotEmpty ? cleaned : 'An unexpected error occurred. Please try again.';
  }
}
