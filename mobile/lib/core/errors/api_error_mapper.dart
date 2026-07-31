import 'package:dio/dio.dart';

import 'app_exception.dart';

abstract final class ApiErrorMapper {
  ApiErrorMapper._();

  static AppException fromDioException(DioException exception) {
    final DioExceptionType type = exception.type;

    final bool isTimeout =
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.transformTimeout;

    if (isTimeout) {
      return const AppException(
        message: 'The request took too long. Please try again.',
        type: AppExceptionType.timeout,
      );
    }

    if (type == DioExceptionType.connectionError) {
      return const AppException(
        message:
            'Unable to connect to SmartWallet. '
            'Check your internet connection and try again.',
        type: AppExceptionType.network,
      );
    }

    if (type == DioExceptionType.badCertificate) {
      return const AppException(
        message: 'A secure connection could not be established.',
        type: AppExceptionType.network,
      );
    }

    if (type == DioExceptionType.badResponse) {
      return _fromResponse(exception.response);
    }

    if (type == DioExceptionType.cancel) {
      return const AppException(
        message: 'The request was cancelled.',
        type: AppExceptionType.unknown,
      );
    }

    return const AppException(
      message: 'Something went wrong. Please try again.',
      type: AppExceptionType.unknown,
    );
  }

  static AppException _fromResponse(Response<dynamic>? response) {
    final int? statusCode = response?.statusCode;
    final String? backendMessage = _extractMessage(response?.data);

    if (statusCode == 400) {
      return AppException(
        message: backendMessage ?? 'Please check the submitted information.',
        type: AppExceptionType.validation,
        statusCode: statusCode,
      );
    }

    if (statusCode == 401) {
      return AppException(
        message:
            backendMessage ?? 'Authentication failed. Please log in again.',
        type: AppExceptionType.unauthorized,
        statusCode: statusCode,
      );
    }

    if (statusCode == 403) {
      return AppException(
        message:
            backendMessage ?? 'You are not allowed to perform this action.',
        type: AppExceptionType.forbidden,
        statusCode: statusCode,
      );
    }

    if (statusCode == 409) {
      return AppException(
        message:
            backendMessage ??
            'The request conflicts with existing information.',
        type: AppExceptionType.conflict,
        statusCode: statusCode,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return AppException(
        message:
            'SmartWallet is temporarily unavailable. '
            'Please try again later.',
        type: AppExceptionType.server,
        statusCode: statusCode,
      );
    }

    return AppException(
      message: backendMessage ?? 'The request could not be completed.',
      type: AppExceptionType.unknown,
      statusCode: statusCode,
    );
  }

  static String? _extractMessage(dynamic responseData) {
    if (responseData is! Map) {
      return null;
    }

    final dynamic message = responseData['message'];

    if (message is! String || message.trim().isEmpty) {
      return null;
    }

    return message.trim();
  }
}
