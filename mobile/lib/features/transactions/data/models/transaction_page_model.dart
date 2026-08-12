import 'transaction_model.dart';

final class TransactionPageModel {
  const TransactionPageModel({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  final List<TransactionModel> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  factory TransactionPageModel.fromJson(Map<String, dynamic> json) {
    final Object? rawContent = json['content'];
    final Object? rawPage = json['page'];
    final Object? rawSize = json['size'];
    final Object? rawTotalElements = json['totalElements'];
    final Object? rawTotalPages = json['totalPages'];
    final Object? rawFirst = json['first'];
    final Object? rawLast = json['last'];

    if (rawContent is! List<dynamic> ||
        rawPage is! num ||
        rawSize is! num ||
        rawTotalElements is! num ||
        rawTotalPages is! num ||
        rawFirst is! bool ||
        rawLast is! bool) {
      throw const FormatException('Invalid transaction page response');
    }

    final List<TransactionModel> content = rawContent.map((dynamic item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid transaction page response');
      }
      return TransactionModel.fromJson(item);
    }).toList(growable: false);

    final int page = rawPage.toInt();
    final int size = rawSize.toInt();
    final int totalElements = rawTotalElements.toInt();
    final int totalPages = rawTotalPages.toInt();

    if (page < 0 ||
        size < 1 ||
        totalElements < 0 ||
        totalPages < 0 ||
        (totalPages == 0 && totalElements != 0)) {
      throw const FormatException('Invalid transaction page response');
    }

    return TransactionPageModel(
      content: content,
      page: page,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
      first: rawFirst,
      last: rawLast,
    );
  }
}
