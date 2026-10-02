import '../../../transactions/utils/transaction_decimal.dart';

final class BudgetCategoryModel {
  const BudgetCategoryModel({required this.id, required this.name, required this.iconKey});

  final int id;
  final String name;
  final String iconKey;

  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? name = json['name'];
    final Object? iconKey = json['iconKey'];
    if (id is! num || id.toInt() <= 0 || name is! String || name.trim().isEmpty || iconKey is! String || iconKey.trim().isEmpty) {
      throw const FormatException('Invalid budget category');
    }
    return BudgetCategoryModel(id: id.toInt(), name: name.trim(), iconKey: iconKey.trim());
  }
}

final class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.version,
    required this.budgetMonth,
    required this.limitAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
    required this.daysRemaining,
    required this.currencyCode,
    required this.health,
    required this.category,
    this.note,
  });

  final int id;
  final int version;
  final DateTime budgetMonth;
  final String limitAmount;
  final String spentAmount;
  final String remainingAmount;
  final String percentageUsed;
  final int daysRemaining;
  final String currencyCode;
  final String health;
  final String? note;
  final BudgetCategoryModel category;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? version = json['version'];
    final Object? month = json['budgetMonth'];
    final Object? limit = json['limitAmount'];
    final Object? spent = json['spentAmount'];
    final Object? remaining = json['remainingAmount'];
    final Object? percentage = json['percentageUsed'];
    final Object? days = json['daysRemaining'];
    final Object? currency = json['currencyCode'];
    final Object? health = json['health'];
    final Object? note = json['note'];
    final Object? category = json['category'];
    if (id is! num || version is! num || month is! String || limit is! String || spent is! String || remaining is! String || percentage is! String || days is! num || currency is! String || health is! String || (note != null && note is! String) || category is! Map<String, dynamic>) {
      throw const FormatException('Invalid budget response');
    }
    final DateTime? parsed = DateTime.tryParse(month);
    if (id.toInt() <= 0 || version.toInt() < 0 || parsed == null || !TransactionDecimal.isValidPositive(limit) || !_isDecimal(spent) || !_isSignedDecimal(remaining) || !_isSignedDecimal(percentage) || days.toInt() < 0 || currency.trim().length != 3 || health.trim().isEmpty) {
      throw const FormatException('Invalid budget response');
    }
    final String? normalizedNote = (note as String?)?.trim();
    return BudgetModel(
      id: id.toInt(), version: version.toInt(), budgetMonth: DateTime(parsed.year, parsed.month, 1),
      limitAmount: limit, spentAmount: spent, remainingAmount: remaining, percentageUsed: percentage,
      daysRemaining: days.toInt(), currencyCode: currency.trim().toUpperCase(), health: health.trim().toUpperCase(),
      note: normalizedNote == null || normalizedNote.isEmpty ? null : normalizedNote,
      category: BudgetCategoryModel.fromJson(category),
    );
  }

  static bool _isDecimal(String value) => RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(value);
  static bool _isSignedDecimal(String value) => RegExp(r'^-?\d+(?:\.\d{1,2})?$').hasMatch(value);
}
