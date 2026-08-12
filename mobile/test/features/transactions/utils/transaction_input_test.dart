import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/transactions/utils/transaction_input.dart';

void main() {
  test('normalizes Arabic digits and Arabic decimal separator safely', () {
    const FinancialAmountInputFormatter formatter =
        FinancialAmountInputFormatter();

    final TextEditingValue result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '\u0661\u0662\u0663\u066B\u0664\u0665',
        selection: TextSelection.collapsed(offset: 6),
      ),
    );

    expect(result.text, '123.45');
  });

  test('rejects an ambiguous ASCII comma instead of changing its value', () {
    const FinancialAmountInputFormatter formatter =
        FinancialAmountInputFormatter();
    const TextEditingValue oldValue = TextEditingValue(
      text: '1',
      selection: TextSelection.collapsed(offset: 1),
    );

    final TextEditingValue result = formatter.formatEditUpdate(
      oldValue,
      const TextEditingValue(
        text: '1,000',
        selection: TextSelection.collapsed(offset: 5),
      ),
    );

    expect(result, oldValue);
  });
}
