import 'dart:math';

abstract final class TransactionRequestId {
  TransactionRequestId._();

  static String generate() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(
      16,
      (_) => random.nextInt(256),
      growable: false,
    );

    // RFC 4122 UUID v4: version 4 and variant 10xx.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final String hex = bytes
        .map((int byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
