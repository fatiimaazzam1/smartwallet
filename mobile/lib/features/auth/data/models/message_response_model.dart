final class MessageResponseModel {
  const MessageResponseModel({required this.message});

  final String message;

  factory MessageResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic messageValue = json['message'];

    if (messageValue is! String || messageValue.trim().isEmpty) {
      throw const FormatException('Invalid message response.');
    }

    return MessageResponseModel(message: messageValue.trim());
  }
}
