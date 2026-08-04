import '../../../../core/errors/app_exception.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/forgot_password_request_model.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/message_response_model.dart';
import '../models/password_reset_token_response_model.dart';
import '../models/refresh_request_model.dart';
import '../models/refresh_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/resend_verification_code_request_model.dart';
import '../models/resend_verification_code_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/verify_email_request_model.dart';
import '../models/verify_email_response_model.dart';
import '../models/verify_password_reset_code_request_model.dart';

final class AuthRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  String? _accessToken;

  String? get accessToken => _accessToken;

  bool get hasAccessToken {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    return await _remoteDataSource.register(request);
  }

  Future<VerifyEmailResponseModel> verifyEmail(
    VerifyEmailRequestModel request,
  ) async {
    return await _remoteDataSource.verifyEmail(request);
  }

  Future<ResendVerificationCodeResponseModel> resendVerificationCode(
    ResendVerificationCodeRequestModel request,
  ) async {
    return await _remoteDataSource.resendVerificationCode(request);
  }

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final LoginResponseModel response = await _remoteDataSource.login(request);

    await _localDataSource.saveRefreshToken(response.refreshToken);

    _accessToken = response.accessToken;

    return response;
  }

  Future<void> logout() async {
    final String? refreshToken = await _localDataSource.readRefreshToken();

    try {
      if (refreshToken != null) {
        await _remoteDataSource.logout(
          RefreshRequestModel(refreshToken: refreshToken),
        );
      }
    } on AppException {
      // Local logout must still complete if remote revocation is temporarily
      // unavailable. The raw refresh token is removed from this device below.
    } finally {
      _accessToken = null;
      await _localDataSource.deleteRefreshToken();
    }
  }

  Future<MessageResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    return await _remoteDataSource.forgotPassword(request);
  }

  Future<MessageResponseModel> resendPasswordResetCode(
    ForgotPasswordRequestModel request,
  ) async {
    return await _remoteDataSource.resendPasswordResetCode(request);
  }

  Future<PasswordResetTokenResponseModel> verifyPasswordResetCode(
    VerifyPasswordResetCodeRequestModel request,
  ) async {
    return await _remoteDataSource.verifyPasswordResetCode(request);
  }

  Future<MessageResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    return await _remoteDataSource.resetPassword(request);
  }

  Future<bool> restoreSession() async {
    final String? refreshToken = await _localDataSource.readRefreshToken();

    if (refreshToken == null) {
      _accessToken = null;
      return false;
    }

    try {
      final RefreshRequestModel request = RefreshRequestModel(
        refreshToken: refreshToken,
      );

      final RefreshResponseModel response = await _remoteDataSource
          .refreshAccessToken(request);

      _accessToken = response.accessToken;

      return true;
    } on AppException catch (exception) {
      final bool isInvalidSession =
          exception.type == AppExceptionType.unauthorized ||
          exception.type == AppExceptionType.forbidden;

      if (!isInvalidSession) {
        rethrow;
      }

      _accessToken = null;

      await _localDataSource.deleteRefreshToken();

      return false;
    }
  }
}
