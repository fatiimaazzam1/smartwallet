import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_type.dart';

void main() {
  test('parses a transaction response', () {
    final TransactionModel transaction = TransactionModel.fromJson(
      <String, dynamic>{
        'id': 42,
        'version': 1,
        'type': 'EXPENSE',
        'amount': 120.00,
        'description': 'Weekly groceries',
        'occurredOn': '2026-08-08',
        'currencyCode': 'usd',
        'status': 'RECORDED',
        'category': <String, dynamic>{
          'id': 5,
          'name': 'Food',
          'iconKey': 'food',
        },
      },
    );

    expect(transaction.id, 42);
    expect(transaction.version, 1);
    expect(transaction.type, TransactionType.expense);
    expect(transaction.amount, '120.0');
    expect(transaction.description, 'Weekly groceries');
    expect(transaction.currencyCode, 'USD');
    expect(transaction.category.name, 'Food');
  });

  test('accepts decimal amount text without converting request data', () {
    final TransactionModel transaction = TransactionModel.fromJson(
      <String, dynamic>{
        'id': 7,
        'version': 0,
        'type': 'INCOME',
        'amount': '99999999999999999.99',
        'description': null,
        'occurredOn': '2026-08-08',
        'currencyCode': 'USD',
        'status': 'RECORDED',
        'category': <String, dynamic>{
          'id': 1,
          'name': 'Salary',
          'iconKey': 'salary',
        },
      },
    );

    expect(transaction.amount, '99999999999999999.99');
  });

  test('rejects unsupported transaction type', () {
    expect(
      () => TransactionModel.fromJson(<String, dynamic>{
        'id': 1,
        'version': 0,
        'type': 'TRANSFER',
        'amount': 10,
        'description': null,
        'occurredOn': '2026-08-08',
        'currencyCode': 'USD',
        'status': 'RECORDED',
        'category': <String, dynamic>{
          'id': 1,
          'name': 'Salary',
          'iconKey': 'salary',
        },
      }),
      throwsFormatException,
    );
  });
}
