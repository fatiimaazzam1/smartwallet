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
  int _generation = 0;

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

    final int generation = _generation;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<CategoryModel> categories =
          await _categoryRepository.getCategories();
      if (generation != _generation) {
        return;
      }
      _categories = categories;
    } on AppException catch (exception) {
      if (generation == _generation) {
        _error = exception;
      }
    } catch (_) {
      if (generation == _generation) {
        _error = const AppException(
          message: 'Something unexpected happened. Please try again.',
          type: AppExceptionType.unknown,
        );
      }
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<CategoryModel?> createCategory({
    required String name,
    required CategoryType type,
  }) async {
    if (_isCreating) {
      return null;
    }

    final int generation = _generation;
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final CategoryModel created = await _categoryRepository.createCategory(
        name: name,
        type: type,
      );
      final List<CategoryModel> categories =
          await _categoryRepository.getCategories();
      if (generation != _generation) {
        return null;
      }
      _categories = categories;
      return created;
    } on AppException catch (exception) {
      if (generation == _generation) {
        _error = exception;
      }
      return null;
    } catch (_) {
      if (generation == _generation) {
        _error = const AppException(
          message: 'Something unexpected happened. Please try again.',
          type: AppExceptionType.unknown,
        );
      }
      return null;
    } finally {
      if (generation == _generation) {
        _isCreating = false;
        notifyListeners();
      }
    }
  }

  Future<bool> archiveCategory(CategoryModel category) async {
    if (category.isSystem || _archivingCategoryId != null) {
      return false;
    }

    final int generation = _generation;
    _archivingCategoryId = category.id;
    _error = null;
    notifyListeners();

    try {
      await _categoryRepository.archiveCategory(category.id);
      if (generation != _generation) {
        return false;
      }
      _categories = _categories
          .where((CategoryModel item) => item.id != category.id)
          .toList(growable: false);
      return true;
    } on AppException catch (exception) {
      if (generation == _generation) {
        _error = exception;
      }
      return false;
    } catch (_) {
      if (generation == _generation) {
        _error = const AppException(
          message: 'Something unexpected happened. Please try again.',
          type: AppExceptionType.unknown,
        );
      }
      return false;
    } finally {
      if (generation == _generation) {
        _archivingCategoryId = null;
        notifyListeners();
      }
    }
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }

  void clear() {
    _generation++;
    _categories = const <CategoryModel>[];
    _error = null;
    _isLoading = false;
    _isCreating = false;
    _archivingCategoryId = null;
    notifyListeners();
  }
}
