import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartwallet_mobile/core/localization/app_language.dart';
import 'package:smartwallet_mobile/core/localization/app_locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('system preference uses Arabic for an Arabic device', () async {
    final AppLocaleController controller = await AppLocaleController.create();

    expect(
      controller.resolveLocale(const <Locale>[Locale('ar', 'LB')]),
      const Locale('ar'),
    );
  });

  test('system preference falls back to English for unsupported language', () async {
    final AppLocaleController controller = await AppLocaleController.create();

    expect(
      controller.resolveLocale(const <Locale>[Locale('fr', 'FR')]),
      const Locale('en'),
    );
  });

  test('explicit English ignores the device language', () async {
    final AppLocaleController controller = await AppLocaleController.create();
    await controller.setPreference(AppLanguagePreference.english);

    expect(
      controller.resolveLocale(const <Locale>[Locale('ar', 'LB')]),
      const Locale('en'),
    );
  });

  test('explicit Arabic ignores the device language', () async {
    final AppLocaleController controller = await AppLocaleController.create();
    await controller.setPreference(AppLanguagePreference.arabic);

    expect(
      controller.resolveLocale(const <Locale>[Locale('en', 'US')]),
      const Locale('ar'),
    );
  });
}
