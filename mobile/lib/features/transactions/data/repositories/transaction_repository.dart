import '../datasources/transaction_remote_data_source.dart';
import '../models/create_transaction_request_model.dart';
import '../models/transaction_filter_model.dart';
import '../models/transaction_model.dart';
import '../models/transaction_page_model.dart';
import '../models/update_transaction_request_model.dart';

class TransactionRepository {
  const TransactionRepository({
    required TransactionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final TransactionRemoteDataSource _remoteDataSource;

  Future<TransactionModel> createTransaction(
    CreateTransactionRequestModel request,
  ) {
    return _remoteDataSource.createTransaction(request);
  }

  Future<TransactionPageModel> getTransactions({
    required int page,
    required int size,
    String query = '',
    TransactionFilterModel filters = TransactionFilterModel.empty,
  }) {
    return _remoteDataSource.getTransactions(
      page: page,
      size: size,
      query: query,
      filters: filters,
    );
  }

  Future<TransactionModel> getTransaction(int transactionId) {
    return _remoteDataSource.getTransaction(transactionId);
  }

  Future<TransactionModel> updateTransaction(
    int transactionId,
    UpdateTransactionRequestModel request,
  ) {
    return _remoteDataSource.updateTransaction(transactionId, request);
  }

  Future<void> archiveTransaction(int transactionId) {
    return _remoteDataSource.archiveTransaction(transactionId);
  }
}
