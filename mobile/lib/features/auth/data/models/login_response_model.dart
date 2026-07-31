final class LoginResponseModel {
  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic accessTokenValue = json['accessToken'];
    final dynamic refreshTokenValue = json['refreshToken'];

    if (accessTokenValue is! String || accessTokenValue.trim().isEmpty) {
      throw const FormatException('Invalid access token in login response.');
    }

    if (refreshTokenValue is! String || refreshTokenValue.trim().isEmpty) {
      throw const FormatException('Invalid refresh token in login response.');
    }

    return LoginResponseModel(
      accessToken: accessTokenValue,
      refreshToken: refreshTokenValue,
    );
  }
}
