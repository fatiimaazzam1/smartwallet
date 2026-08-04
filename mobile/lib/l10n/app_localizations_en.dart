// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartWallet';

  @override
  String get goBack => 'Go back';

  @override
  String get returnToLogin => 'Return to Login';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved successfully.';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading...';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get firstNameHint => 'First name';

  @override
  String get lastNameHint => 'Last name';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordRequirements =>
      'Use 8–72 characters with uppercase, lowercase, number, and special character.';

  @override
  String get genericUnexpectedError =>
      'Something unexpected happened. Please try again.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get networkError =>
      'Unable to connect to SmartWallet. Check your internet connection and try again.';

  @override
  String get timeoutError => 'The request took too long. Please try again.';

  @override
  String get unauthorizedError =>
      'Your session is no longer valid. Please log in again.';

  @override
  String get forbiddenError => 'You are not allowed to perform this action.';

  @override
  String get validationError => 'Please check the submitted information.';

  @override
  String get serverError =>
      'SmartWallet is temporarily unavailable. Please try again later.';

  @override
  String get takeControlTitle => 'Take control of your money.';

  @override
  String get takeControlSubtitle =>
      'Track your spending, plan ahead, and understand what is safe to spend.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log in';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginSubtitle =>
      'Log in to continue managing your money with confidence.';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPasswordQuestion => 'Forgot Password?';

  @override
  String get logInButton => 'Log In';

  @override
  String get noAccount => 'Do not have an account?';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Start managing your money with confidence.';

  @override
  String get createSecurePassword => 'Create a secure password';

  @override
  String get confirmPasswordHint => 'Enter the password again';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get verificationSentTo => 'We sent a six-digit verification code to';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get verificationCodeRequired => 'Verification code is required.';

  @override
  String get enterSixDigitVerificationCode =>
      'Enter the six-digit verification code.';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get didNotReceiveCode => 'Did not receive the code?';

  @override
  String get sending => 'Sending...';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get verificationCodeResent => 'A new verification code was sent.';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address. If the account is eligible, we will send a six-digit reset code.';

  @override
  String get sendResetCode => 'Send Reset Code';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetCodeSent =>
      'If the account is eligible, a reset code was sent.';

  @override
  String get verifyResetCode => 'Verify Reset Code';

  @override
  String get resetCodeSubtitle =>
      'Enter the six-digit reset code if one was sent for';

  @override
  String get resetCode => 'Reset Code';

  @override
  String get resetCodeRequired => 'Reset code is required.';

  @override
  String get enterSixDigitResetCode => 'Enter the six-digit reset code.';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String get resetCodeResent =>
      'A new reset code was sent if the account is eligible.';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get createNewPasswordSubtitle =>
      'Choose a strong password that you have not shared with anyone.';

  @override
  String get resetSessionLessThanMinute =>
      'This secure reset session expires in less than one minute.';

  @override
  String get newPassword => 'New Password';

  @override
  String get newPasswordHint => 'Enter your new password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get confirmNewPasswordHint => 'Enter the new password again';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get passwordResetSuccess =>
      'Your password was reset successfully. Log in with your new password.';

  @override
  String get preparingSmartWallet => 'Preparing SmartWallet...';

  @override
  String get unableRestoreSession => 'Unable to Restore Session';

  @override
  String get restoreSessionError =>
      'SmartWallet could not restore your session. Please try again.';

  @override
  String get emailMissingTitle => 'Email Address Missing';

  @override
  String get verificationEmailMissingMessage =>
      'Return to Login and enter your account email again.';

  @override
  String get passwordRecoveryEmailMissingMessage =>
      'Return to Login and start password recovery again.';

  @override
  String get resetSessionMissingTitle => 'Reset Session Missing';

  @override
  String get resetSessionMissingMessage =>
      'For your security, return to Login and request a new password reset code.';

  @override
  String get navigationError => 'This page could not be opened.';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get add => 'Add';

  @override
  String get plans => 'Plans';

  @override
  String get profile => 'Profile';

  @override
  String get homeWelcome => 'Welcome to SmartWallet';

  @override
  String get homeSessionActive => 'Your secure session is active.';

  @override
  String get authenticationSuccessful => 'Authentication Successful';

  @override
  String get authenticationSuccessfulBody =>
      'Registration, email verification, and login can now navigate to this authenticated area.';

  @override
  String get dashboardComingBody =>
      'The real dashboard, wallet summary, transactions, budgets, and spending insights will be added in the next milestones.';

  @override
  String get historyComingTitle => 'History is coming next';

  @override
  String get historyComingBody =>
      'Transaction history will appear here after Income and Expense features are implemented.';

  @override
  String get plansComingTitle => 'Plans are coming next';

  @override
  String get plansComingBody =>
      'Budgets and financial plans will appear here in a later milestone.';

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get addTransactionBody =>
      'Income and expense entry will be implemented in the next finance milestone.';

  @override
  String get profileLoadError => 'Your profile could not be loaded.';

  @override
  String get profileDetails => 'Profile Details';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get preferences => 'Preferences';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get categoriesComing =>
      'Category management will be available with the Income and Expense feature.';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutTitle => 'Log Out?';

  @override
  String get logoutBody => 'Are you sure you want to log out of your account?';

  @override
  String get logoutConfirm => 'Log Out';

  @override
  String get profileUpdated => 'Your profile was updated successfully.';

  @override
  String get editProfileSubtitle =>
      'Update the name displayed on your SmartWallet account.';

  @override
  String get emailCannotChange => 'Your email address cannot be changed here.';

  @override
  String get preferencesSubtitle =>
      'Choose how SmartWallet should display and organize your information.';

  @override
  String get displaySection => 'Display';

  @override
  String get budgetSection => 'Budget Warnings';

  @override
  String get formatSection => 'Dates and Dashboard';

  @override
  String get languageSection => 'Language';

  @override
  String get hideBalance => 'Hide balance by default';

  @override
  String get hideBalanceBody =>
      'Hide sensitive balance amounts when a screen opens.';

  @override
  String get compactTransactions => 'Compact transaction list';

  @override
  String get compactTransactionsBody =>
      'Use less vertical space for transaction rows.';

  @override
  String get showBudgetWarnings => 'Show budget warnings';

  @override
  String get showBudgetWarningsBody =>
      'Warn when spending reaches the selected threshold.';

  @override
  String get warningThreshold => 'Warning threshold';

  @override
  String get dateFormat => 'Date format';

  @override
  String get dashboardPeriod => 'Dashboard period';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System';

  @override
  String get englishLanguage => 'English';

  @override
  String get arabicLanguage => 'Arabic';

  @override
  String get systemLanguageHelp =>
      'System follows Arabic or English when supported. Other device languages use English.';

  @override
  String get currentMonth => 'Current month';

  @override
  String get lastThirtyDays => 'Last 30 days';

  @override
  String get preferencesUpdated =>
      'Your preferences were updated successfully.';

  @override
  String get retryLoad => 'Retry';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get emailTooLong => 'Email must not exceed 150 characters';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordLength => 'Password must be between 8 and 72 characters';

  @override
  String get passwordNoSpaces => 'Password must not contain spaces';

  @override
  String get passwordLowercase => 'Password must contain a lowercase letter';

  @override
  String get passwordUppercase => 'Password must contain an uppercase letter';

  @override
  String get passwordNumber => 'Password must contain a number';

  @override
  String get passwordSpecial => 'Password must contain a special character';

  @override
  String requiredField(String fieldName) {
    return '$fieldName is required.';
  }

  @override
  String minimumCharacters(String fieldName, int count) {
    return '$fieldName must contain at least $count characters.';
  }

  @override
  String resendIn(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String resetSessionExpiry(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: 'one minute',
    );
    return 'This secure reset session expires in about $_temp0.';
  }

  @override
  String greetingName(String firstName) {
    return 'Hello, $firstName';
  }

  @override
  String get conflictError =>
      'This request conflicts with existing information.';

  @override
  String get invalidCredentialsError => 'Incorrect email or password.';

  @override
  String get accountDisabledError => 'This account is disabled.';

  @override
  String get emailAlreadyRegisteredError =>
      'An account already exists for this email address.';

  @override
  String get invalidOrExpiredCodeError =>
      'The code is invalid or expired. Request a new code and try again.';

  @override
  String get tooManyAttemptsError =>
      'Too many incorrect attempts. Request a new code.';

  @override
  String get cooldownError => 'Please wait before requesting another code.';

  @override
  String get requestCancelledError => 'The request was cancelled.';

  @override
  String get secureStorageError =>
      'SmartWallet could not access secure session storage.';

  @override
  String get invalidServerResponseError =>
      'SmartWallet received an invalid server response.';
}
