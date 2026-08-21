final class BudgetRelatedExpenseModel {
  const BudgetRelatedExpenseModel({
    required this.id,
    required this.amount,
    required this.occurredOn,
    this.description,
  });

  final int id;
  final String amount;
  final DateTime occurredOn;
  final String? description;

  factory BudgetRelatedExpenseModel.fromJson(Map<String, dynamic> json) {
    final Object? rawId = json['id'];
    final Object? rawAmount = json['amount'];
    final Object? rawDate = json['occurredOn'];
    final Object? rawDescription = json['description'];
    if (rawId is! num || rawAmount is! String || rawDate is! String) {
      throw const FormatException('Invalid budget related expense response');
    }
    final DateTime? parsed = DateTime.tryParse(rawDate);
    if (parsed == null) {
      throw const FormatException('Invalid budget related expense date');
    }
    final String? description = rawDescription is String && rawDescription.trim().isNotEmpty
        ? rawDescription.trim()
        : null;
    return BudgetRelatedExpenseModel(
      id: rawId.toInt(),
      amount: rawAmount,
      occurredOn: DateTime(parsed.year, parsed.month, parsed.day),
      description: description,
    );
  }
}
