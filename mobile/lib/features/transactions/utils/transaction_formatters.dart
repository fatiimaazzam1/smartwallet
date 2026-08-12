import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../profile/data/models/user_preferences_model.dart';
import '../data/models/transaction_type.dart';

abstract final class TransactionFormatters {
  TransactionFormatters._();

  static String toApiDate(DateTime value) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String formatDate(
    DateTime value,
    DateFormatPreference preference,
  ) {
    final String year = value.year.toString().padLeft(4, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');

    return switch (preference) {
      DateFormatPreference.dayMonthYear => '$day/$month/$year',
      DateFormatPreference.monthDayYear => '$month/$day/$year',
      DateFormatPreference.yearMonthDay => '$year-$month-$day',
    };
  }

  static String formatCurrencyAmount({
    required BuildContext context,
    required String currencyCode,
    required String amount,
  }) {
    final String locale = Localizations.localeOf(context).toLanguageTag();
    final String normalized = amount.trim();
    final List<String> parts = normalized.split('.');
    final String integerText = parts.first.isEmpty ? '0' : parts.first;
    final String fractionText = parts.length > 1
        ? parts[1].padRight(2, '0').substring(0, 2)
        : '00';
    final int integerValue = int.tryParse(integerText) ?? 0;

    final NumberFormat groupedInteger = NumberFormat.decimalPattern(locale);
    final NumberFormat fractionFormat = NumberFormat('0.00', locale);
    final NumberFormat singleDigit = NumberFormat('0', locale);
    final String localizedZero = singleDigit.format(0);
    final String localizedFractionSample = fractionFormat.format(
      int.parse(fractionText) / 100,
    );
    final String fractionSuffix = localizedFractionSample.startsWith(localizedZero)
        ? localizedFractionSample.substring(localizedZero.length)
        : '.$fractionText';
    final String exactNumber =
        '${groupedInteger.format(integerValue)}$fractionSuffix';

    final NumberFormat currency = NumberFormat.simpleCurrency(
      locale: locale,
      name: currencyCode,
      decimalDigits: 2,
    );
    final NumberFormat numericTemplateFormat = NumberFormat('#,##0.00', locale);
    final String numericTemplate = numericTemplateFormat.format(1234.56);
    final String currencyTemplate = currency.format(1234.56);

    if (currencyTemplate.contains(numericTemplate)) {
      return currencyTemplate.replaceFirst(numericTemplate, exactNumber);
    }

    return '$currencyCode $exactNumber';
  }

  static String formatSignedCurrencyAmount({
    required BuildContext context,
    required String currencyCode,
    required String amount,
    required TransactionType type,
  }) {
    final String formatted = formatCurrencyAmount(
      context: context,
      currencyCode: currencyCode,
      amount: amount,
    );
    return type == TransactionType.income ? '+$formatted' : '-$formatted';
  }

  static String currencySymbol(BuildContext context, String currencyCode) {
    return NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      name: currencyCode,
      decimalDigits: 2,
    ).currencySymbol;
  }

  static String normalizeDescription(String value) {
    final String normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return normalized;
  }

  static String amountForEditing(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    final int dotIndex = normalized.indexOf('.');
    if (dotIndex < 0) {
      return '$normalized.00';
    }

    final int fractionLength = normalized.length - dotIndex - 1;
    if (fractionLength == 0) {
      return '${normalized}00';
    }
    if (fractionLength == 1) {
      return '${normalized}0';
    }
    return normalized;
  }
}
