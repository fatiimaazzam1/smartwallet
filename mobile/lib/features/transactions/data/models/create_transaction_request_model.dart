import 'dart:convert';

import '../../utils/transaction_decimal.dart';
import '../../utils/transaction_formatters.dart';
import 'transaction_type.dart';

final class CreateTransactionRequestModel {
  const CreateTransactionRequestModel({
    required this.clientRequestId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.occurredOn,
    this.description,
  });

  final String clientRequestId;
  final TransactionType type;
  final String amount;
  final int categoryId;
  final DateTime occurredOn;
  final String? description;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'clientRequestId': clientRequestId,
      'type': type.apiValue,
      'amount': amount,
      'categoryId': categoryId,
      'occurredOn': TransactionFormatters.toApiDate(occurredOn),
      'description': description,
    };
  }

  /// Builds the request body with `amount` as an exact JSON number rather than
  /// converting it through a Dart double. All string values still go through
  /// jsonEncode, and the amount is inserted only after strict decimal checks.
  String toJsonBody() {
    final String exactAmount = TransactionDecimal.requireValidPositive(amount);
    return '{'
        '"clientRequestId":${jsonEncode(clientRequestId)},'
        '"type":${jsonEncode(type.apiValue)},'
        '"amount":$exactAmount,'
        '"categoryId":$categoryId,'
        '"occurredOn":${jsonEncode(TransactionFormatters.toApiDate(occurredOn))},'
        '"description":${jsonEncode(description)}'
        '}';
  }
}
