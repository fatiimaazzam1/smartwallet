import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/profile/data/models/user_preferences_model.dart';
import 'package:smartwallet_mobile/features/transactions/utils/transaction_formatters.dart';
import 'package:smartwallet_mobile/features/transactions/utils/transaction_request_id.dart';

void main() {
  test('formats backend date without timezone conversion', () {
    final DateTime date = DateTime(2026, 8, 12);

    expect(TransactionFormatters.toApiDate(date), '2026-08-12');
    expect(
      TransactionFormatters.formatDate(
        date,
        DateFormatPreference.dayMonthYear,
      ),
      '12/08/2026',
    );
    expect(
      TransactionFormatters.formatDate(
        date,
        DateFormatPreference.monthDayYear,
      ),
      '08/12/2026',
    );
    expect(
      TransactionFormatters.formatDate(
        date,
        DateFormatPreference.yearMonthDay,
      ),
      '2026-08-12',
    );
  });

  test('generated client request id is an RFC-style UUID v4', () {
    final String id = TransactionRequestId.generate();

    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}
