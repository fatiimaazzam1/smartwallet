final class ResendVerificationCodeResponseModel {
  const ResendVerificationCodeResponseModel({required this.message});

  final String message;

  factory ResendVerificationCodeResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic messageValue = json['message'];

    if (messageValue is! String || messageValue.trim().isEmpty) {
      throw const FormatException('Invalid resend verification code response.');
    }

    return ResendVerificationCodeResponseModel(message: messageValue.trim());
  }
}
