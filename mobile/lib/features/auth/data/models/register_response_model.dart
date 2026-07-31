final class RegisterResponseModel {
  const RegisterResponseModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.message,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String message;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'];
    final dynamic firstNameValue = json['firstName'];
    final dynamic lastNameValue = json['lastName'];
    final dynamic emailValue = json['email'];
    final dynamic messageValue = json['message'];

    if (idValue is! num) {
      throw const FormatException(
        'Invalid account id in registration response.',
      );
    }

    if (firstNameValue is! String || firstNameValue.trim().isEmpty) {
      throw const FormatException(
        'Invalid first name in registration response.',
      );
    }

    if (lastNameValue is! String || lastNameValue.trim().isEmpty) {
      throw const FormatException(
        'Invalid last name in registration response.',
      );
    }

    if (emailValue is! String || emailValue.trim().isEmpty) {
      throw const FormatException('Invalid email in registration response.');
    }

    if (messageValue is! String || messageValue.trim().isEmpty) {
      throw const FormatException('Invalid message in registration response.');
    }

    return RegisterResponseModel(
      id: idValue.toInt(),
      firstName: firstNameValue.trim(),
      lastName: lastNameValue.trim(),
      email: emailValue.trim().toLowerCase(),
      message: messageValue.trim(),
    );
  }
}
