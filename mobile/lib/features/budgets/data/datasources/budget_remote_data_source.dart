import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../transactions/utils/transaction_decimal.dart';
import '../../../transactions/utils/transaction_formatters.dart';
import '../models/budget_model.dart';
import '../models/budget_related_expense_model.dart';
import '../models/budget_month_model.dart';

final class BudgetRemoteDataSource {
  const BudgetRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  Future<BudgetMonthModel> getBudgets(DateTime month) async {
    try {
      final Response<dynamic> response = await _apiClient.get<dynamic>(ApiEndpoints.budgets, queryParameters: <String, dynamic>{'month': TransactionFormatters.toApiDate(DateTime(month.year, month.month, 1))});
      return _budgetMonth(response.data);
    } on DioException catch (e) { throw ApiErrorMapper.fromDioException(e); }
  }

  Future<BudgetModel> getBudget(int id) async {
    try {
      final Response<dynamic> response = await _apiClient.get<dynamic>(ApiEndpoints.budgetById(id));
      return _budget(response.data);
    } on DioException catch (e) { throw ApiErrorMapper.fromDioException(e); }
  }

  Future<List<BudgetRelatedExpenseModel>> getRelatedExpenses(int id, {int size = 5}) async {
    try {
      final Response<dynamic> response = await _apiClient.get<dynamic>(
        ApiEndpoints.budgetExpenses(id),
        queryParameters: <String, dynamic>{'size': size},
      );
      final Object? data = response.data;
      if (data is! List<dynamic>) {
        throw const AppException(
          message: 'SmartWallet received an invalid server response.',
          type: AppExceptionType.unknown,
        );
      }
      try {
        return data.map((Object? item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Invalid budget related expense response');
          }
          return BudgetRelatedExpenseModel.fromJson(item);
        }).toList(growable: false);
      } on FormatException {
        throw _invalidServerResponse();
      } on TypeError {
        throw _invalidServerResponse();
      }
    } on DioException catch (e) {
      throw ApiErrorMapper.fromDioException(e);
    }
  }

  Future<BudgetModel> create({required int categoryId, required String limitAmount, required DateTime month, String? note}) async {
    try {
      final String amount = TransactionDecimal.requireValidPositive(limitAmount);
      final String body = '{"categoryId":$categoryId,"limitAmount":$amount,"budgetMonth":${jsonEncode(TransactionFormatters.toApiDate(DateTime(month.year, month.month, 1)))},"note":${jsonEncode(note)}}';
      final Response<dynamic> response = await _apiClient.post<dynamic>(ApiEndpoints.budgets, data: body);
      return _budget(response.data);
    } on DioException catch (e) { throw ApiErrorMapper.fromDioException(e); }
  }

  Future<BudgetModel> update({required int id, required int version, required String limitAmount, String? note}) async {
    try {
      final String amount = TransactionDecimal.requireValidPositive(limitAmount);
      final String body = '{"version":$version,"limitAmount":$amount,"note":${jsonEncode(note)}}';
      final Response<dynamic> response = await _apiClient.patch<dynamic>(ApiEndpoints.budgetById(id), data: body);
      return _budget(response.data);
    } on DioException catch (e) { throw ApiErrorMapper.fromDioException(e); }
  }

  Future<void> archive({required int id, required int version}) async {
    try { await _apiClient.delete<void>(ApiEndpoints.budgetById(id), queryParameters: <String, dynamic>{'version': version}); }
    on DioException catch (e) { throw ApiErrorMapper.fromDioException(e); }
  }

  static BudgetModel _budget(dynamic data) {
    try {
      return BudgetModel.fromJson(_map(data));
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static BudgetMonthModel _budgetMonth(dynamic data) {
    try {
      return BudgetMonthModel.fromJson(_map(data));
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw _invalidServerResponse();
  }

  static AppException _invalidServerResponse() => const AppException(
    message: 'SmartWallet received an invalid server response.',
    type: AppExceptionType.unknown,
  );
}
