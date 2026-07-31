import 'package:dio/dio.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../constants/api_endpoints.dart';
import 'api_client.dart';

final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _apiClient = apiClient,
       _authRepository = authRepository;

  static const String _authorizationHeader = 'Authorization';
  static const String _retryKey = 'auth_retry_attempted';
  static const String _sentAccessTokenKey = 'sent_access_token';

  static const Set<String> _publicPaths = <String>{
    ApiEndpoints.register,
    ApiEndpoints.verifyEmail,
    ApiEndpoints.resendVerificationCode,
    ApiEndpoints.login,
    ApiEndpoints.refresh,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.resendPasswordResetCode,
    ApiEndpoints.verifyPasswordResetCode,
    ApiEndpoints.resetPassword,
  };

  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  Future<bool>? _refreshFuture;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String path = options.uri.path;

    if (!_isPublicPath(path)) {
      final String? accessToken = _authRepository.accessToken;

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers[_authorizationHeader] = 'Bearer $accessToken';

        options.extra[_sentAccessTokenKey] = accessToken;
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions requestOptions = err.requestOptions;

    final bool isUnauthorized = err.response?.statusCode == 401;

    final bool alreadyRetried = requestOptions.extra[_retryKey] == true;

    final bool isPublicRequest = _isPublicPath(requestOptions.uri.path);

    if (!isUnauthorized || alreadyRetried || isPublicRequest) {
      handler.next(err);
      return;
    }

    try {
      final String? tokenUsedByRequest =
          requestOptions.extra[_sentAccessTokenKey] as String?;

      String? currentAccessToken = _authRepository.accessToken;

      final bool anotherRequestAlreadyRefreshed =
          currentAccessToken != null &&
          currentAccessToken.isNotEmpty &&
          tokenUsedByRequest != null &&
          tokenUsedByRequest != currentAccessToken;

      if (!anotherRequestAlreadyRefreshed) {
        final bool sessionRestored = await _refreshAccessTokenOnce();

        if (!sessionRestored) {
          handler.next(err);
          return;
        }

        currentAccessToken = _authRepository.accessToken;
      }

      if (currentAccessToken == null || currentAccessToken.isEmpty) {
        handler.next(err);
        return;
      }

      requestOptions.headers[_authorizationHeader] =
          'Bearer $currentAccessToken';

      requestOptions.extra[_retryKey] = true;
      requestOptions.extra[_sentAccessTokenKey] = currentAccessToken;

      final Response<dynamic> retriedResponse = await _apiClient.fetch<dynamic>(
        requestOptions,
      );

      handler.resolve(retriedResponse);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<bool> _refreshAccessTokenOnce() {
    final Future<bool>? existingRefresh = _refreshFuture;

    if (existingRefresh != null) {
      return existingRefresh;
    }

    final Future<bool> refreshOperation = _authRepository.restoreSession();

    _refreshFuture = refreshOperation;

    return refreshOperation.whenComplete(() {
      _refreshFuture = null;
    });
  }

  bool _isPublicPath(String path) {
    return _publicPaths.contains(path);
  }
}
