enum AppExceptionType {
  validation,
  unauthorized,
  forbidden,
  conflict,
  network,
  timeout,
  server,
  unknown,
}

final class AppException implements Exception {
  const AppException({
    required this.message,
    required this.type,
    this.statusCode,
  });

  final String message;
  final AppExceptionType type;
  final int? statusCode;

  @override
  String toString() {
    return message;
  }
}
