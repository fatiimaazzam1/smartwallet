enum CategoryType {
  income('INCOME'),
  expense('EXPENSE');

  const CategoryType(this.apiValue);

  final String apiValue;

  static CategoryType fromApiValue(String value) {
    return switch (value.trim().toUpperCase()) {
      'INCOME' => CategoryType.income,
      'EXPENSE' => CategoryType.expense,
      _ => throw const FormatException('Unsupported category type'),
    };
  }
}
