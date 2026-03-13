

/// Base exception for server errors
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  ServerException({
    required this.message,
    this.statusCode,
    this.responseData,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Exception for authentication failures
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized. Please login again.']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Exception for permission denied
class ForbiddenException implements Exception {
  final String message;
  ForbiddenException([this.message = 'Permission denied.']);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Exception for resource not found
class NotFoundException implements Exception {
  final String doctype;
  final String? name;
  NotFoundException(this.doctype, [this.name]);

  @override
  String toString() =>
      'NotFoundException: $doctype${name != null ? ' ($name)' : ''} not found';
}

/// Exception for cache operations
class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache operation failed.']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for network connectivity issues
class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection.']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for validation errors from Frappe
class ValidationException implements Exception {
  final String message;
  final List<String> errors;

  ValidationException({
    required this.message,
    this.errors = const [],
  });

  @override
  String toString() => 'ValidationException: $message';
}
