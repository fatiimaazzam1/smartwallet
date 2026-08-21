import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/budget_month_model.dart';
import '../../data/repositories/budget_repository.dart';

final class BudgetController extends ChangeNotifier {
  BudgetController({required BudgetRepository repository}) : _repository = repository;
  final BudgetRepository _repository;

  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  BudgetMonthModel? _data;
  AppException? _error;
  bool _loading = false;
  int _generation = 0;

  DateTime get month => _month;
  BudgetMonthModel? get data => _data;
  AppException? get error => _error;
  bool get isLoading => _loading;

  bool get canGoToPreviousMonth => _month.isAfter(_currentMonth());

  Future<void> load({bool force = false}) async {
    final DateTime current = _currentMonth();
    if (_month.isBefore(current)) {
      _month = current;
      _data = null;
    }
    if (_loading) {
      if (!force) return;
      _generation++;
      _loading = false;
    }
    if (_data != null && !force) return;
    final int generation = _generation;
    _loading = true; _error = null; notifyListeners();
    try {
      final BudgetMonthModel data = await _repository.getBudgets(_month);
      if (generation == _generation) _data = data;
    } on AppException catch (e) { if (generation == _generation) _error = e; }
    catch (_) { if (generation == _generation) _error = const AppException(message: 'Something unexpected happened. Please try again.', type: AppExceptionType.unknown); }
    finally { if (generation == _generation) { _loading = false; notifyListeners(); } }
  }

  Future<void> setMonth(DateTime value) async {
    final DateTime requested = DateTime(value.year, value.month, 1);
    final DateTime current = _currentMonth();
    final DateTime normalized = requested.isBefore(current) ? current : requested;
    if (normalized == _month) return;
    _month = normalized;
    _data = null;
    notifyListeners();
    await load(force: true);
  }

  Future<void> goToPreviousMonth() {
    if (!canGoToPreviousMonth) return Future<void>.value();
    return setMonth(DateTime(_month.year, _month.month - 1, 1));
  }

  Future<void> goToNextMonth() =>
      setMonth(DateTime(_month.year, _month.month + 1, 1));

  Future<void> refresh() => load(force: true);

  void clear() {
    _generation++;
    _month = _currentMonth();
    _data = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  static DateTime _currentMonth() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}
