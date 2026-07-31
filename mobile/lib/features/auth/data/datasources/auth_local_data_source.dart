import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/app_exception.dart';

final class AuthLocalDataSource {
  AuthLocalDataSource({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const String _refreshTokenKey = 'smartwallet_refresh_token';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveRefreshToken(String refreshToken) async {
    if (refreshToken.trim().isEmpty) {
      throw const AppException(
        message: 'The received session token is invalid.',
        type: AppExceptionType.unknown,
      );
    }

    try {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } on PlatformException {
      throw const AppException(
        message: 'SmartWallet could not securely save your session.',
        type: AppExceptionType.unknown,
      );
    }
  }

  Future<String?> readRefreshToken() async {
    try {
      final String? refreshToken = await _secureStorage.read(
        key: _refreshTokenKey,
      );

      if (refreshToken == null || refreshToken.trim().isEmpty) {
        return null;
      }

      return refreshToken;
    } on PlatformException {
      throw const AppException(
        message: 'SmartWallet could not securely restore your session.',
        type: AppExceptionType.unknown,
      );
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
    } on PlatformException {
      throw const AppException(
        message: 'SmartWallet could not securely clear your session.',
        type: AppExceptionType.unknown,
      );
    }
  }
}
