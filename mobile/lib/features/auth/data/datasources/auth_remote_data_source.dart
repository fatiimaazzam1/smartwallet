import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
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

final class AuthRemoteDataSource {
  const AuthRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.register,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return RegisterResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<VerifyEmailResponseModel> verifyEmail(
    VerifyEmailRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.verifyEmail,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return VerifyEmailResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<ResendVerificationCodeResponseModel> resendVerificationCode(
    ResendVerificationCodeRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.resendVerificationCode,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return ResendVerificationCodeResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.login,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return LoginResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<RefreshResponseModel> refreshAccessToken(
    RefreshRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.refresh,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return RefreshResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<MessageResponseModel> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.forgotPassword,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return MessageResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<MessageResponseModel> resendPasswordResetCode(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.resendPasswordResetCode,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return MessageResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<PasswordResetTokenResponseModel> verifyPasswordResetCode(
    VerifyPasswordResetCodeRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.verifyPasswordResetCode,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return PasswordResetTokenResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<MessageResponseModel> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.resetPassword,
            data: request.toJson(),
          );

      final Map<String, dynamic>? responseData = response.data;

      if (responseData == null) {
        throw _invalidServerResponse();
      }

      try {
        return MessageResponseModel.fromJson(responseData);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  static AppException _invalidServerResponse() {
    return const AppException(
      message: 'SmartWallet received an invalid server response.',
      type: AppExceptionType.unknown,
    );
  }
}
