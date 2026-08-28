import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/budget_related_expense_model.dart';
import '../../data/repositories/budget_repository.dart';

final class BudgetDetailsController extends ChangeNotifier {
  BudgetDetailsController({
    required BudgetRepository repository,
    required this.budgetId,
  }) : _repository = repository;

  final BudgetRepository _repository;
  final int budgetId;
  bool _disposed = false;

  BudgetModel? _budget;
  List<BudgetRelatedExpenseModel> _relatedExpenses =
      const <BudgetRelatedExpenseModel>[];
  AppException? _error;
  AppException? _relatedError;
  bool _loading = false;
  bool _loadingRelated = false;
  bool _deleting = false;

  BudgetModel? get budget => _budget;
  List<BudgetRelatedExpenseModel> get relatedExpenses =>
      List<BudgetRelatedExpenseModel>.unmodifiable(_relatedExpenses);
  AppException? get error => _error;
  AppException? get relatedError => _relatedError;
  bool get isLoading => _loading;
  bool get isLoadingRelated => _loadingRelated;
  bool get isDeleting => _deleting;

  Future<void> load({bool force = false}) async {
    if (_loading || (_budget != null && !force)) return;
    _loading = true;
    _error = null;
    _notifyListeners();
    try {
      _budget = await _repository.getBudget(budgetId);
    } on AppException catch (exception) {
      _error = exception;
      return;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return;
    } finally {
      _loading = false;
      _notifyListeners();
    }

    await loadRelatedExpenses(force: true);
  }

  Future<void> loadRelatedExpenses({bool force = false}) async {
    if (_budget == null || _loadingRelated) return;
    if (!force && _relatedExpenses.isNotEmpty) return;
    _loadingRelated = true;
    _relatedError = null;
    _notifyListeners();
    try {
      _relatedExpenses = await _repository.getRelatedExpenses(budgetId);
    } on AppException catch (exception) {
      _relatedError = exception;
    } catch (_) {
      _relatedError = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
    } finally {
      _loadingRelated = false;
      _notifyListeners();
    }
  }

  Future<bool> delete() async {
    final BudgetModel? budget = _budget;
    if (budget == null || _deleting) return false;
    _deleting = true;
    _error = null;
    _notifyListeners();
    try {
      await _repository.archive(id: budget.id, version: budget.version);
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
      _deleting = false;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
