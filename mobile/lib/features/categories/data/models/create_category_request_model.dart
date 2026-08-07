import 'category_type.dart';

final class CreateCategoryRequestModel {
  const CreateCategoryRequestModel({
    required this.name,
    required this.type,
  });

  final String name;
  final CategoryType type;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'type': type.apiValue,
    };
  }
}
