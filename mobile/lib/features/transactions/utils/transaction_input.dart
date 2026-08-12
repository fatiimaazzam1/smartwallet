import 'package:flutter/services.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import 'transaction_decimal.dart';

abstract final class TransactionInput {
  TransactionInput._();

  static final RegExp _unsupportedDescriptionCharacters = RegExp(
    r'[\x00-\x1F\x7F\u200B\u200C\u200D\u200E\u200F\u202A-\u202E\u2060-\u206F\uFEFF]',
  );

  static String? validateAmount(String? value, AppLocalizations l10n) {
    final String normalized = (value ?? '').trim();
    if (normalized.isEmpty) {
      return l10n.transactionAmountRequired;
    }
    if (!RegExp(r'^\d{1,17}(?:\.\d{1,2})?$').hasMatch(normalized)) {
      return l10n.transactionAmountInvalid;
    }
    if (!TransactionDecimal.isValidPositive(normalized)) {
      return l10n.transactionAmountMustBePositive;
    }
    return null;
  }

  static String? validateDescription(String? value, AppLocalizations l10n) {
    final String description = value ?? '';
    if (description.length > 255) {
      return l10n.transactionDescriptionTooLong;
    }
    if (_unsupportedDescriptionCharacters.hasMatch(description)) {
      return l10n.transactionDescriptionUnsupported;
    }
    return null;
  }
}

final class FinancialAmountInputFormatter extends TextInputFormatter {
  const FinancialAmountInputFormatter();

  static final RegExp _validPattern = RegExp(r'^\d{0,17}(?:\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String normalized = _normalize(newValue.text);

    if (!_validPattern.hasMatch(normalized)) {
      return oldValue;
    }

    final int baseOffset = newValue.selection.baseOffset
        .clamp(0, normalized.length)
        .toInt();
    final int extentOffset = newValue.selection.extentOffset
        .clamp(0, normalized.length)
        .toInt();

    return TextEditingValue(
      text: normalized,
      selection: TextSelection(
        baseOffset: baseOffset,
        extentOffset: extentOffset,
      ),
      composing: TextRange.empty,
    );
  }

  static String _normalize(String value) {
    final StringBuffer buffer = StringBuffer();

    for (final int rune in value.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x30 + rune - 0x0660);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(0x30 + rune - 0x06F0);
      } else if (rune == 0x066B) {
        buffer.write('.');
      } else {
        buffer.writeCharCode(rune);
      }
    }

    return buffer.toString();
  }
}
