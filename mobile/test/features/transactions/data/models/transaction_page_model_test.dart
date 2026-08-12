import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_page_model.dart';

void main() {
  test('parses transaction pagination metadata', () {
    final TransactionPageModel page = TransactionPageModel.fromJson(
      <String, dynamic>{
        'content': <dynamic>[
          <String, dynamic>{
            'id': 2,
            'version': 0,
            'type': 'INCOME',
            'amount': 1000,
            'description': 'Monthly salary',
            'occurredOn': '2026-08-08',
            'currencyCode': 'USD',
            'status': 'RECORDED',
            'category': <String, dynamic>{
              'id': 1,
              'name': 'Salary',
              'iconKey': 'salary',
            },
          },
        ],
        'page': 0,
        'size': 20,
        'totalElements': 21,
        'totalPages': 2,
        'first': true,
        'last': false,
      },
    );

    expect(page.content, hasLength(1));
    expect(page.page, 0);
    expect(page.totalElements, 21);
    expect(page.last, isFalse);
  });
}
