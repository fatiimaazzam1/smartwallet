import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/create_transaction_request_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_type.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/update_transaction_request_model.dart';

void main() {
  test('create request serializes only backend-authoritative fields', () {
    final CreateTransactionRequestModel request = CreateTransactionRequestModel(
      clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
      type: TransactionType.income,
      amount: '1000.00',
      categoryId: 1,
      occurredOn: DateTime(2026, 8, 8),
      description: 'Monthly salary',
    );
    final Map<String, dynamic> json = request.toJson();

    expect(json, <String, dynamic>{
      'clientRequestId': '123e4567-e89b-42d3-a456-426614174000',
      'type': 'INCOME',
      'amount': '1000.00',
      'categoryId': 1,
      'occurredOn': '2026-08-08',
      'description': 'Monthly salary',
    });
    expect(json.containsKey('userId'), isFalse);
    expect(json.containsKey('walletId'), isFalse);
    expect(json.containsKey('balance'), isFalse);
    expect(request.toJsonBody(), contains('"amount":1000.00'));
    expect(request.toJsonBody(), isNot(contains('"amount":"1000.00"')));
  });

  test('update request keeps transaction type out of edit payload', () {
    final UpdateTransactionRequestModel request = UpdateTransactionRequestModel(
      version: 3,
      amount: '120.00',
      categoryId: 5,
      occurredOn: DateTime(2026, 8, 8),
      description: 'Groceries',
    );
    final Map<String, dynamic> json = request.toJson();

    expect(json['version'], 3);
    expect(json['amount'], '120.00');
    expect(json.containsKey('type'), isFalse);
    expect(request.toJsonBody(), contains('"amount":120.00'));
  });
}
