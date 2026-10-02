import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_model.dart';

Map<String, dynamic> _baseJson() => <String, dynamic>{
  'id': 42,
  'version': 0,
  'type': 'EXPENSE',
  'amount': '80.00',
  'description': 'Phone Bill',
  'occurredOn': '2026-08-29',
  'currencyCode': 'USD',
  'status': 'RECORDED',
  'category': <String, dynamic>{
    'id': 4,
    'name': 'Bills',
    'iconKey': 'bills',
  },
};

void main() {
  test('parses paid planned-expense payment protection flag', () {
    final Map<String, dynamic> json = _baseJson()
      ..['plannedExpensePayment'] = true;

    final TransactionModel transaction = TransactionModel.fromJson(json);

    expect(transaction.plannedExpensePayment, isTrue);
  });

  test('defaults protection flag to false for older/manual responses', () {
    final TransactionModel transaction = TransactionModel.fromJson(_baseJson());

    expect(transaction.plannedExpensePayment, isFalse);
  });
}
