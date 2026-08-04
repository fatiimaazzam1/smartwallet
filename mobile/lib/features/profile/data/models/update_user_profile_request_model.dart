final class UpdateUserProfileRequestModel {
  const UpdateUserProfileRequestModel({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
    };
  }
}
