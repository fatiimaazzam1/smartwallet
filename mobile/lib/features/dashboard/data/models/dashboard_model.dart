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
    if (id is! num ||
        id.toInt() <= 0 ||
        name is! String ||
        name.trim().isEmpty ||
        percent is! String ||
        health is! String ||
        health.trim().isEmpty) {
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

final class DashboardTopSpendingCategoryModel {
  const DashboardTopSpendingCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.amount,
  });

  final int categoryId;
  final String categoryName;
  final String iconKey;
  final String amount;

  factory DashboardTopSpendingCategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final Object? id = json['categoryId'];
    final Object? name = json['categoryName'];
    final Object? icon = json['iconKey'];
    final Object? amount = json['amount'];
    if (id is! num ||
        id.toInt() <= 0 ||
        name is! String ||
        name.trim().isEmpty ||
        icon is! String ||
        icon.trim().isEmpty ||
        amount is! String) {
      throw const FormatException('Invalid top spending category');
    }
    return DashboardTopSpendingCategoryModel(
      categoryId: id.toInt(),
      categoryName: name.trim(),
      iconKey: icon.trim(),
      amount: amount,
    );
  }
}

final class DashboardBudgetPerformanceModel {
  const DashboardBudgetPerformanceModel({
    required this.safeCount,
    required this.warningCount,
    required this.limitReachedCount,
  });

  final int safeCount;
  final int warningCount;
  final int limitReachedCount;

  int get totalCount => safeCount + warningCount + limitReachedCount;

  factory DashboardBudgetPerformanceModel.fromJson(Map<String, dynamic> json) {
    final Object? safe = json['safeCount'];
    final Object? warning = json['warningCount'];
    final Object? reached = json['limitReachedCount'];
    if (safe is! num ||
        warning is! num ||
        reached is! num ||
        safe.toInt() < 0 ||
        warning.toInt() < 0 ||
        reached.toInt() < 0) {
      throw const FormatException('Invalid budget performance');
    }
    return DashboardBudgetPerformanceModel(
      safeCount: safe.toInt(),
      warningCount: warning.toInt(),
      limitReachedCount: reached.toInt(),
    );
  }
}

final class DashboardWeeklyInsightsModel {
  const DashboardWeeklyInsightsModel({
    required this.weekStart,
    required this.throughDate,
    required this.currentWeekSpending,
    required this.previousComparableSpending,
    required this.comparisonAvailable,
    required this.comparisonDirection,
    required this.comparisonPercentage,
    required this.topSpendingCategory,
    required this.budgetPerformance,
    required this.upcomingFourteenDayCount,
    required this.upcomingFourteenDayTotal,
  });

  final DateTime weekStart;
  final DateTime throughDate;
  final String currentWeekSpending;
  final String previousComparableSpending;
  final bool comparisonAvailable;
  final String? comparisonDirection;
  final String? comparisonPercentage;
  final DashboardTopSpendingCategoryModel? topSpendingCategory;
  final DashboardBudgetPerformanceModel budgetPerformance;
  final int upcomingFourteenDayCount;
  final String upcomingFourteenDayTotal;

  factory DashboardWeeklyInsightsModel.fromJson(Map<String, dynamic> json) {
    final Object? rawWeekStart = json['weekStart'];
    final Object? rawThroughDate = json['throughDate'];
    final Object? current = json['currentWeekSpending'];
    final Object? previous = json['previousComparableSpending'];
    final Object? available = json['comparisonAvailable'];
    final Object? direction = json['comparisonDirection'];
    final Object? percentage = json['comparisonPercentage'];
    final Object? topCategory = json['topSpendingCategory'];
    final Object? budgetPerformance = json['budgetPerformance'];
    final Object? upcomingCount = json['upcomingFourteenDayCount'];
    final Object? upcomingTotal = json['upcomingFourteenDayTotal'];

    final DateTime? weekStart = rawWeekStart is String
        ? DateTime.tryParse(rawWeekStart)
        : null;
    final DateTime? throughDate = rawThroughDate is String
        ? DateTime.tryParse(rawThroughDate)
        : null;
    final String? normalizedDirection = direction is String
        ? direction.trim().toUpperCase()
        : null;

    if (weekStart == null ||
        throughDate == null ||
        throughDate.isBefore(weekStart) ||
        current is! String ||
        previous is! String ||
        available is! bool ||
        (direction != null && direction is! String) ||
        (percentage != null && percentage is! String) ||
        (topCategory != null && topCategory is! Map<String, dynamic>) ||
        budgetPerformance is! Map<String, dynamic> ||
        upcomingCount is! num ||
        upcomingCount.toInt() < 0 ||
        upcomingTotal is! String) {
      throw const FormatException('Invalid weekly insights');
    }

    if (available) {
      if (!const <String>{
            'INCREASED',
            'DECREASED',
            'UNCHANGED',
          }.contains(normalizedDirection) ||
          percentage is! String) {
        throw const FormatException('Invalid weekly comparison');
      }
    } else if (direction != null || percentage != null) {
      throw const FormatException('Unavailable comparison must be neutral');
    }

    return DashboardWeeklyInsightsModel(
      weekStart: DateTime(weekStart.year, weekStart.month, weekStart.day),
      throughDate: DateTime(
        throughDate.year,
        throughDate.month,
        throughDate.day,
      ),
      currentWeekSpending: current,
      previousComparableSpending: previous,
      comparisonAvailable: available,
      comparisonDirection: normalizedDirection,
      comparisonPercentage: percentage as String?,
      topSpendingCategory: topCategory is Map<String, dynamic>
          ? DashboardTopSpendingCategoryModel.fromJson(topCategory)
          : null,
      budgetPerformance: DashboardBudgetPerformanceModel.fromJson(
        budgetPerformance,
      ),
      upcomingFourteenDayCount: upcomingCount.toInt(),
      upcomingFourteenDayTotal: upcomingTotal,
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
    required this.weeklyInsights,
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
  final DashboardWeeklyInsightsModel weeklyInsights;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final Object? balance = json['currentBalance'];
    final Object? safe = json['safeToSpend'];
    final Object? out = json['outstandingPlannedThroughMonthEnd'];
    final Object? currency = json['currencyCode'];
    final Object? count = json['upcomingExpenseCount'];
    final Object? total = json['upcomingExpenseTotal'];
    final Object? up = json['upcomingExpenses'];
    final Object? warning = json['budgetWarning'];
    final Object? weekly = json['weeklyInsights'];
    if (balance is! String ||
        safe is! String ||
        out is! String ||
        currency is! String ||
        currency.trim().isEmpty ||
        count is! num ||
        count.toInt() < 0 ||
        total is! String ||
        up is! List ||
        (warning != null && warning is! Map<String, dynamic>) ||
        weekly is! Map<String, dynamic>) {
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
      weeklyInsights: DashboardWeeklyInsightsModel.fromJson(weekly),
    );
  }
}
