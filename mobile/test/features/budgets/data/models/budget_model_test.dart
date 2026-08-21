import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/budgets/data/models/budget_month_model.dart';

void main() {
  test('parses exact budget decimal strings and month summary', () {
    final BudgetMonthModel model = BudgetMonthModel.fromJson(
      <String, dynamic>{
        'month': '2026-08-01',
        'totalPlanned': '1000.00',
        'totalSpent': '250.50',
        'totalRemaining': '749.50',
        'currencyCode': 'usd',
        'budgets': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 4,
            'version': 1,
            'budgetMonth': '2026-08-01',
            'limitAmount': '500.00',
            'spentAmount': '250.50',
            'remainingAmount': '249.50',
            'percentageUsed': '50.10',
            'daysRemaining': 10,
            'currencyCode': 'USD',
            'health': 'SAFE',
            'note': null,
            'category': <String, dynamic>{
              'id': 7,
              'name': 'Food',
              'iconKey': 'food',
            },
          },
        ],
      },
    );

    expect(model.currencyCode, 'USD');
    expect(model.totalPlanned, '1000.00');
    expect(model.budgets.single.limitAmount, '500.00');
    expect(model.budgets.single.category.name, 'Food');
  });
}
