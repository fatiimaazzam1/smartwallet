import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/create_transaction_request_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_type.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../utils/transaction_formatters.dart';
import '../../utils/transaction_request_id.dart';

final class AddTransactionController extends ChangeNotifier {
  AddTransactionController({
    required TransactionRepository transactionRepository,
    String? clientRequestId,
  }) : _transactionRepository = transactionRepository,
       _clientRequestId = clientRequestId ?? TransactionRequestId.generate();

  final TransactionRepository _transactionRepository;
  bool _disposed = false;
  final String _clientRequestId;

  bool _isSubmitting = false;
  AppException? _error;

  bool get isSubmitting => _isSubmitting;
  AppException? get error => _error;

  @visibleForTesting
  String get clientRequestId => _clientRequestId;

  Future<TransactionModel?> create({
    required TransactionType type,
    required String amount,
    required int categoryId,
    required DateTime occurredOn,
    required String description,
  }) async {
    if (_isSubmitting) {
      return null;
    }

    _isSubmitting = true;
    _error = null;
    _notifyListeners();

    try {
      final String normalizedDescription =
          TransactionFormatters.normalizeDescription(description);
      return await _transactionRepository.createTransaction(
        CreateTransactionRequestModel(
          clientRequestId: _clientRequestId,
          type: type,
          amount: amount.trim(),
          categoryId: categoryId,
          occurredOn: occurredOn,
          description: normalizedDescription.isEmpty
              ? null
              : normalizedDescription,
        ),
      );
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
      _isSubmitting = false;
      _notifyListeners();
    }
  }

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
