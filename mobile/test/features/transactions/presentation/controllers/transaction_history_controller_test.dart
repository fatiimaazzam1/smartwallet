import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/create_transaction_request_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_filter_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/transaction_page_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/models/update_transaction_request_model.dart';
import 'package:smartwallet_mobile/features/transactions/data/repositories/transaction_repository.dart';
import 'package:smartwallet_mobile/features/transactions/presentation/controllers/transaction_history_controller.dart';

void main() {
  test('loads first page and appends the next page without duplicates', () async {
    final _FakeTransactionRepository repository = _FakeTransactionRepository(
      pages: <int, TransactionPageModel>{
        0: _page(0, <TransactionModel>[_transaction(3), _transaction(2)], last: false),
        1: _page(1, <TransactionModel>[_transaction(2), _transaction(1)], last: true),
      },
    );
    final TransactionHistoryController controller = TransactionHistoryController(
      transactionRepository: repository,
      pageSize: 2,
    );

    await controller.loadInitial();
    expect(controller.history.map((TransactionModel item) => item.id), <int>[3, 2]);
    expect(controller.isLastPage, isFalse);

    await controller.loadMore();
    expect(controller.history.map((TransactionModel item) => item.id), <int>[3, 2, 1]);
    expect(controller.isLastPage, isTrue);
    expect(repository.requestedPages, <int>[0, 1]);
  });

  test('refresh resets pagination to page zero', () async {
    final _FakeTransactionRepository repository = _FakeTransactionRepository(
      pages: <int, TransactionPageModel>{
        0: _page(0, <TransactionModel>[_transaction(2)], last: false),
        1: _page(1, <TransactionModel>[_transaction(1)], last: true),
      },
    );
    final TransactionHistoryController controller = TransactionHistoryController(
      transactionRepository: repository,
      pageSize: 1,
    );

    await controller.loadInitial();
    await controller.loadMore();
    await controller.refreshHistory();

    expect(repository.requestedPages, <int>[0, 1, 0]);
    expect(controller.history.map((TransactionModel item) => item.id), <int>[2]);
  });
  test('removes a deleted transaction from history and recent state immediately', () async {
    final _FakeTransactionRepository repository = _FakeTransactionRepository(
      pages: <int, TransactionPageModel>{
        0: _page(0, <TransactionModel>[_transaction(2), _transaction(1)], last: true),
      },
    );
    final TransactionHistoryController controller = TransactionHistoryController(
      transactionRepository: repository,
      pageSize: 2,
    );

    await controller.loadInitial();
    await controller.loadRecent(force: true);
    controller.removeTransaction(2);

    expect(controller.history.map((TransactionModel item) => item.id), <int>[1]);
    expect(controller.recent.map((TransactionModel item) => item.id), <int>[1]);
  });

  test('clear prevents an in-flight recent request from restoring old-user data', () async {
    final _DelayedRecentRepository repository = _DelayedRecentRepository();
    final TransactionHistoryController controller = TransactionHistoryController(
      transactionRepository: repository,
    );

    final Future<void> pending = controller.loadRecent();
    controller.clear();
    repository.complete(
      _page(0, <TransactionModel>[_transaction(99)], last: true),
    );
    await pending;

    expect(controller.recent, isEmpty);
    expect(controller.hasLoadedRecent, isFalse);
  });

}

class _FakeTransactionRepository implements TransactionRepository {
  _FakeTransactionRepository({required this.pages});

  final Map<int, TransactionPageModel> pages;
  final List<int> requestedPages = <int>[];

  @override
  Future<TransactionPageModel> getTransactions({
    required int page,
    required int size,
    String query = '',
    TransactionFilterModel filters = TransactionFilterModel.empty,
  }) async {
    requestedPages.add(page);
    return pages[page] ?? _page(page, const <TransactionModel>[], last: true);
  }

  @override
  Future<TransactionModel> createTransaction(CreateTransactionRequestModel request) {
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

TransactionPageModel _page(
  int page,
  List<TransactionModel> content, {
  required bool last,
}) {
  return TransactionPageModel(
    content: content,
    page: page,
    size: content.isEmpty ? 1 : content.length,
    totalElements: 3,
    totalPages: 2,
    first: page == 0,
    last: last,
  );
}

TransactionModel _transaction(int id) {
  return TransactionModel.fromJson(<String, dynamic>{
    'id': id,
    'version': 0,
    'type': 'EXPENSE',
    'amount': 10,
    'description': 'Item $id',
    'occurredOn': '2026-08-08',
    'currencyCode': 'USD',
    'status': 'RECORDED',
    'category': <String, dynamic>{
      'id': 5,
      'name': 'Food',
      'iconKey': 'food',
    },
  });
}


class _DelayedRecentRepository implements TransactionRepository {
  final Completer<TransactionPageModel> _completer =
      Completer<TransactionPageModel>();

  void complete(TransactionPageModel page) => _completer.complete(page);

  @override
  Future<TransactionPageModel> getTransactions({
    required int page,
    required int size,
    String query = '',
    TransactionFilterModel filters = TransactionFilterModel.empty,
  }) {
    return _completer.future;
  }

  @override
  Future<TransactionModel> createTransaction(
    CreateTransactionRequestModel request,
  ) {
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
