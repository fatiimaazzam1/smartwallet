final class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final String firstInitial = _firstCharacter(firstName);
    final String lastInitial = _firstCharacter(lastName);
    final String value = '$firstInitial$lastInitial'.trim();
    return value.isEmpty ? '?' : value.toUpperCase();
  }

  UserProfileModel copyWith({String? firstName, String? lastName}) {
    return UserProfileModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'];
    final dynamic firstNameValue = json['firstName'];
    final dynamic lastNameValue = json['lastName'];
    final dynamic emailValue = json['email'];

    if (idValue is! num ||
        firstNameValue is! String ||
        lastNameValue is! String ||
        emailValue is! String) {
      throw const FormatException('Invalid user profile response.');
    }

    return UserProfileModel(
      id: idValue.toInt(),
      firstName: firstNameValue.trim(),
      lastName: lastNameValue.trim(),
      email: emailValue.trim(),
    );
  }

  static String _firstCharacter(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return String.fromCharCode(trimmed.runes.first);
  }
}
