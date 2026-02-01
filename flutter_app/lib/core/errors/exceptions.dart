/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception
class ServerException extends AppException {
  const ServerException([String message = 'Server error occurred', String? code])
      : super(message, code);
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred'])
      : super(message);
}

/// Auth exception
class AppAuthException extends AppException {
  const AppAuthException([String message = 'Authentication error', String? code])
      : super(message, code);
}

/// Storage exception
class AppStorageException extends AppException {
  const AppStorageException([String message = 'Storage error occurred'])
      : super(message);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException([String message = 'Cache error occurred'])
      : super(message);
}

/// Rate limit exception
class RateLimitException extends AppException {
  final int currentUsage;
  final int limit;
  final String tier;

  const RateLimitException({
    required this.currentUsage,
    required this.limit,
    required this.tier,
    String message = 'Rate limit exceeded',
  }) : super(message, 'rate_limit_exceeded');
}

/// Validation exception
class ValidationException extends AppException {
  const ValidationException([String message = 'Validation error'])
      : super(message, 'validation_error');
}
