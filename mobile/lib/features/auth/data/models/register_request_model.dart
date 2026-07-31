final class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}
