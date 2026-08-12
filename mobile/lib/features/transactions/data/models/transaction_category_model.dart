final class TransactionCategoryModel {
  const TransactionCategoryModel({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  final int id;
  final String name;
  final String iconKey;

  factory TransactionCategoryModel.fromJson(Map<String, dynamic> json) {
    final Object? rawId = json['id'];
    final Object? rawName = json['name'];
    final Object? rawIconKey = json['iconKey'];

    if (rawId is! num || rawName is! String || rawIconKey is! String) {
      throw const FormatException('Invalid transaction category response');
    }

    final String name = rawName.trim();
    final String iconKey = rawIconKey.trim();

    if (rawId.toInt() <= 0 || name.isEmpty || iconKey.isEmpty) {
      throw const FormatException('Invalid transaction category response');
    }

    return TransactionCategoryModel(
      id: rawId.toInt(),
      name: name,
      iconKey: iconKey,
    );
  }
}
