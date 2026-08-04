import 'package:smartwallet_mobile/l10n/l10n.dart';

abstract final class FormValidators {
  FormValidators._();

  static String? requiredField(
    String? value, {
    required String fieldName,
    required AppLocalizations l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n.requiredField(fieldName);
    }

    return null;
  }

  static String? name(
    String? value, {
    required String fieldName,
    required AppLocalizations l10n,
  }) {
    final String? requiredError = requiredField(
      value,
      fieldName: fieldName,
      l10n: l10n,
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.trim().length < 2) {
      return l10n.minimumCharacters(fieldName, 2);
    }

    return null;
  }

  static String? email(String? value, AppLocalizations l10n) {
    final String? requiredError = requiredField(
      value,
      fieldName: l10n.emailAddress,
      l10n: l10n,
    );

    if (requiredError != null) {
      return requiredError;
    }

    final String email = value!.trim();

    if (email.length > 150) {
      return l10n.emailTooLong;
    }

    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return l10n.invalidEmail;
    }

    return null;
  }

  static String? password(String? value, AppLocalizations l10n) {
    final String? requiredError = requiredField(
      value,
      fieldName: l10n.password,
      l10n: l10n,
    );

    if (requiredError != null) {
      return requiredError;
    }

    final String password = value!;

    if (password.length < 8 || password.length > 72) {
      return l10n.passwordLength;
    }

    if (password.contains(RegExp(r'\s'))) {
      return l10n.passwordNoSpaces;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return l10n.passwordLowercase;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return l10n.passwordUppercase;
    }

    if (!password.contains(RegExp(r'\d'))) {
      return l10n.passwordNumber;
    }

    if (!password.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return l10n.passwordSpecial;
    }

    return null;
  }

  static String? confirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    final String? requiredError = requiredField(
      value,
      fieldName: l10n.confirmPassword,
      l10n: l10n,
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value != password) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }
}
