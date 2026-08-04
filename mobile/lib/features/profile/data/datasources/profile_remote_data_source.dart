import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/update_user_profile_request_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_profile_model.dart';

final class ProfileRemoteDataSource {
  const ProfileRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserProfileModel> getCurrentUser() async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .get<Map<String, dynamic>>(ApiEndpoints.currentUser);
      return _parseProfile(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<UserProfileModel> updateCurrentUser(
    UpdateUserProfileRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .patch<Map<String, dynamic>>(
            ApiEndpoints.currentUser,
            data: request.toJson(),
          );
      return _parseProfile(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<UserPreferencesModel> getPreferences() async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .get<Map<String, dynamic>>(ApiEndpoints.currentUserPreferences);
      return _parsePreferences(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<UserPreferencesModel> updatePreferences(
    UserPreferencesModel preferences,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .put<Map<String, dynamic>>(
            ApiEndpoints.currentUserPreferences,
            data: preferences.toJson(),
          );
      return _parsePreferences(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  static UserProfileModel _parseProfile(Map<String, dynamic>? data) {
    if (data == null) {
      throw _invalidServerResponse();
    }

    try {
      return UserProfileModel.fromJson(data);
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static UserPreferencesModel _parsePreferences(Map<String, dynamic>? data) {
    if (data == null) {
      throw _invalidServerResponse();
    }

    try {
      return UserPreferencesModel.fromJson(data);
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static AppException _invalidServerResponse() {
    return const AppException(
      message: 'SmartWallet received an invalid server response.',
      type: AppExceptionType.unknown,
    );
  }
}
