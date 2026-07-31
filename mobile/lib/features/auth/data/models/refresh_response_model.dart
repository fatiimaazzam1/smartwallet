final class RefreshResponseModel {
  const RefreshResponseModel({required this.accessToken});

  final String accessToken;

  factory RefreshResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic accessTokenValue = json['accessToken'];

    if (accessTokenValue is! String || accessTokenValue.isEmpty) {
      throw const FormatException('Invalid access token in refresh response.');
    }

    return RefreshResponseModel(accessToken: accessTokenValue);
  }
}
