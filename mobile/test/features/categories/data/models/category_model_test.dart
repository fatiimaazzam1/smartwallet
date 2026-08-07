import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/categories/data/models/category_model.dart';
import 'package:smartwallet_mobile/features/categories/data/models/category_type.dart';

void main() {
  test('parses a category response', () {
    final CategoryModel category = CategoryModel.fromJson(
      <String, dynamic>{
        'id': 13,
        'name': 'Pet Care',
        'type': 'EXPENSE',
        'iconKey': 'custom',
        'system': false,
      },
    );

    expect(category.id, 13);
    expect(category.name, 'Pet Care');
    expect(category.type, CategoryType.expense);
    expect(category.isCustom, isTrue);
  });

  test('rejects an unsupported category type', () {
    expect(
      () => CategoryModel.fromJson(<String, dynamic>{
        'id': 1,
        'name': 'Invalid',
        'type': 'SAVING',
        'iconKey': 'custom',
        'system': false,
      }),
      throwsFormatException,
    );
  });
  test('marks only the system Other category as retired', () {
    final CategoryModel systemOther = CategoryModel.fromJson(
      <String, dynamic>{
        'id': 4,
        'name': 'Other',
        'type': 'INCOME',
        'iconKey': 'other',
        'system': true,
      },
    );
    final CategoryModel customOther = CategoryModel.fromJson(
      <String, dynamic>{
        'id': 20,
        'name': 'Other',
        'type': 'EXPENSE',
        'iconKey': 'custom',
        'system': false,
      },
    );

    expect(systemOther.isRetiredSystemDefault, isTrue);
    expect(customOther.isRetiredSystemDefault, isFalse);
  });

}
