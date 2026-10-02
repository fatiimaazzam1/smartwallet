import '../../../transactions/utils/transaction_decimal.dart';

final class PlannedExpenseCategoryModel {
  const PlannedExpenseCategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  final int id;
  final String name;
  final String iconKey;

  factory PlannedExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? name = json['name'];
    final Object? icon = json['iconKey'];
    if (id is! num ||
        id.toInt() <= 0 ||
        name is! String ||
        name.trim().isEmpty ||
        icon is! String ||
        icon.trim().isEmpty) {
      throw const FormatException('Invalid planned expense category');
    }
    return PlannedExpenseCategoryModel(
      id: id.toInt(),
      name: name.trim(),
      iconKey: icon.trim(),
    );
  }
}

enum PlannedExpenseStatus {
  upcoming('UPCOMING'),
  paid('PAID'),
  cancelled('CANCELLED');

  const PlannedExpenseStatus(this.apiValue);
  final String apiValue;

  static PlannedExpenseStatus fromApi(String value) => values.firstWhere(
    (PlannedExpenseStatus item) => item.apiValue == value.toUpperCase(),
    orElse: () => throw const FormatException('Invalid planned expense status'),
  );
}

enum PlannedExpenseRecurrence {
  none('NONE'),
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  yearly('YEARLY');

  const PlannedExpenseRecurrence(this.apiValue);
  final String apiValue;

  static PlannedExpenseRecurrence fromApi(String value) => values.firstWhere(
    (PlannedExpenseRecurrence item) => item.apiValue == value.toUpperCase(),
    orElse: () => throw const FormatException('Invalid recurrence'),
  );
}

final class PlannedExpenseModel {
  const PlannedExpenseModel({
    required this.id,
    required this.version,
    required this.title,
    required this.amount,
    required this.dueOn,
    required this.recurrence,
    required this.status,
    required this.currencyCode,
    required this.category,
    this.note,
    this.paidOn,
    this.transactionId,
  });

  final int id;
  final int version;
  final String title;
  final String amount;
  final DateTime dueOn;
  final PlannedExpenseRecurrence recurrence;
  final PlannedExpenseStatus status;
  final String currencyCode;
  final PlannedExpenseCategoryModel category;
  final String? note;
  final DateTime? paidOn;
  final int? transactionId;

  factory PlannedExpenseModel.fromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? version = json['version'];
    final Object? title = json['title'];
    final Object? amount = json['amount'];
    final Object? due = json['dueOn'];
    final Object? recurrence = json['recurrence'];
    final Object? status = json['status'];
    final Object? currency = json['currencyCode'];
    final Object? category = json['category'];
    final Object? note = json['note'];
    final Object? paid = json['paidOn'];
    final Object? tx = json['transactionId'];

    if (id is! num ||
        version is! num ||
        title is! String ||
        amount is! String ||
        due is! String ||
        recurrence is! String ||
        status is! String ||
        currency is! String ||
        category is! Map<String, dynamic> ||
        (note != null && note is! String) ||
        (paid != null && paid is! String) ||
        (tx != null && tx is! num)) {
      throw const FormatException('Invalid planned expense response');
    }

    final DateTime? parsedDue = DateTime.tryParse(due);
    final DateTime? parsedPaid = paid is String ? DateTime.tryParse(paid) : null;
    if (id.toInt() <= 0 ||
        version.toInt() < 0 ||
        title.trim().isEmpty ||
        !TransactionDecimal.isValidPositive(amount) ||
        parsedDue == null ||
        (paid != null && parsedPaid == null) ||
        currency.trim().length != 3) {
      throw const FormatException('Invalid planned expense response');
    }

    final String? normalizedNote = (note as String?)?.trim();
    return PlannedExpenseModel(
      id: id.toInt(),
      version: version.toInt(),
      title: title.trim(),
      amount: amount,
      dueOn: DateTime(parsedDue.year, parsedDue.month, parsedDue.day),
      recurrence: PlannedExpenseRecurrence.fromApi(recurrence),
      status: PlannedExpenseStatus.fromApi(status),
      currencyCode: currency.trim().toUpperCase(),
      category: PlannedExpenseCategoryModel.fromJson(category),
      note: normalizedNote == null || normalizedNote.isEmpty
          ? null
          : normalizedNote,
      paidOn: parsedPaid == null
          ? null
          : DateTime(parsedPaid.year, parsedPaid.month, parsedPaid.day),
      transactionId: tx is num ? tx.toInt() : null,
    );
  }
}

final class PlannedExpensePageModel {
  const PlannedExpensePageModel({
    required this.content,
    required this.page,
    required this.last,
    required this.totalElements,
    required this.totalAmount,
  });

  final List<PlannedExpenseModel> content;
  final int page;
  final bool last;
  final int totalElements;
  final String totalAmount;

  factory PlannedExpensePageModel.fromJson(Map<String, dynamic> json) {
    final Object? content = json['content'];
    final Object? page = json['page'];
    final Object? last = json['last'];
    final Object? totalElements = json['totalElements'];
    final Object? totalAmount = json['totalAmount'];

    if (content is! List ||
        page is! num ||
        last is! bool ||
        totalElements is! num ||
        totalAmount is! String ||
        totalElements.toInt() < 0 ||
        !TransactionDecimal.isValidNonNegative(totalAmount)) {
      throw const FormatException('Invalid planned expense page');
    }

    return PlannedExpensePageModel(
      content: content.map((dynamic item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid planned expense');
        }
        return PlannedExpenseModel.fromJson(item);
      }).toList(growable: false),
      page: page.toInt(),
      last: last,
      totalElements: totalElements.toInt(),
      totalAmount: totalAmount,
    );
  }
}
