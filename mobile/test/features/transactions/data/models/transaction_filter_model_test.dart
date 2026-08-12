import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/categories/data/models/category_model.dart';
import 'package:smartwallet_mobile/features/categories/data/models/category_type.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_filter_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_type.dart';

void main() {
  const CategoryModel food = CategoryModel(
    id: 5,
    name: 'Food',
    type: CategoryType.expense,
    iconKey: 'food',
    isSystem: true,
  );

  test('counts only applied filters', () {
    final TransactionFilterModel filter = TransactionFilterModel(
      type: TransactionType.expense,
      category: food,
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 12),
    );

    expect(filter.activeCount, 4);
    expect(filter.isEmpty, isFalse);
  });

  test('filter equality compares category identity and date-only values', () {
    final TransactionFilterModel first = TransactionFilterModel(
      category: food,
      startDate: DateTime(2026, 8, 1, 2),
    );
    final TransactionFilterModel second = TransactionFilterModel(
      category: food,
      startDate: DateTime(2026, 8, 1, 18),
    );

    expect(first.sameAs(second), isTrue);
    expect(TransactionFilterModel.empty.isEmpty, isTrue);
  });
}
