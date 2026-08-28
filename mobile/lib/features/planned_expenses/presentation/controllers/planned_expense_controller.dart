import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/planned_expense_model.dart';
import '../../data/repositories/planned_expense_repository.dart';

final class PlannedExpenseController extends ChangeNotifier {
  PlannedExpenseController({required PlannedExpenseRepository repository})
    : _repository = repository;

  final PlannedExpenseRepository _repository;
  final Map<PlannedExpenseStatus, List<PlannedExpenseModel>> _items =
      <PlannedExpenseStatus, List<PlannedExpenseModel>>{};
  final Map<PlannedExpenseStatus, bool> _last =
      <PlannedExpenseStatus, bool>{};
  final Map<PlannedExpenseStatus, int> _nextPage =
      <PlannedExpenseStatus, int>{};
  final Map<PlannedExpenseStatus, int> _totalElements =
      <PlannedExpenseStatus, int>{};
  final Map<PlannedExpenseStatus, String> _totalAmounts =
      <PlannedExpenseStatus, String>{};

  PlannedExpenseStatus _status = PlannedExpenseStatus.upcoming;
  AppException? _error;
  bool _loading = false;
  bool _loadingMore = false;
  int _generation = 0;

  PlannedExpenseStatus get status => _status;
  List<PlannedExpenseModel> get items =>
      _items[_status] ?? const <PlannedExpenseModel>[];
  AppException? get error => _error;
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get isLastPage => _last[_status] ?? false;
  int get totalElements => _totalElements[_status] ?? items.length;
  String get totalAmount => _totalAmounts[_status] ?? '0.00';

  Future<void> selectStatus(PlannedExpenseStatus value) async {
    if (_status == value) return;
    _invalidateInFlightRequests();
    _status = value;
    _error = null;
    notifyListeners();
    if (!_items.containsKey(value)) {
      await load(force: true);
    }
  }

  Future<void> load({bool force = false}) async {
    if (_loading) {
      if (!force) return;
      _invalidateInFlightRequests();
    }
    if (!force && _items.containsKey(_status)) return;

    final int generation = _generation;
    final PlannedExpenseStatus requestedStatus = _status;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final PlannedExpensePageModel page = await _repository.list(
        status: requestedStatus,
        page: 0,
      );
      if (generation == _generation) {
        _items[requestedStatus] = page.content;
        _nextPage[requestedStatus] = page.page + 1;
        _last[requestedStatus] = page.last;
        _totalElements[requestedStatus] = page.totalElements;
        _totalAmounts[requestedStatus] = page.totalAmount;
      }
    } on AppException catch (error) {
      if (generation == _generation) _error = error;
    } catch (_) {
      if (generation == _generation) {
        _error = const AppException(
          message: 'Something unexpected happened. Please try again.',
          type: AppExceptionType.unknown,
        );
      }
    } finally {
      if (generation == _generation) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    final PlannedExpenseStatus requestedStatus = _status;
    if (_loading || _loadingMore || (_last[requestedStatus] ?? false)) return;

    final int generation = _generation;
    _loadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final PlannedExpensePageModel page = await _repository.list(
        status: requestedStatus,
        page: _nextPage[requestedStatus] ?? 0,
      );
      if (generation == _generation) {
        final Set<int> ids = (_items[requestedStatus] ??
                const <PlannedExpenseModel>[])
            .map((PlannedExpenseModel item) => item.id)
            .toSet();
        _items[requestedStatus] = <PlannedExpenseModel>[
          ...(_items[requestedStatus] ?? const <PlannedExpenseModel>[]),
          ...page.content.where(
            (PlannedExpenseModel item) => ids.add(item.id),
          ),
        ];
        _nextPage[requestedStatus] = page.page + 1;
        _last[requestedStatus] = page.last;
        _totalElements[requestedStatus] = page.totalElements;
        _totalAmounts[requestedStatus] = page.totalAmount;
      }
    } on AppException catch (error) {
      if (generation == _generation) _error = error;
    } catch (_) {
      if (generation == _generation) {
        _error = const AppException(
          message: 'Something unexpected happened. Please try again.',
          type: AppExceptionType.unknown,
        );
      }
    } finally {
      if (generation == _generation) {
        _loadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshCurrent() async {
    _invalidateInFlightRequests();
    await load(force: true);
  }

  Future<void> refreshAll() async {
    _invalidateInFlightRequests();
    _items.clear();
    _last.clear();
    _nextPage.clear();
    _totalElements.clear();
    _totalAmounts.clear();
    await load(force: true);
  }

  void clear() {
    _invalidateInFlightRequests();
    _items.clear();
    _last.clear();
    _nextPage.clear();
    _totalElements.clear();
    _totalAmounts.clear();
    _status = PlannedExpenseStatus.upcoming;
    _error = null;
    notifyListeners();
  }

  void _invalidateInFlightRequests() {
    _generation++;
    _loading = false;
    _loadingMore = false;
  }
}
