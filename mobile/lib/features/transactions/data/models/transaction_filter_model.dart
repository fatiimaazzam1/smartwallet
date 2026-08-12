import '../../../categories/data/models/category_model.dart';
import 'transaction_type.dart';

final class TransactionFilterModel {
  const TransactionFilterModel({
    this.type,
    this.category,
    this.startDate,
    this.endDate,
  });

  final TransactionType? type;
  final CategoryModel? category;
  final DateTime? startDate;
  final DateTime? endDate;

  static const TransactionFilterModel empty = TransactionFilterModel();

  bool get isEmpty =>
      type == null && category == null && startDate == null && endDate == null;

  int get activeCount {
    int count = 0;
    if (type != null) {
      count++;
    }
    if (category != null) {
      count++;
    }
    if (startDate != null) {
      count++;
    }
    if (endDate != null) {
      count++;
    }
    return count;
  }

  TransactionFilterModel copyWith({
    TransactionType? type,
    CategoryModel? category,
    DateTime? startDate,
    DateTime? endDate,
    bool clearType = false,
    bool clearCategory = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return TransactionFilterModel(
      type: clearType ? null : type ?? this.type,
      category: clearCategory ? null : category ?? this.category,
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
    );
  }

  bool sameAs(TransactionFilterModel other) {
    return type == other.type &&
        category?.id == other.category?.id &&
        _sameDate(startDate, other.startDate) &&
        _sameDate(endDate, other.endDate);
  }

  static bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return a == b;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
