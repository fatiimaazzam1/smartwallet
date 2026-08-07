import '../datasources/category_remote_data_source.dart';
import '../models/category_model.dart';
import '../models/category_type.dart';
import '../models/create_category_request_model.dart';

final class CategoryRepository {
  const CategoryRepository({required CategoryRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final CategoryRemoteDataSource _remoteDataSource;

  Future<List<CategoryModel>> getCategories({CategoryType? type}) {
    return _remoteDataSource.getCategories(type: type);
  }

  Future<CategoryModel> createCategory({
    required String name,
    required CategoryType type,
  }) {
    return _remoteDataSource.createCategory(
      CreateCategoryRequestModel(name: name, type: type),
    );
  }

  Future<void> archiveCategory(int categoryId) {
    return _remoteDataSource.archiveCategory(categoryId);
  }
}
