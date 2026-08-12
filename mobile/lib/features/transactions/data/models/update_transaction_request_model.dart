import 'dart:convert';

import '../../utils/transaction_decimal.dart';
import '../../utils/transaction_formatters.dart';

final class UpdateTransactionRequestModel {
  const UpdateTransactionRequestModel({
    required this.version,
    required this.amount,
    required this.categoryId,
    required this.occurredOn,
    this.description,
  });

  final int version;
  final String amount;
  final int categoryId;
  final DateTime occurredOn;
  final String? description;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'amount': amount,
      'categoryId': categoryId,
      'occurredOn': TransactionFormatters.toApiDate(occurredOn),
      'description': description,
    };
  }

  String toJsonBody() {
    final String exactAmount = TransactionDecimal.requireValidPositive(amount);
    return '{'
        '"version":$version,'
        '"amount":$exactAmount,'
        '"categoryId":$categoryId,'
        '"occurredOn":${jsonEncode(TransactionFormatters.toApiDate(occurredOn))},'
        '"description":${jsonEncode(description)}'
        '}';
  }
}
