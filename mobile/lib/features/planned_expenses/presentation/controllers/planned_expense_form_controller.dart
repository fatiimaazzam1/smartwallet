import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../transactions/utils/transaction_request_id.dart';
import '../../data/models/planned_expense_model.dart';
import '../../data/repositories/planned_expense_repository.dart';

final class PlannedExpenseFormController extends ChangeNotifier {
  PlannedExpenseFormController({required PlannedExpenseRepository repository})
    : _repository = repository;

  final PlannedExpenseRepository _repository;
  final String _createClientRequestId = TransactionRequestId.generate();
  bool _disposed = false;
  AppException? _error;
  bool _submitting = false;
  bool _loading = false;
  PlannedExpenseModel? _existing;

  AppException? get error => _error;
  bool get isSubmitting => _submitting;
  bool get isLoading => _loading;
  PlannedExpenseModel? get existing => _existing;

  Future<void> loadExisting(int id) async {
    if (_loading || _existing?.id == id) return;
    _loading = true;
    _error = null;
    _notifyListeners();
    try {
      _existing = await _repository.get(id);
    } on AppException catch (e) {
      _error = e;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
    } finally {
      _loading = false;
      _notifyListeners();
    }
  }

  Future<PlannedExpenseModel?> create({
    required String title,
    required String amount,
    required int categoryId,
    required DateTime dueOn,
    required PlannedExpenseRecurrence recurrence,
    String? note,
  }) async {
    if (_submitting) return null;
    _submitting = true;
    _error = null;
    _notifyListeners();
    try {
      return await _repository.create(
        clientRequestId: _createClientRequestId,
        title: title,
        amount: amount,
        categoryId: categoryId,
        dueOn: dueOn,
        recurrence: recurrence,
        note: note,
      );
    } on AppException catch (e) {
      _error = e;
      return null;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return null;
    } finally {
      _submitting = false;
      _notifyListeners();
    }
  }

  Future<PlannedExpenseModel?> update({
    required String title,
    required String amount,
    required int categoryId,
    required DateTime dueOn,
    required PlannedExpenseRecurrence recurrence,
    String? note,
  }) async {
    final PlannedExpenseModel? item = _existing;
    if (item == null || _submitting) return null;
    _submitting = true;
    _error = null;
    _notifyListeners();
    try {
      final PlannedExpenseModel updated = await _repository.update(
        id: item.id,
        version: item.version,
        title: title,
        amount: amount,
        categoryId: categoryId,
        dueOn: dueOn,
        recurrence: recurrence,
        note: note,
      );
      _existing = updated;
      return updated;
    } on AppException catch (e) {
      _error = e;
      return null;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return null;
    } finally {
      _submitting = false;
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
