import 'package:flutter/material.dart';

enum AppLanguagePreference {
  system('SYSTEM'),
  english('ENGLISH'),
  arabic('ARABIC');

  const AppLanguagePreference(this.apiValue);

  final String apiValue;

  Locale? get explicitLocale {
    switch (this) {
      case AppLanguagePreference.system:
        return null;
      case AppLanguagePreference.english:
        return const Locale('en');
      case AppLanguagePreference.arabic:
        return const Locale('ar');
    }
  }

  static AppLanguagePreference fromApiValue(String value) {
    return AppLanguagePreference.values.firstWhere(
      (AppLanguagePreference item) => item.apiValue == value,
      orElse: () => AppLanguagePreference.system,
    );
  }
}
