import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/dashboard/data/models/dashboard_model.dart';

void main() {
  test('parses real dashboard values without converting money to double', () {
    final DashboardModel model = DashboardModel.fromJson(
      <String, dynamic>{
        'currentBalance': '900.00',
        'safeToSpend': '800.00',
        'outstandingPlannedThroughMonthEnd': '100.00',
        'currencyCode': 'USD',
        'upcomingExpenseCount': 2,
        'upcomingExpenseTotal': '100.00',
        'upcomingExpenses': <dynamic>[],
        'budgetWarning': <String, dynamic>{
          'budgetId': 3,
          'categoryName': 'Food',
          'percentageUsed': '82.50',
          'health': 'WARNING',
        },
      },
    );

    expect(model.currentBalance, '900.00');
    expect(model.safeToSpend, '800.00');
    expect(model.upcomingExpenseCount, 2);
    expect(model.upcomingExpenseTotal, '100.00');
    expect(model.budgetWarning?.percentageUsed, '82.50');
  });
}
