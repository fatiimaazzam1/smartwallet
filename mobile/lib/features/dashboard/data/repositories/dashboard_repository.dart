import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

final class DashboardRepository {
  const DashboardRepository({required ApiClient apiClient}):_apiClient=apiClient;final ApiClient _apiClient;
  Future<DashboardModel> get() async{try{final Response<dynamic> r=await _apiClient.get<dynamic>(ApiEndpoints.dashboard);if(r.data is! Map<String,dynamic>)throw const AppException(message:'SmartWallet received an invalid server response.',type:AppExceptionType.unknown);try{return DashboardModel.fromJson(r.data as Map<String,dynamic>);}on FormatException{throw const AppException(message:'SmartWallet received an invalid server response.',type:AppExceptionType.unknown);}on TypeError{throw const AppException(message:'SmartWallet received an invalid server response.',type:AppExceptionType.unknown);}}on DioException catch(e){throw ApiErrorMapper.fromDioException(e);}}
}
