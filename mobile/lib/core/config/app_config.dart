abstract final class AppConfig {
  AppConfig._();

  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const Duration connectTimeout = Duration(seconds: 10);

  static const Duration receiveTimeout = Duration(seconds: 15);

  static const Duration sendTimeout = Duration(seconds: 10);

  static String get apiBaseUrl {
    final String value = _apiBaseUrl.trim();

    if (value.isEmpty) {
      throw StateError(
        'API_BASE_URL is missing. '
        'Run Flutter using --dart-define=API_BASE_URL=<backend-url>.',
      );
    }

    final Uri? uri = Uri.tryParse(value);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw StateError('API_BASE_URL is invalid: $value');
    }

    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
