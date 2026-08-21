import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';

final class BudgetFormController extends ChangeNotifier {
  BudgetFormController({required BudgetRepository repository})
    : _repository = repository;

  final BudgetRepository _repository;
  AppException? _error;
  bool _submitting = false;
  bool _loading = false;
  BudgetModel? _existing;

  AppException? get error => _error;
  bool get isSubmitting => _submitting;
  bool get isLoading => _loading;
  BudgetModel? get existing => _existing;

  Future<void> loadExisting(int id) async {
    if (_loading || _existing?.id == id) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _existing = await _repository.getBudget(id);
    } on AppException catch (e) {
      _error = e;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<BudgetModel?> create({
    required int categoryId,
    required String amount,
    required DateTime month,
    String? note,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      return await _repository.create(
        categoryId: categoryId,
        limitAmount: amount,
        month: month,
        note: note,
      );
    } on AppException catch (e) {
      _error = e;
      return null;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<BudgetModel?> update({required String amount, String? note}) async {
    final BudgetModel? budget = _existing;
    if (budget == null || _submitting) return null;
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      final BudgetModel updated = await _repository.update(
        id: budget.id,
        version: budget.version,
        limitAmount: amount,
        note: note,
      );
      _existing = updated;
      return updated;
    } on AppException catch (e) {
      _error = e;
      return null;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
