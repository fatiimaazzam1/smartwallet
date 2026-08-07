final class WalletModel {
  const WalletModel({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.balance,
  });

  final int id;
  final String name;
  final String currencyCode;
  final double balance;

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final Object? rawId = json['id'];
    final Object? rawName = json['name'];
    final Object? rawCurrency = json['currencyCode'];
    final Object? rawBalance = json['balance'];

    if (rawId is! num ||
        rawName is! String ||
        rawCurrency is! String ||
        rawBalance is! num) {
      throw const FormatException('Invalid wallet response');
    }

    final String normalizedName = rawName.trim();
    final String normalizedCurrency = rawCurrency.trim().toUpperCase();

    if (normalizedName.isEmpty || normalizedCurrency.length != 3) {
      throw const FormatException('Invalid wallet response');
    }

    return WalletModel(
      id: rawId.toInt(),
      name: normalizedName,
      currencyCode: normalizedCurrency,
      balance: rawBalance.toDouble(),
    );
  }
}
