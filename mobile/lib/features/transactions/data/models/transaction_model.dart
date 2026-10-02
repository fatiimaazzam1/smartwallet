import '../../utils/transaction_decimal.dart';
import 'transaction_category_model.dart';
import 'transaction_type.dart';

final class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.version,
    required this.type,
    required this.amount,
    required this.occurredOn,
    required this.currencyCode,
    required this.status,
    required this.category,
    this.description,
    this.plannedExpensePayment = false,
  });

  final int id;
  final int version;
  final TransactionType type;

  /// Decimal text received from the backend. Keeping the lexical value avoids
  /// unnecessary floating-point round trips when it is reused in edit forms.
  final String amount;
  final String? description;
  final DateTime occurredOn;
  final String currencyCode;
  final String status;
  final TransactionCategoryModel category;
  final bool plannedExpensePayment;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final Object? rawId = json['id'];
    final Object? rawVersion = json['version'];
    final Object? rawType = json['type'];
    final Object? rawAmount = json['amount'];
    final Object? rawDescription = json['description'];
    final Object? rawOccurredOn = json['occurredOn'];
    final Object? rawCurrencyCode = json['currencyCode'];
    final Object? rawStatus = json['status'];
    final Object? rawCategory = json['category'];
    final Object? rawPlannedExpensePayment = json['plannedExpensePayment'];

    if (rawId is! num ||
        rawVersion is! num ||
        rawType is! String ||
        (rawAmount is! num && rawAmount is! String) ||
        (rawDescription != null && rawDescription is! String) ||
        rawOccurredOn is! String ||
        rawCurrencyCode is! String ||
        rawStatus is! String ||
        rawCategory is! Map<String, dynamic> ||
        (rawPlannedExpensePayment != null &&
            rawPlannedExpensePayment is! bool)) {
      throw const FormatException('Invalid transaction response');
    }

    final int id = rawId.toInt();
    final int version = rawVersion.toInt();
    final String amount = rawAmount.toString().trim();
    final bool validAmount = TransactionDecimal.isValidPositive(amount);
    final DateTime? parsedDate = DateTime.tryParse(rawOccurredOn);
    final String currencyCode = rawCurrencyCode.trim().toUpperCase();
    final String status = rawStatus.trim().toUpperCase();
    final String? normalizedDescription = (rawDescription as String?)?.trim();
    final String? description =
        normalizedDescription == null || normalizedDescription.isEmpty
        ? null
        : normalizedDescription;

    if (id <= 0 ||
        version < 0 ||
        !validAmount ||
        parsedDate == null ||
        currencyCode.length != 3 ||
        status.isEmpty) {
      throw const FormatException('Invalid transaction response');
    }

    final DateTime occurredOn = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );

    return TransactionModel(
      id: id,
      version: version,
      type: TransactionType.fromApiValue(rawType),
      amount: amount,
      description: description,
      occurredOn: occurredOn,
      currencyCode: currencyCode,
      status: status,
      category: TransactionCategoryModel.fromJson(rawCategory),
      plannedExpensePayment: rawPlannedExpensePayment as bool? ?? false,
    );
  }
}
