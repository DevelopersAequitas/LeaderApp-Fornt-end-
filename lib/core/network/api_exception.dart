/// Base exception for all API-related failures.
class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;
  final dynamic details;

  const ApiException({
    required this.message,
    this.errorCode,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

/// Thrown when 401 Unauthorized / Token Expired is returned.
class UnauthenticatedException extends ApiException {
  const UnauthenticatedException({
    super.message = 'Your session has expired. Please sign in again.',
    super.errorCode = 'UNAUTHENTICATED',
    super.statusCode = 401,
    super.details,
  });
}

/// Thrown when 403 Forbidden is returned.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'You do not have permission to perform this action.',
    super.errorCode = 'UNAUTHORIZED_ACCESS',
    super.statusCode = 403,
    super.details,
  });
}

/// Thrown when 404 Not Found is returned.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'We couldn\'t find what you were looking for.',
    super.errorCode = 'RESOURCE_NOT_FOUND',
    super.statusCode = 404,
    super.details,
  });
}

/// Thrown when 422 Validation Error is returned.
class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Please check your details and try again.',
    super.errorCode = 'VALIDATION_ERROR',
    super.statusCode = 422,
    super.details,
  });
}

/// Thrown when network connection fails or timeout occurs.
class NetworkConnectionException extends ApiException {
  const NetworkConnectionException({
    super.message = 'Unable to connect. Please check your internet connection.',
    super.errorCode = 'NETWORK_ERROR',
    super.details,
  });
}
