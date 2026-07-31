final class VerifyEmailResponseModel {
  const VerifyEmailResponseModel({required this.message});

  final String message;

  factory VerifyEmailResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic messageValue = json['message'];

    if (messageValue is! String || messageValue.trim().isEmpty) {
      throw const FormatException('Invalid verify email response.');
    }

    return VerifyEmailResponseModel(message: messageValue.trim());
  }
}
