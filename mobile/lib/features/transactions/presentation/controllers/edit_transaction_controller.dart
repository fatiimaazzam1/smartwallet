import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/update_transaction_request_model.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../utils/transaction_formatters.dart';

final class EditTransactionController extends ChangeNotifier {
  EditTransactionController({
    required TransactionRepository transactionRepository,
    required this.transactionId,
  }) : _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;
  bool _disposed = false;
  final int transactionId;

  TransactionModel? _transaction;
  AppException? _error;
  bool _isLoading = false;
  bool _isSaving = false;

  TransactionModel? get transaction => _transaction;
  AppException? get error => _error;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasConflict => _error?.statusCode == 409;

  Future<void> load({bool force = false}) async {
    if (_isLoading || (_transaction != null && !force)) {
      return;
    }

    _isLoading = true;
    _error = null;
    _notifyListeners();

    try {
      _transaction = await _transactionRepository.getTransaction(transactionId);
    } on AppException catch (exception) {
      _error = exception;
      if (exception.statusCode == 404) {
        _transaction = null;
      }
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  Future<TransactionModel?> save({
    required String amount,
    required int categoryId,
    required DateTime occurredOn,
    required String description,
  }) async {
    final TransactionModel? current = _transaction;
    if (_isSaving || current == null) {
      return null;
    }

    _isSaving = true;
    _error = null;
    _notifyListeners();

    try {
      final String normalizedDescription =
          TransactionFormatters.normalizeDescription(description);
      final TransactionModel updated = await _transactionRepository
          .updateTransaction(
            transactionId,
            UpdateTransactionRequestModel(
              version: current.version,
              amount: amount.trim(),
              categoryId: categoryId,
              occurredOn: occurredOn,
              description: normalizedDescription.isEmpty
                  ? null
                  : normalizedDescription,
            ),
          );
      _transaction = updated;
      return updated;
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
      _isSaving = false;
      _notifyListeners();
    }
  }

  Future<void> reloadLatest() => load(force: true);

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    _notifyListeners();
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
