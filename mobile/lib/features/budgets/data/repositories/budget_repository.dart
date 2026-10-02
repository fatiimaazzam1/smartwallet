import '../datasources/budget_remote_data_source.dart';
import '../models/budget_model.dart';
import '../models/budget_month_model.dart';
import '../models/budget_related_expense_model.dart';

final class BudgetRepository {
  const BudgetRepository({required BudgetRemoteDataSource remoteDataSource}) : _remote = remoteDataSource;
  final BudgetRemoteDataSource _remote;

  Future<BudgetMonthModel> getBudgets(DateTime month) => _remote.getBudgets(month);
  Future<BudgetModel> getBudget(int id) => _remote.getBudget(id);
  Future<List<BudgetRelatedExpenseModel>> getRelatedExpenses(int id, {int size = 5}) => _remote.getRelatedExpenses(id, size: size);
  Future<BudgetModel> create({required int categoryId, required String limitAmount, required DateTime month, String? note}) => _remote.create(categoryId: categoryId, limitAmount: limitAmount, month: month, note: note);
  Future<BudgetModel> update({required int id, required int version, required String limitAmount, String? note}) => _remote.update(id: id, version: version, limitAmount: limitAmount, note: note);
  Future<void> archive({required int id, required int version}) => _remote.archive(id: id, version: version);
}
