import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/planned_expense_model.dart';
import '../../data/repositories/planned_expense_repository.dart';

final class PlannedExpenseDetailsController extends ChangeNotifier {
  PlannedExpenseDetailsController({
    required PlannedExpenseRepository repository,
    required this.plannedExpenseId,
  }) : _repository = repository;

  final PlannedExpenseRepository _repository;
  final int plannedExpenseId;
  bool _disposed = false;
  PlannedExpenseModel? _item;
  AppException? _error;
  bool _loading = false;
  bool _busy = false;

  PlannedExpenseModel? get item => _item;
  AppException? get error => _error;
  bool get isLoading => _loading;
  bool get isBusy => _busy;

  Future<void> load({bool force = false}) async {
    if (_loading || (_item != null && !force)) return;
    _loading = true;
    _error = null;
    _notifyListeners();
    try {
      _item = await _repository.get(plannedExpenseId);
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

  Future<bool> cancel() async {
    final PlannedExpenseModel? item = _item;
    if (item == null || _busy) return false;
    _busy = true;
    _error = null;
    _notifyListeners();
    try {
      _item = await _repository.cancel(id: item.id, version: item.version);
      return true;
    } on AppException catch (e) {
      _error = e;
      return false;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return false;
    } finally {
      _busy = false;
      _notifyListeners();
    }
  }

  Future<bool> markPaid({
    required DateTime paidOn,
    required String clientRequestId,
  }) async {
    final PlannedExpenseModel? item = _item;
    if (item == null || _busy) return false;
    _busy = true;
    _error = null;
    _notifyListeners();
    try {
      _item = await _repository.markPaid(
        id: item.id,
        version: item.version,
        paidOn: paidOn,
        clientRequestId: clientRequestId,
      );
      return true;
    } on AppException catch (e) {
      _error = e;
      return false;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return false;
    } finally {
      _busy = false;
      _notifyListeners();
    }
  }

  Future<bool> delete() async {
    final PlannedExpenseModel? item = _item;
    if (item == null || _busy) return false;
    _busy = true;
    _error = null;
    _notifyListeners();
    try {
      await _repository.archive(id: item.id, version: item.version);
      return true;
    } on AppException catch (e) {
      _error = e;
      return false;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return false;
    } finally {
      _busy = false;
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
