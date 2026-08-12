import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/core/network/api_client.dart';
import 'package:smartwallet_mobile/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_model.dart';

void main() {
  test('preserves a large backend BigDecimal amount before JSON num parsing', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://smartwallet.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) {
          handler.resolve(
            Response<String>(
              requestOptions: options,
              statusCode: 200,
              data: '''
                {
                  "id": 7,
                  "version": 0,
                  "type": "INCOME",
                  "amount": 99999999999999999.99,
                  "description": "Large exact amount",
                  "occurredOn": "2026-08-08",
                  "currencyCode": "USD",
                  "status": "RECORDED",
                  "category": {
                    "id": 1,
                    "name": "Salary",
                    "iconKey": "salary"
                  }
                }
              ''',
            ),
          );
        },
      ),
    );

    final TransactionRemoteDataSource dataSource = TransactionRemoteDataSource(
      apiClient: ApiClient(dio: dio),
    );

    final TransactionModel transaction = await dataSource.getTransaction(7);

    expect(transaction.amount, '99999999999999999.99');
  });
}
