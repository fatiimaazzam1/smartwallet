import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/category_model.dart';
import '../../data/models/category_type.dart';
import '../../data/repositories/category_repository.dart';

final class CategoryController extends ChangeNotifier {
  CategoryController({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  final CategoryRepository _categoryRepository;

  List<CategoryModel> _categories = const <CategoryModel>[];
  AppException? _error;
  bool _isLoading = false;
  bool _isCreating = false;
  int? _archivingCategoryId;

  List<CategoryModel> get categories => _categories;
  AppException? get error => _error;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  int? get archivingCategoryId => _archivingCategoryId;
  bool get hasLoaded => _categories.isNotEmpty;

  List<CategoryModel> categoriesOfType(CategoryType type) {
    return _categories
        .where((CategoryModel category) => category.type == type)
        .toList(growable: false);
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading || (hasLoaded && !force)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryRepository.getCategories();
    } on AppException catch (exception) {
      _error = exception;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CategoryModel?> createCategory({
    required String name,
    required CategoryType type,
  }) async {
    if (_isCreating) {
      return null;
    }

    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final CategoryModel created = await _categoryRepository.createCategory(
        name: name,
        type: type,
      );
      await _reloadAfterMutation();
      return created;
    } on AppException catch (exception) {
      _error = exception;
      return null;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> archiveCategory(CategoryModel category) async {
    if (category.isSystem || _archivingCategoryId != null) {
      return false;
    }

    _archivingCategoryId = category.id;
    _error = null;
    notifyListeners();

    try {
      await _categoryRepository.archiveCategory(category.id);
      _categories = _categories
          .where((CategoryModel item) => item.id != category.id)
          .toList(growable: false);
      return true;
    } on AppException catch (exception) {
      _error = exception;
      return false;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return false;
    } finally {
      _archivingCategoryId = null;
      notifyListeners();
    }
  }

  Future<void> _reloadAfterMutation() async {
    _categories = await _categoryRepository.getCategories();
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }
}
