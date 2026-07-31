final class ResetPasswordRequestModel {
  const ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
    required this.confirmPassword,
  });

  final String resetToken;
  final String newPassword;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'resetToken': resetToken,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
