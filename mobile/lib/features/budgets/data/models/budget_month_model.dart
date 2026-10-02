import 'budget_model.dart';

final class BudgetMonthModel {
  const BudgetMonthModel({required this.month, required this.totalPlanned, required this.totalSpent, required this.totalRemaining, required this.currencyCode, required this.budgets});

  final DateTime month;
  final String totalPlanned;
  final String totalSpent;
  final String totalRemaining;
  final String currencyCode;
  final List<BudgetModel> budgets;

  factory BudgetMonthModel.fromJson(Map<String, dynamic> json) {
    final Object? month = json['month'];
    final Object? planned = json['totalPlanned'];
    final Object? spent = json['totalSpent'];
    final Object? remaining = json['totalRemaining'];
    final Object? currency = json['currencyCode'];
    final Object? budgets = json['budgets'];
    if (month is! String || planned is! String || spent is! String || remaining is! String || currency is! String || budgets is! List) {
      throw const FormatException('Invalid budget month response');
    }
    final DateTime? parsed = DateTime.tryParse(month);
    if (parsed == null) throw const FormatException('Invalid budget month response');
    return BudgetMonthModel(
      month: DateTime(parsed.year, parsed.month, 1), totalPlanned: planned, totalSpent: spent,
      totalRemaining: remaining, currencyCode: currency.trim().toUpperCase(),
      budgets: budgets.map((dynamic item) {
        if (item is! Map<String, dynamic>) throw const FormatException('Invalid budget response');
        return BudgetModel.fromJson(item);
      }).toList(growable: false),
    );
  }
}
