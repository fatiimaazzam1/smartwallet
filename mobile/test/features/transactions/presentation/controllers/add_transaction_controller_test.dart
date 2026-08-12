import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/core/errors/app_exception.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/create_transaction_request_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_filter_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_page_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_type.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/update_transaction_request_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/repositories/transaction_repository.dart';
import 'package:smartwallet_mobile/features/transactions/presentation/controllers/add_transaction_controller.dart';

void main() {
  test('reuses the same client request id when the same add form retries', () async {
    final _RetryRepository repository = _RetryRepository();
    final AddTransactionController controller = AddTransactionController(
      transactionRepository: repository,
      clientRequestId: '123e4567-e89b-42d3-a456-426614174000',
    );

    final TransactionModel? first = await controller.create(
      type: TransactionType.income,
      amount: '100.00',
      categoryId: 1,
      occurredOn: DateTime(2026, 8, 8),
      description: 'Salary',
    );
    expect(first, isNull);

    final TransactionModel? second = await controller.create(
      type: TransactionType.income,
      amount: '100.00',
      categoryId: 1,
      occurredOn: DateTime(2026, 8, 8),
      description: 'Salary',
    );

    expect(second, isNotNull);
    expect(repository.requestIds, <String>[
      '123e4567-e89b-42d3-a456-426614174000',
      '123e4567-e89b-42d3-a456-426614174000',
    ]);
  });
}

class _RetryRepository implements TransactionRepository {
  final List<String> requestIds = <String>[];
  int _attempt = 0;

  @override
  Future<TransactionModel> createTransaction(
    CreateTransactionRequestModel request,
  ) async {
    requestIds.add(request.clientRequestId);
    _attempt++;
    if (_attempt == 1) {
      throw const AppException(
        message: 'Unable to connect to SmartWallet.',
        type: AppExceptionType.network,
      );
    }

    return TransactionModel.fromJson(<String, dynamic>{
      'id': 9,
      'version': 0,
      'type': 'INCOME',
      'amount': 100,
      'description': 'Salary',
      'occurredOn': '2026-08-08',
      'currencyCode': 'USD',
      'status': 'RECORDED',
      'category': <String, dynamic>{
        'id': 1,
        'name': 'Salary',
        'iconKey': 'salary',
      },
    });
  }

  @override
  Future<TransactionPageModel> getTransactions({
    required int page,
    required int size,
    String query = '',
    TransactionFilterModel filters = TransactionFilterModel.empty,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionModel> getTransaction(int transactionId) {
    throw UnimplementedError();
  }

  @override
  Future<TransactionModel> updateTransaction(
    int transactionId,
    UpdateTransactionRequestModel request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> archiveTransaction(int transactionId) {
    throw UnimplementedError();
  }
}
