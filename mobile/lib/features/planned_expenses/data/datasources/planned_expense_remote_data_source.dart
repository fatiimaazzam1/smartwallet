import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../transactions/utils/transaction_decimal.dart';
import '../../../transactions/utils/transaction_formatters.dart';
import '../models/planned_expense_model.dart';

final class PlannedExpenseRemoteDataSource {
  const PlannedExpenseRemoteDataSource({required ApiClient apiClient}) : _apiClient=apiClient;
  final ApiClient _apiClient;

  Future<PlannedExpensePageModel> list({required PlannedExpenseStatus status,required int page,int size=20}) async {
    try { final Response<dynamic> r=await _apiClient.get<dynamic>(ApiEndpoints.plannedExpenses,queryParameters:<String,dynamic>{'status':status.apiValue,'page':page,'size':size}); return _page(r.data); }
    on DioException catch(e){throw ApiErrorMapper.fromDioException(e);}
  }
  Future<PlannedExpenseModel> get(int id) async { try{final Response<dynamic> r=await _apiClient.get<dynamic>(ApiEndpoints.plannedExpenseById(id));return _item(r.data);}on DioException catch(e){throw ApiErrorMapper.fromDioException(e);} }
  Future<PlannedExpenseModel> create({required String clientRequestId,required String title,required String amount,required int categoryId,required DateTime dueOn,required PlannedExpenseRecurrence recurrence,String? note}) async {
    try{final String exact=TransactionDecimal.requireValidPositive(amount);final String body='{"clientRequestId":${jsonEncode(clientRequestId)},"title":${jsonEncode(title)},"amount":$exact,"categoryId":$categoryId,"dueOn":${jsonEncode(TransactionFormatters.toApiDate(dueOn))},"recurrence":${jsonEncode(recurrence.apiValue)},"note":${jsonEncode(note)}}';final Response<dynamic> r=await _apiClient.post<dynamic>(ApiEndpoints.plannedExpenses,data:body);return _item(r.data);}on DioException catch(e){throw ApiErrorMapper.fromDioException(e);}
  }
  Future<PlannedExpenseModel> update({required int id,required int version,required String title,required String amount,required int categoryId,required DateTime dueOn,required PlannedExpenseRecurrence recurrence,String? note}) async {
    try{final String exact=TransactionDecimal.requireValidPositive(amount);final String body='{"version":$version,"title":${jsonEncode(title)},"amount":$exact,"categoryId":$categoryId,"dueOn":${jsonEncode(TransactionFormatters.toApiDate(dueOn))},"recurrence":${jsonEncode(recurrence.apiValue)},"note":${jsonEncode(note)}}';final Response<dynamic> r=await _apiClient.patch<dynamic>(ApiEndpoints.plannedExpenseById(id),data:body);return _item(r.data);}on DioException catch(e){throw ApiErrorMapper.fromDioException(e);}
  }
  Future<PlannedExpenseModel> cancel({required int id,required int version}) async {try{final Response<dynamic> r=await _apiClient.post<dynamic>(ApiEndpoints.cancelPlannedExpense(id),data:<String,dynamic>{'version':version});return _item(r.data);}on DioException catch(e){throw ApiErrorMapper.fromDioException(e);}}
  Future<PlannedExpenseModel> markPaid({required int id,required int version,required DateTime paidOn,required String clientRequestId}) async {try{final Response<dynamic> r=await _apiClient.post<dynamic>(ApiEndpoints.markPlannedExpensePaid(id),data:<String,dynamic>{'version':version,'paidOn':TransactionFormatters.toApiDate(paidOn),'clientRequestId':clientRequestId});return _item(r.data);}on DioException catch(e){throw ApiErrorMapper.fromDioException(e);}}
  Future<void> archive({required int id,required int version}) async {try{await _apiClient.delete<void>(ApiEndpoints.plannedExpenseById(id),queryParameters:<String,dynamic>{'version':version});}on DioException catch(e){throw ApiErrorMapper.fromDioException(e);}}
  static PlannedExpenseModel _item(dynamic data){try{return PlannedExpenseModel.fromJson(_map(data));}on FormatException{throw _invalid();}on TypeError{throw _invalid();}}static PlannedExpensePageModel _page(dynamic data){try{return PlannedExpensePageModel.fromJson(_map(data));}on FormatException{throw _invalid();}on TypeError{throw _invalid();}}static Map<String,dynamic> _map(dynamic data){if(data is Map<String,dynamic>)return data;throw _invalid();}static AppException _invalid()=>const AppException(message:'SmartWallet received an invalid server response.',type:AppExceptionType.unknown);
}
