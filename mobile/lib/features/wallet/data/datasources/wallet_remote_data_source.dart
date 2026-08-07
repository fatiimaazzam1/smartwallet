import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

final class WalletRemoteDataSource {
  const WalletRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<WalletModel> getCurrentWallet() async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient
          .get<Map<String, dynamic>>(ApiEndpoints.currentWallet);
      return _parseWallet(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  static WalletModel _parseWallet(Map<String, dynamic>? data) {
    if (data == null) {
      throw _invalidServerResponse();
    }

    try {
      return WalletModel.fromJson(data);
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
