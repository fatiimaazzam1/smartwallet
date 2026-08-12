import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/transaction_filter_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_page_model.dart';
import '../../data/repositories/transaction_repository.dart';

final class TransactionHistoryController extends ChangeNotifier {
  TransactionHistoryController({
    required TransactionRepository transactionRepository,
    this.pageSize = 20,
    this.searchDebounce = const Duration(milliseconds: 400),
  }) : assert(pageSize > 0 && pageSize <= 50),
       _transactionRepository = transactionRepository;

  final TransactionRepository _transactionRepository;
  final int pageSize;
  final Duration searchDebounce;

  List<TransactionModel> _history = const <TransactionModel>[];
  List<TransactionModel> _recent = const <TransactionModel>[];
  TransactionFilterModel _filters = TransactionFilterModel.empty;
  String _query = '';
  AppException? _historyError;
  AppException? _paginationError;
  AppException? _recentError;
  bool _isInitialLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _isRecentLoading = false;
  bool _recentReloadPending = false;
  bool _hasLoadedHistory = false;
  bool _hasLoadedRecent = false;
  bool _isLastPage = false;
  int _nextPage = 0;
  int _historyGeneration = 0;
  int _recentGeneration = 0;
  Future<void>? _activeRecentLoad;
  Timer? _searchTimer;

  List<TransactionModel> get history => _history;
  List<TransactionModel> get recent => _recent;
  TransactionFilterModel get filters => _filters;
  String get query => _query;
  AppException? get historyError => _historyError;
  AppException? get paginationError => _paginationError;
  AppException? get recentError => _recentError;
  bool get isInitialLoading => _isInitialLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get isRecentLoading => _isRecentLoading;
  bool get hasLoadedHistory => _hasLoadedHistory;
  bool get hasLoadedRecent => _hasLoadedRecent;
  bool get isLastPage => _isLastPage;
  bool get hasActiveFilters => !_filters.isEmpty;
  int get activeFilterCount => _filters.activeCount;
  bool get hasSearch => _query.trim().isNotEmpty;

  Future<void> loadInitial({bool force = false}) async {
    if (_isInitialLoading || (_hasLoadedHistory && !force)) {
      return;
    }
    await _loadFirstPage(refreshing: false);
  }

  Future<void> refreshHistory() => _loadFirstPage(refreshing: true);

  Future<void> loadRecent({bool force = false}) {
    if (_isRecentLoading) {
      if (force) {
        _recentReloadPending = true;
      }
      return _activeRecentLoad ?? Future<void>.value();
    }

    if (_hasLoadedRecent && !force) {
      return Future<void>.value();
    }

    final Future<void> load = _runRecentLoadLoop();
    _activeRecentLoad = load;
    return load;
  }

  Future<void> _runRecentLoadLoop() async {
    final int generation = _recentGeneration;
    _isRecentLoading = true;
    _recentReloadPending = false;
    _recentError = null;
    notifyListeners();

    try {
      do {
        _recentReloadPending = false;
        try {
          final TransactionPageModel page = await _transactionRepository
              .getTransactions(page: 0, size: 3);
          if (generation != _recentGeneration) {
            return;
          }
          _recent = page.content;
          _hasLoadedRecent = true;
          _recentError = null;
        } on AppException catch (exception) {
          if (generation != _recentGeneration) {
            return;
          }
          _recentError = exception;
        } catch (_) {
          if (generation != _recentGeneration) {
            return;
          }
          _recentError = const AppException(
            message: 'Something unexpected happened. Please try again.',
            type: AppExceptionType.unknown,
          );
        }
      } while (_recentReloadPending && generation == _recentGeneration);
    } finally {
      if (generation == _recentGeneration) {
        _isRecentLoading = false;
        _activeRecentLoad = null;
        notifyListeners();
      }
    }
  }

  Future<void> refreshAfterMutation() async {
    await Future.wait<void>(<Future<void>>[
      loadRecent(force: true),
      refreshHistory(),
    ]);
  }

  void removeTransaction(int transactionId) {
    final int historyLength = _history.length;
    final int recentLength = _recent.length;
    _history = _history
        .where((TransactionModel item) => item.id != transactionId)
        .toList(growable: false);
    _recent = _recent
        .where((TransactionModel item) => item.id != transactionId)
        .toList(growable: false);

    if (_history.length != historyLength || _recent.length != recentLength) {
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    final String normalized = value.trimLeft();
    if (_query == normalized) {
      return;
    }

    _query = normalized.length > 100
        ? normalized.substring(0, 100)
        : normalized;
    _historyGeneration++;
    _searchTimer?.cancel();
    notifyListeners();

    _searchTimer = Timer(searchDebounce, () {
      _loadFirstPage(refreshing: false);
    });
  }

  Future<void> applyFilters(TransactionFilterModel value) async {
    if (_filters.sameAs(value)) {
      return;
    }
    _filters = value;
    notifyListeners();
    await _loadFirstPage(refreshing: false);
  }

  Future<void> resetFilters() async {
    if (_filters.isEmpty) {
      return;
    }
    _filters = TransactionFilterModel.empty;
    notifyListeners();
    await _loadFirstPage(refreshing: false);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore ||
        _isInitialLoading ||
        _isRefreshing ||
        !_hasLoadedHistory ||
        _isLastPage) {
      return;
    }

    final int generation = _historyGeneration;
    final int requestedPage = _nextPage;
    _isLoadingMore = true;
    _paginationError = null;
    notifyListeners();

    try {
      final TransactionPageModel page = await _transactionRepository
          .getTransactions(
            page: requestedPage,
            size: pageSize,
            query: _query.trim(),
            filters: _filters,
          );

      if (generation != _historyGeneration) {
        return;
      }

      final Set<int> existingIds = _history
          .map((TransactionModel transaction) => transaction.id)
          .toSet();
      final List<TransactionModel> newItems = page.content
          .where((TransactionModel transaction) => existingIds.add(transaction.id))
          .toList(growable: false);

      _history = <TransactionModel>[..._history, ...newItems];
      _isLastPage = page.last;
      _nextPage = page.page + 1;
    } on AppException catch (exception) {
      if (generation == _historyGeneration) {
        _paginationError = exception;
      }
    } catch (_) {
      if (generation == _historyGeneration) {
        _paginationError = const AppException(
          message: 'Something unexpected happened. Please try again.',
          type: AppExceptionType.unknown,
        );
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadMore() => loadMore();

  Future<void> _loadFirstPage({required bool refreshing}) async {
    final int generation = ++_historyGeneration;
    _searchTimer?.cancel();

    if (refreshing && _history.isNotEmpty) {
      _isRefreshing = true;
    } else {
      _isInitialLoading = true;
      _history = const <TransactionModel>[];
      _hasLoadedHistory = false;
      _nextPage = 0;
      _isLastPage = false;
    }
    _historyError = null;
    _paginationError = null;
    notifyListeners();

    try {
      final TransactionPageModel page = await _transactionRepository
          .getTransactions(
            page: 0,
            size: pageSize,
            query: _query.trim(),
            filters: _filters,
          );

      if (generation != _historyGeneration) {
        return;
      }

      _history = page.content;
      _nextPage = page.page + 1;
      _isLastPage = page.last;
      _hasLoadedHistory = true;
    } on AppException catch (exception) {
      if (generation == _historyGeneration) {
        _historyError = exception;
        if (!_hasLoadedHistory) {
          _history = const <TransactionModel>[];
        }
      }
    } catch (_) {
      if (generation == _historyGeneration) {
        _historyError = const AppException(
          message: 'Something unexpected happened. Please try again.',
          type: AppExceptionType.unknown,
        );
        if (!_hasLoadedHistory) {
          _history = const <TransactionModel>[];
        }
      }
    } finally {
      if (generation == _historyGeneration) {
        _isInitialLoading = false;
        _isRefreshing = false;
      }
      notifyListeners();
    }
  }

  void clear() {
    _searchTimer?.cancel();
    _historyGeneration++;
    _recentGeneration++;
    _history = const <TransactionModel>[];
    _recent = const <TransactionModel>[];
    _filters = TransactionFilterModel.empty;
    _query = '';
    _historyError = null;
    _paginationError = null;
    _recentError = null;
    _isInitialLoading = false;
    _isRefreshing = false;
    _isLoadingMore = false;
    _isRecentLoading = false;
    _recentReloadPending = false;
    _activeRecentLoad = null;
    _hasLoadedHistory = false;
    _hasLoadedRecent = false;
    _isLastPage = false;
    _nextPage = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
