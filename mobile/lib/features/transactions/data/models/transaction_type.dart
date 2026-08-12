import '../../../categories/data/models/category_type.dart';

enum TransactionType {
  income('INCOME'),
  expense('EXPENSE');

  const TransactionType(this.apiValue);

  final String apiValue;

  CategoryType get categoryType => switch (this) {
    TransactionType.income => CategoryType.income,
    TransactionType.expense => CategoryType.expense,
  };

  static TransactionType fromApiValue(String value) {
    return switch (value.trim().toUpperCase()) {
      'INCOME' => TransactionType.income,
      'EXPENSE' => TransactionType.expense,
      _ => throw const FormatException('Unsupported transaction type'),
    };
  }
}
