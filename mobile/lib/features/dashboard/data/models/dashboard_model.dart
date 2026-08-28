import '../../../planned_expenses/data/models/planned_expense_model.dart';

final class DashboardBudgetWarningModel {
  const DashboardBudgetWarningModel({
    required this.budgetId,
    required this.categoryName,
    required this.percentageUsed,
    required this.health,
  });

  final int budgetId;
  final String categoryName;
  final String percentageUsed;
  final String health;

  factory DashboardBudgetWarningModel.fromJson(Map<String, dynamic> json) {
    final Object? id = json['budgetId'];
    final Object? name = json['categoryName'];
    final Object? percent = json['percentageUsed'];
    final Object? health = json['health'];
    if (id is! num || name is! String || percent is! String || health is! String) {
      throw const FormatException('Invalid warning');
    }
    return DashboardBudgetWarningModel(
      budgetId: id.toInt(),
      categoryName: name.trim(),
      percentageUsed: percent,
      health: health.trim().toUpperCase(),
    );
  }
}

final class DashboardModel {
  const DashboardModel({
    required this.currentBalance,
    required this.safeToSpend,
    required this.outstandingPlannedThroughMonthEnd,
    required this.currencyCode,
    required this.upcomingExpenseCount,
    required this.upcomingExpenseTotal,
    required this.upcomingExpenses,
    this.budgetWarning,
  });

  final String currentBalance;
  final String safeToSpend;
  final String outstandingPlannedThroughMonthEnd;
  final String currencyCode;
  final int upcomingExpenseCount;
  final String upcomingExpenseTotal;
  final List<PlannedExpenseModel> upcomingExpenses;
  final DashboardBudgetWarningModel? budgetWarning;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final Object? balance = json['currentBalance'];
    final Object? safe = json['safeToSpend'];
    final Object? out = json['outstandingPlannedThroughMonthEnd'];
    final Object? currency = json['currencyCode'];
    final Object? count = json['upcomingExpenseCount'];
    final Object? total = json['upcomingExpenseTotal'];
    final Object? up = json['upcomingExpenses'];
    final Object? warning = json['budgetWarning'];
    if (balance is! String ||
        safe is! String ||
        out is! String ||
        currency is! String ||
        count is! num ||
        count.toInt() < 0 ||
        total is! String ||
        up is! List ||
        (warning != null && warning is! Map<String, dynamic>)) {
      throw const FormatException('Invalid dashboard');
    }
    return DashboardModel(
      currentBalance: balance,
      safeToSpend: safe,
      outstandingPlannedThroughMonthEnd: out,
      currencyCode: currency.trim().toUpperCase(),
      upcomingExpenseCount: count.toInt(),
      upcomingExpenseTotal: total,
      upcomingExpenses: up.map((dynamic item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid planned expense');
        }
        return PlannedExpenseModel.fromJson(item);
      }).toList(growable: false),
      budgetWarning: warning is Map<String, dynamic>
          ? DashboardBudgetWarningModel.fromJson(warning)
          : null,
    );
  }
}
