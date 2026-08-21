import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/planned_expenses/data/models/planned_expense_model.dart';

void main() {
  test('parses a paid planned expense and linked transaction safely', () {
    final PlannedExpenseModel model = PlannedExpenseModel.fromJson(
      <String, dynamic>{
        'id': 9,
        'version': 2,
        'title': 'Internet bill',
        'amount': '45.90',
        'dueOn': '2026-08-20',
        'recurrence': 'MONTHLY',
        'status': 'PAID',
        'note': 'Home internet',
        'paidOn': '2026-08-20',
        'transactionId': 44,
        'currencyCode': 'usd',
        'category': <String, dynamic>{
          'id': 5,
          'name': 'Bills',
          'iconKey': 'bills',
        },
      },
    );

    expect(model.amount, '45.90');
    expect(model.status, PlannedExpenseStatus.paid);
    expect(model.recurrence, PlannedExpenseRecurrence.monthly);
    expect(model.transactionId, 44);
    expect(model.currencyCode, 'USD');
  });

  test('rejects a non-positive planned amount', () {
    expect(
      () => PlannedExpenseModel.fromJson(<String, dynamic>{
        'id': 1,
        'version': 0,
        'title': 'Bad plan',
        'amount': '0.00',
        'dueOn': '2026-08-20',
        'recurrence': 'NONE',
        'status': 'UPCOMING',
        'note': null,
        'paidOn': null,
        'transactionId': null,
        'currencyCode': 'USD',
        'category': <String, dynamic>{
          'id': 5,
          'name': 'Bills',
          'iconKey': 'bills',
        },
      }),
      throwsFormatException,
    );
  });

  test('parses planned expense page summary safely', () {
    final PlannedExpensePageModel page = PlannedExpensePageModel.fromJson(
      <String, dynamic>{
        'content': <dynamic>[],
        'page': 0,
        'size': 20,
        'totalElements': 3,
        'totalPages': 1,
        'last': true,
        'totalAmount': '320.00',
      },
    );

    expect(page.totalElements, 3);
    expect(page.totalAmount, '320.00');
  });
}
