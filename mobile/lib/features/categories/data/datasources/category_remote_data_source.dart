import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';
import '../models/category_type.dart';
import '../models/create_category_request_model.dart';

final class CategoryRemoteDataSource {
  const CategoryRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<CategoryModel>> getCategories({CategoryType? type}) async {
    try {
      final Response<List<dynamic>> response = await _apiClient
          .get<List<dynamic>>(
            ApiEndpoints.categories,
            queryParameters: type == null
                ? null
                : <String, dynamic>{'type': type.apiValue},
          );
      return _parseCategoryList(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<CategoryModel> createCategory(
    CreateCategoryRequestModel request,
  ) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.categories,
            data: request.toJson(),
          );
      return _parseCategory(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<void> archiveCategory(int categoryId) async {
    try {
      await _apiClient.delete<void>(ApiEndpoints.categoryById(categoryId));
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  static List<CategoryModel> _parseCategoryList(List<dynamic>? data) {
    if (data == null) {
      throw _invalidServerResponse();
    }

    try {
      return data
          .map((dynamic item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Invalid category response');
            }
            return CategoryModel.fromJson(item);
          })
          .where(
            (CategoryModel category) => !category.isRetiredSystemDefault,
          )
          .toList(growable: false);
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static CategoryModel _parseCategory(Map<String, dynamic>? data) {
    if (data == null) {
      throw _invalidServerResponse();
    }

    try {
      return CategoryModel.fromJson(data);
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
