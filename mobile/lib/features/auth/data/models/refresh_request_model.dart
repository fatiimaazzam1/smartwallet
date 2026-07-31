final class RefreshRequestModel {
  const RefreshRequestModel({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'refreshToken': refreshToken};
  }
}
