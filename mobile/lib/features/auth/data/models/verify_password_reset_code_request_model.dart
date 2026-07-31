final class VerifyPasswordResetCodeRequestModel {
  const VerifyPasswordResetCodeRequestModel({
    required this.email,
    required this.code,
  });

  final String email;
  final String code;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'code': code.trim(),
    };
  }
}
