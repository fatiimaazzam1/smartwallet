import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Arabic ARB files contain the same message keys', () {
    final Map<String, dynamic> english = _readArb('lib/l10n/app_en.arb');
    final Map<String, dynamic> arabic = _readArb('lib/l10n/app_ar.arb');

    final Set<String> englishKeys = _messageKeys(english);
    final Set<String> arabicKeys = _messageKeys(arabic);

    expect(arabicKeys, englishKeys);
  });

  test('all English and Arabic messages are non-empty', () {
    for (final String path in <String>[
      'lib/l10n/app_en.arb',
      'lib/l10n/app_ar.arb',
    ]) {
      final Map<String, dynamic> arb = _readArb(path);

      for (final String key in _messageKeys(arb)) {
        final Object? value = arb[key];
        expect(value, isA<String>(), reason: '$path: $key must be a string');
        expect(
          (value! as String).trim(),
          isNotEmpty,
          reason: '$path: $key must not be empty',
        );
      }
    }
  });
}

Map<String, dynamic> _readArb(String path) {
  final String source = File(path).readAsStringSync();
  return jsonDecode(source) as Map<String, dynamic>;
}

Set<String> _messageKeys(Map<String, dynamic> arb) {
  return arb.keys.where((String key) => !key.startsWith('@')).toSet();
}
