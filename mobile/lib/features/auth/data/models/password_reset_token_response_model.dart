final class PasswordResetTokenResponseModel {
  const PasswordResetTokenResponseModel({
    required this.resetToken,
    required this.expiresInSeconds,
  });

  final String resetToken;
  final int expiresInSeconds;

  factory PasswordResetTokenResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic resetTokenValue = json['resetToken'];
    final dynamic expiresInSecondsValue = json['expiresInSeconds'];

    if (resetTokenValue is! String || resetTokenValue.isEmpty) {
      throw const FormatException('Invalid password reset token response.');
    }

    if (expiresInSecondsValue is! int || expiresInSecondsValue <= 0) {
      throw const FormatException('Invalid password reset token expiry.');
    }

    return PasswordResetTokenResponseModel(
      resetToken: resetTokenValue,
      expiresInSeconds: expiresInSecondsValue,
    );
  }
}
