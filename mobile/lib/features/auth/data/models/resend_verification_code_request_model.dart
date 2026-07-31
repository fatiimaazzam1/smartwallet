final class ResendVerificationCodeRequestModel {
  const ResendVerificationCodeRequestModel({required this.email});

  final String email;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email.trim().toLowerCase()};
  }
}
