import 'category_type.dart';

final class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.isSystem,
  });

  final int id;
  final String name;
  final CategoryType type;
  final String iconKey;
  final bool isSystem;

  bool get isCustom => !isSystem;

  bool get isRetiredSystemDefault =>
      isSystem && name.toLowerCase() == 'other';

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final Object? rawId = json['id'];
    final Object? rawName = json['name'];
    final Object? rawType = json['type'];
    final Object? rawIconKey = json['iconKey'];
    final Object? rawSystem = json['system'];

    if (rawId is! num ||
        rawName is! String ||
        rawType is! String ||
        rawIconKey is! String ||
        rawSystem is! bool) {
      throw const FormatException('Invalid category response');
    }

    final String normalizedName = rawName.trim();
    final String normalizedIconKey = rawIconKey.trim();

    if (normalizedName.isEmpty || normalizedIconKey.isEmpty) {
      throw const FormatException('Invalid category response');
    }

    return CategoryModel(
      id: rawId.toInt(),
      name: normalizedName,
      type: CategoryType.fromApiValue(rawType),
      iconKey: normalizedIconKey,
      isSystem: rawSystem,
    );
  }
}
