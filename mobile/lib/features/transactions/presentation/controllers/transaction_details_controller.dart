import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

final class TransactionDetailsController extends ChangeNotifier {
  TransactionDetailsController({
    required TransactionRepository transactionRepository,
    required this.transactionId,
  }) : _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;
  bool _disposed = false;
  final int transactionId;

  TransactionModel? _transaction;
  AppException? _error;
  bool _isLoading = false;
  bool _isDeleting = false;

  TransactionModel? get transaction => _transaction;
  AppException? get error => _error;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;

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

  Future<bool> delete() async {
    if (_isDeleting) {
      return false;
    }

    _isDeleting = true;
    _error = null;
    _notifyListeners();

    try {
      await _transactionRepository.archiveTransaction(transactionId);
      _transaction = null;
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
      _isDeleting = false;
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
