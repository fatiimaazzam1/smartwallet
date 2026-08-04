abstract final class ApiEndpoints {
  ApiEndpoints._();

  static const String authBase = '/api/v1/auth';
  static const String usersBase = '/api/v1/users';

  static const String register = '$authBase/register';
  static const String verifyEmail = '$authBase/verify-email';
  static const String resendVerificationCode =
      '$authBase/resend-verification-code';

  static const String login = '$authBase/login';
  static const String refresh = '$authBase/refresh';
  static const String logout = '$authBase/logout';

  static const String forgotPassword = '$authBase/forgot-password';

  static const String resendPasswordResetCode =
      '$authBase/resend-password-reset-code';

  static const String verifyPasswordResetCode =
      '$authBase/verify-password-reset-code';

  static const String resetPassword = '$authBase/reset-password';

  static const String currentUser = '$usersBase/me';
  static const String currentUserPreferences = '$currentUser/preferences';
}
