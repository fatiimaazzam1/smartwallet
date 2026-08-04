import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

final class AppLocaleController extends ChangeNotifier {
  AppLocaleController({
    AppLanguagePreference preference = AppLanguagePreference.system,
  }) : _preference = preference;

  static const String _storageKey = 'smartwallet_language_preference';

  AppLanguagePreference _preference;

  AppLanguagePreference get preference => _preference;

  Locale? get locale => _preference.explicitLocale;

  static Future<AppLocaleController> create() async {
    final AppLocaleController controller = AppLocaleController();
    await controller.loadSavedPreference();
    return controller;
  }

  Future<void> loadSavedPreference() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final String? storedValue = preferences.getString(_storageKey);

      if (storedValue == null) {
        return;
      }

      final AppLanguagePreference storedPreference =
          AppLanguagePreference.fromApiValue(storedValue);

      if (_preference == storedPreference) {
        return;
      }

      _preference = storedPreference;
      notifyListeners();
    } catch (_) {
      // Keep the safe System default when local preference loading fails.
    }
  }

  Future<void> setPreference(
    AppLanguagePreference preference, {
    bool persist = true,
  }) async {
    if (_preference == preference) {
      if (persist) {
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        await preferences.setString(_storageKey, preference.apiValue);
      }
      return;
    }

    _preference = preference;
    notifyListeners();

    if (persist) {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, preference.apiValue);
    }
  }

  Locale resolveLocale(List<Locale>? deviceLocales) {
    final Locale? explicit = locale;

    if (explicit != null) {
      return explicit;
    }

    final List<Locale> locales = deviceLocales ?? const <Locale>[];

    if (locales.isEmpty) {
      return const Locale('en');
    }

    final String languageCode = locales.first.languageCode.toLowerCase();

    if (languageCode == 'ar') {
      return const Locale('ar');
    }

    if (languageCode == 'en') {
      return const Locale('en');
    }

    return const Locale('en');
  }
}
