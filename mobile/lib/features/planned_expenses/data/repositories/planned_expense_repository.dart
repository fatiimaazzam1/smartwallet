import '../datasources/planned_expense_remote_data_source.dart';
import '../models/planned_expense_model.dart';

final class PlannedExpenseRepository {
  const PlannedExpenseRepository({required PlannedExpenseRemoteDataSource remoteDataSource}):_remote=remoteDataSource;
  final PlannedExpenseRemoteDataSource _remote;
  Future<PlannedExpensePageModel> list({required PlannedExpenseStatus status,required int page,int size=20})=>_remote.list(status:status,page:page,size:size);
  Future<PlannedExpenseModel> get(int id)=>_remote.get(id);
  Future<PlannedExpenseModel> create({required String clientRequestId,required String title,required String amount,required int categoryId,required DateTime dueOn,required PlannedExpenseRecurrence recurrence,String? note})=>_remote.create(clientRequestId:clientRequestId,title:title,amount:amount,categoryId:categoryId,dueOn:dueOn,recurrence:recurrence,note:note);
  Future<PlannedExpenseModel> update({required int id,required int version,required String title,required String amount,required int categoryId,required DateTime dueOn,required PlannedExpenseRecurrence recurrence,String? note})=>_remote.update(id:id,version:version,title:title,amount:amount,categoryId:categoryId,dueOn:dueOn,recurrence:recurrence,note:note);
  Future<PlannedExpenseModel> cancel({required int id,required int version})=>_remote.cancel(id:id,version:version);
  Future<PlannedExpenseModel> markPaid({required int id,required int version,required DateTime paidOn,required String clientRequestId})=>_remote.markPaid(id:id,version:version,paidOn:paidOn,clientRequestId:clientRequestId);
  Future<void> archive({required int id,required int version})=>_remote.archive(id:id,version:version);
}
