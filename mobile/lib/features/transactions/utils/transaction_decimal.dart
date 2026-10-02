abstract final class TransactionDecimal {
  TransactionDecimal._();

  static final RegExp _pattern = RegExp(r'^\d{1,17}(?:\.\d{1,2})?$');

  static bool isValidPositive(String value) {
    final String normalized = value.trim();
    if (!_pattern.hasMatch(normalized)) {
      return false;
    }

    final BigInt? smallestUnits = BigInt.tryParse(
      normalized.replaceAll('.', ''),
    );
    return smallestUnits != null && smallestUnits > BigInt.zero;
  }


  static bool isValidNonNegative(String value) {
    final String normalized = value.trim();
    if (!_pattern.hasMatch(normalized)) {
      return false;
    }

    final BigInt? smallestUnits = BigInt.tryParse(
      normalized.replaceAll('.', ''),
    );
    return smallestUnits != null && smallestUnits >= BigInt.zero;
  }

  static String requireValidPositive(String value) {
    final String normalized = value.trim();
    if (!isValidPositive(normalized)) {
      throw ArgumentError.value(value, 'value', 'Invalid transaction amount');
    }
    return normalized;
  }
}
