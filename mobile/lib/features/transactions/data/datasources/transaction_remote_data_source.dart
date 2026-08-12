import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/api_error_mapper.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../utils/transaction_formatters.dart';
import '../models/create_transaction_request_model.dart';
import '../models/transaction_filter_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_page_model.dart';
import '../models/update_transaction_request_model.dart';

final class TransactionRemoteDataSource {
  const TransactionRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<TransactionModel> createTransaction(
    CreateTransactionRequestModel request,
  ) async {
    try {
      final Response<String> response = await _apiClient.post<String>(
        ApiEndpoints.transactions,
        data: request.toJsonBody(),
        options: Options(responseType: ResponseType.plain),
      );
      return _parseTransaction(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<TransactionPageModel> getTransactions({
    required int page,
    required int size,
    String query = '',
    TransactionFilterModel filters = TransactionFilterModel.empty,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = <String, dynamic>{
        'page': page,
        'size': size,
      };

      final String normalizedQuery = query.trim();
      if (normalizedQuery.isNotEmpty) {
        queryParameters['query'] = normalizedQuery;
      }
      if (filters.type != null) {
        queryParameters['type'] = filters.type!.apiValue;
      }
      if (filters.category != null) {
        queryParameters['categoryId'] = filters.category!.id;
      }
      if (filters.startDate != null) {
        queryParameters['startDate'] = TransactionFormatters.toApiDate(
          filters.startDate!,
        );
      }
      if (filters.endDate != null) {
        queryParameters['endDate'] = TransactionFormatters.toApiDate(
          filters.endDate!,
        );
      }

      final Response<String> response = await _apiClient.get<String>(
        ApiEndpoints.transactions,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.plain),
      );
      return _parsePage(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<TransactionModel> getTransaction(int transactionId) async {
    try {
      final Response<String> response = await _apiClient.get<String>(
        ApiEndpoints.transactionById(transactionId),
        options: Options(responseType: ResponseType.plain),
      );
      return _parseTransaction(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<TransactionModel> updateTransaction(
    int transactionId,
    UpdateTransactionRequestModel request,
  ) async {
    try {
      final Response<String> response = await _apiClient.patch<String>(
        ApiEndpoints.transactionById(transactionId),
        data: request.toJsonBody(),
        options: Options(responseType: ResponseType.plain),
      );
      return _parseTransaction(response.data);
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  Future<void> archiveTransaction(int transactionId) async {
    try {
      await _apiClient.delete<void>(ApiEndpoints.transactionById(transactionId));
    } on DioException catch (exception) {
      throw ApiErrorMapper.fromDioException(exception);
    }
  }

  static TransactionModel _parseTransaction(String? data) {
    final Map<String, dynamic> json = _parseObject(data);
    try {
      return TransactionModel.fromJson(json);
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static TransactionPageModel _parsePage(String? data) {
    final Map<String, dynamic> json = _parseObject(data);
    try {
      return TransactionPageModel.fromJson(json);
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static Map<String, dynamic> _parseObject(String? data) {
    if (data == null || data.trim().isEmpty) {
      throw _invalidServerResponse();
    }

    try {
      // Dio's normal JSON decoder converts JSON numbers to Dart num first.
      // Reading the transaction response as text and quoting only numeric
      // `amount` fields preserves the backend BigDecimal lexical value before
      // jsonDecode, avoiding silent precision loss for large financial values.
      final Object? decoded = jsonDecode(_quoteNumericAmountValues(data));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid transaction response');
      }
      return decoded;
    } on FormatException {
      throw _invalidServerResponse();
    } on TypeError {
      throw _invalidServerResponse();
    }
  }

  static String _quoteNumericAmountValues(String source) {
    final StringBuffer output = StringBuffer();
    int index = 0;

    while (index < source.length) {
      if (source.codeUnitAt(index) != 0x22) {
        output.writeCharCode(source.codeUnitAt(index));
        index++;
        continue;
      }

      final int stringEnd = _findJsonStringEnd(source, index);
      final String token = source.substring(index, stringEnd);
      output.write(token);

      final Object? decodedToken = jsonDecode(token);
      if (decodedToken != 'amount') {
        index = stringEnd;
        continue;
      }

      int cursor = stringEnd;
      while (cursor < source.length && _isJsonWhitespace(source.codeUnitAt(cursor))) {
        output.writeCharCode(source.codeUnitAt(cursor));
        cursor++;
      }

      if (cursor >= source.length || source.codeUnitAt(cursor) != 0x3A) {
        index = cursor;
        continue;
      }

      output.writeCharCode(0x3A);
      cursor++;
      while (cursor < source.length && _isJsonWhitespace(source.codeUnitAt(cursor))) {
        output.writeCharCode(source.codeUnitAt(cursor));
        cursor++;
      }

      if (cursor >= source.length || !_isJsonNumberStart(source.codeUnitAt(cursor))) {
        index = cursor;
        continue;
      }

      final int numberStart = cursor;
      while (cursor < source.length && _isJsonNumberCharacter(source.codeUnitAt(cursor))) {
        cursor++;
      }

      output
        ..writeCharCode(0x22)
        ..write(source.substring(numberStart, cursor))
        ..writeCharCode(0x22);
      index = cursor;
    }

    return output.toString();
  }

  static int _findJsonStringEnd(String source, int start) {
    int cursor = start + 1;
    bool escaped = false;

    while (cursor < source.length) {
      final int codeUnit = source.codeUnitAt(cursor);
      if (escaped) {
        escaped = false;
      } else if (codeUnit == 0x5C) {
        escaped = true;
      } else if (codeUnit == 0x22) {
        return cursor + 1;
      }
      cursor++;
    }

    throw const FormatException('Unterminated JSON string');
  }

  static bool _isJsonWhitespace(int codeUnit) {
    return codeUnit == 0x20 ||
        codeUnit == 0x09 ||
        codeUnit == 0x0A ||
        codeUnit == 0x0D;
  }

  static bool _isJsonNumberStart(int codeUnit) {
    return codeUnit == 0x2D || (codeUnit >= 0x30 && codeUnit <= 0x39);
  }

  static bool _isJsonNumberCharacter(int codeUnit) {
    return (codeUnit >= 0x30 && codeUnit <= 0x39) ||
        codeUnit == 0x2D ||
        codeUnit == 0x2B ||
        codeUnit == 0x2E ||
        codeUnit == 0x45 ||
        codeUnit == 0x65;
  }

  static AppException _invalidServerResponse() {
    return const AppException(
      message: 'SmartWallet received an invalid server response.',
      type: AppExceptionType.unknown,
    );
  }
}
