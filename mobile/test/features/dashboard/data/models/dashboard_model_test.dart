import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/dashboard/data/models/dashboard_model.dart';

void main() {
  test('parses dashboard and weekly insights without converting money to double', () {
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
        'weeklyInsights': <String, dynamic>{
          'weekStart': '2026-08-24',
          'throughDate': '2026-08-29',
          'currentWeekSpending': '125.50',
          'previousComparableSpending': '100.00',
          'comparisonAvailable': true,
          'comparisonDirection': 'INCREASED',
          'comparisonPercentage': '25.50',
          'topSpendingCategory': <String, dynamic>{
            'categoryId': 5,
            'categoryName': 'Food',
            'iconKey': 'restaurant',
            'amount': '80.00',
          },
          'budgetPerformance': <String, dynamic>{
            'safeCount': 2,
            'warningCount': 1,
            'limitReachedCount': 0,
          },
          'upcomingFourteenDayCount': 2,
          'upcomingFourteenDayTotal': '130.00',
        },
      },
    );

    expect(model.currentBalance, '900.00');
    expect(model.safeToSpend, '800.00');
    expect(model.upcomingExpenseCount, 2);
    expect(model.upcomingExpenseTotal, '100.00');
    expect(model.budgetWarning?.percentageUsed, '82.50');
    expect(model.weeklyInsights.currentWeekSpending, '125.50');
    expect(model.weeklyInsights.comparisonPercentage, '25.50');
    expect(model.weeklyInsights.topSpendingCategory?.amount, '80.00');
    expect(model.weeklyInsights.budgetPerformance.totalCount, 3);
    expect(model.weeklyInsights.upcomingFourteenDayTotal, '130.00');
  });

  test('accepts a neutral weekly comparison when previous spending is unavailable', () {
    final DashboardWeeklyInsightsModel insights =
        DashboardWeeklyInsightsModel.fromJson(<String, dynamic>{
          'weekStart': '2026-08-24',
          'throughDate': '2026-08-29',
          'currentWeekSpending': '0.00',
          'previousComparableSpending': '0.00',
          'comparisonAvailable': false,
          'comparisonDirection': null,
          'comparisonPercentage': null,
          'topSpendingCategory': null,
          'budgetPerformance': <String, dynamic>{
            'safeCount': 0,
            'warningCount': 0,
            'limitReachedCount': 0,
          },
          'upcomingFourteenDayCount': 0,
          'upcomingFourteenDayTotal': '0.00',
        });

    expect(insights.comparisonAvailable, isFalse);
    expect(insights.comparisonDirection, isNull);
    expect(insights.comparisonPercentage, isNull);
    expect(insights.topSpendingCategory, isNull);
  });
}
