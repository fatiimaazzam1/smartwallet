import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SmartWallet'**
  String get appTitle;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @returnToLogin.
  ///
  /// In en, this message translates to:
  /// **'Return to Login'**
  String get returnToLogin;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully.'**
  String get saved;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameHint;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Use 8–72 characters with uppercase, lowercase, number, and special character.'**
  String get passwordRequirements;

  /// No description provided for @genericUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Please try again.'**
  String get genericUnexpectedError;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to SmartWallet. Check your internet connection and try again.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get timeoutError;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'Your session is no longer valid. Please log in again.'**
  String get unauthorizedError;

  /// No description provided for @forbiddenError.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to perform this action.'**
  String get forbiddenError;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Please check the submitted information.'**
  String get validationError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'SmartWallet is temporarily unavailable. Please try again later.'**
  String get serverError;

  /// No description provided for @takeControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Take control of your money.'**
  String get takeControlTitle;

  /// No description provided for @takeControlSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your spending, plan ahead, and understand what is safe to spend.'**
  String get takeControlSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue managing your money with confidence.'**
  String get loginSubtitle;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Do not have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start managing your money with confidence.'**
  String get registerSubtitle;

  /// No description provided for @createSecurePassword.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password'**
  String get createSecurePassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the password again'**
  String get confirmPasswordHint;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @verificationSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a six-digit verification code to'**
  String get verificationSentTo;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verificationCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required.'**
  String get verificationCodeRequired;

  /// No description provided for @enterSixDigitVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit verification code.'**
  String get enterSixDigitVerificationCode;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @didNotReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Did not receive the code?'**
  String get didNotReceiveCode;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @verificationCodeResent.
  ///
  /// In en, this message translates to:
  /// **'A new verification code was sent.'**
  String get verificationCodeResent;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address. If the account is eligible, we will send a six-digit reset code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Code'**
  String get sendResetCode;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @resetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'If the account is eligible, a reset code was sent.'**
  String get resetCodeSent;

  /// No description provided for @verifyResetCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Reset Code'**
  String get verifyResetCode;

  /// No description provided for @resetCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit reset code if one was sent for'**
  String get resetCodeSubtitle;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset Code'**
  String get resetCode;

  /// No description provided for @resetCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Reset code is required.'**
  String get resetCodeRequired;

  /// No description provided for @enterSixDigitResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the six-digit reset code.'**
  String get enterSixDigitResetCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @resetCodeResent.
  ///
  /// In en, this message translates to:
  /// **'A new reset code was sent if the account is eligible.'**
  String get resetCodeResent;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @createNewPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password that you have not shared with anyone.'**
  String get createNewPasswordSubtitle;

  /// No description provided for @resetSessionLessThanMinute.
  ///
  /// In en, this message translates to:
  /// **'This secure reset session expires in less than one minute.'**
  String get resetSessionLessThanMinute;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again'**
  String get confirmNewPasswordHint;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your password was reset successfully. Log in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @preparingSmartWallet.
  ///
  /// In en, this message translates to:
  /// **'Preparing SmartWallet...'**
  String get preparingSmartWallet;

  /// No description provided for @unableRestoreSession.
  ///
  /// In en, this message translates to:
  /// **'Unable to Restore Session'**
  String get unableRestoreSession;

  /// No description provided for @restoreSessionError.
  ///
  /// In en, this message translates to:
  /// **'SmartWallet could not restore your session. Please try again.'**
  String get restoreSessionError;

  /// No description provided for @emailMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Address Missing'**
  String get emailMissingTitle;

  /// No description provided for @verificationEmailMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Return to Login and enter your account email again.'**
  String get verificationEmailMissingMessage;

  /// No description provided for @passwordRecoveryEmailMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Return to Login and start password recovery again.'**
  String get passwordRecoveryEmailMissingMessage;

  /// No description provided for @resetSessionMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Session Missing'**
  String get resetSessionMissingTitle;

  /// No description provided for @resetSessionMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'For your security, return to Login and request a new password reset code.'**
  String get resetSessionMissingMessage;

  /// No description provided for @navigationError.
  ///
  /// In en, this message translates to:
  /// **'This page could not be opened.'**
  String get navigationError;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SmartWallet'**
  String get homeWelcome;

  /// No description provided for @homeSessionActive.
  ///
  /// In en, this message translates to:
  /// **'Your secure session is active.'**
  String get homeSessionActive;

  /// No description provided for @authenticationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Authentication Successful'**
  String get authenticationSuccessful;

  /// No description provided for @authenticationSuccessfulBody.
  ///
  /// In en, this message translates to:
  /// **'Registration, email verification, and login can now navigate to this authenticated area.'**
  String get authenticationSuccessfulBody;

  /// No description provided for @dashboardComingBody.
  ///
  /// In en, this message translates to:
  /// **'The real dashboard, wallet summary, transactions, budgets, and spending insights will be added in the next milestones.'**
  String get dashboardComingBody;

  /// No description provided for @historyComingTitle.
  ///
  /// In en, this message translates to:
  /// **'History is coming next'**
  String get historyComingTitle;

  /// No description provided for @historyComingBody.
  ///
  /// In en, this message translates to:
  /// **'Transaction history will appear here after Income and Expense features are implemented.'**
  String get historyComingBody;

  /// No description provided for @plansComingTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans are coming next'**
  String get plansComingTitle;

  /// No description provided for @plansComingBody.
  ///
  /// In en, this message translates to:
  /// **'Budgets and financial plans will appear here in a later milestone.'**
  String get plansComingBody;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionTitle;

  /// No description provided for @addTransactionBody.
  ///
  /// In en, this message translates to:
  /// **'Income and expense entry will be implemented in the next finance milestone.'**
  String get addTransactionBody;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your profile could not be loaded.'**
  String get profileLoadError;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profileDetails;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @categoriesComing.
  ///
  /// In en, this message translates to:
  /// **'Category management is available from Profile.'**
  String get categoriesComing;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutBody;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirm;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your profile was updated successfully.'**
  String get profileUpdated;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the name displayed on your SmartWallet account.'**
  String get editProfileSubtitle;

  /// No description provided for @emailCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Your email address cannot be changed here.'**
  String get emailCannotChange;

  /// No description provided for @preferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how SmartWallet should display and organize your information.'**
  String get preferencesSubtitle;

  /// No description provided for @displaySection.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get displaySection;

  /// No description provided for @budgetSection.
  ///
  /// In en, this message translates to:
  /// **'Budget Warnings'**
  String get budgetSection;

  /// No description provided for @formatSection.
  ///
  /// In en, this message translates to:
  /// **'Dates and Dashboard'**
  String get formatSection;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @hideBalance.
  ///
  /// In en, this message translates to:
  /// **'Hide balance by default'**
  String get hideBalance;

  /// No description provided for @hideBalanceBody.
  ///
  /// In en, this message translates to:
  /// **'Hide sensitive balance amounts when a screen opens.'**
  String get hideBalanceBody;

  /// No description provided for @compactTransactions.
  ///
  /// In en, this message translates to:
  /// **'Compact transaction list'**
  String get compactTransactions;

  /// No description provided for @compactTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'Use less vertical space for transaction rows.'**
  String get compactTransactionsBody;

  /// No description provided for @showBudgetWarnings.
  ///
  /// In en, this message translates to:
  /// **'Show budget warnings'**
  String get showBudgetWarnings;

  /// No description provided for @showBudgetWarningsBody.
  ///
  /// In en, this message translates to:
  /// **'Warn when spending reaches the selected threshold.'**
  String get showBudgetWarningsBody;

  /// No description provided for @warningThreshold.
  ///
  /// In en, this message translates to:
  /// **'Warning threshold'**
  String get warningThreshold;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateFormat;

  /// No description provided for @dashboardPeriod.
  ///
  /// In en, this message translates to:
  /// **'Dashboard period'**
  String get dashboardPeriod;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @arabicLanguage.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabicLanguage;

  /// No description provided for @systemLanguageHelp.
  ///
  /// In en, this message translates to:
  /// **'System follows Arabic or English when supported. Other device languages use English.'**
  String get systemLanguageHelp;

  /// No description provided for @currentMonth.
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get currentMonth;

  /// No description provided for @lastThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get lastThirtyDays;

  /// No description provided for @preferencesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your preferences were updated successfully.'**
  String get preferencesUpdated;

  /// No description provided for @retryLoad.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLoad;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @emailTooLong.
  ///
  /// In en, this message translates to:
  /// **'Email must not exceed 150 characters'**
  String get emailTooLong;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be between 8 and 72 characters'**
  String get passwordLength;

  /// No description provided for @passwordNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'Password must not contain spaces'**
  String get passwordNoSpaces;

  /// No description provided for @passwordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a lowercase letter'**
  String get passwordLowercase;

  /// No description provided for @passwordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter'**
  String get passwordUppercase;

  /// No description provided for @passwordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a number'**
  String get passwordNumber;

  /// No description provided for @passwordSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain a special character'**
  String get passwordSpecial;

  /// Validation message for an empty required field.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required.'**
  String requiredField(String fieldName);

  /// Validation message for minimum character count.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must contain at least {count} characters.'**
  String minimumCharacters(String fieldName, int count);

  /// Countdown before a verification or reset code can be resent.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String resendIn(int seconds);

  /// Approximate reset-session expiry in minutes.
  ///
  /// In en, this message translates to:
  /// **'This secure reset session expires in about {minutes, plural, =1{one minute} other{{minutes} minutes}}.'**
  String resetSessionExpiry(int minutes);

  /// Greeting using the user first name.
  ///
  /// In en, this message translates to:
  /// **'Hello, {firstName}'**
  String greetingName(String firstName);

  /// No description provided for @conflictError.
  ///
  /// In en, this message translates to:
  /// **'This request conflicts with existing information.'**
  String get conflictError;

  /// No description provided for @invalidCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get invalidCredentialsError;

  /// No description provided for @accountDisabledError.
  ///
  /// In en, this message translates to:
  /// **'This account is disabled.'**
  String get accountDisabledError;

  /// No description provided for @emailAlreadyRegisteredError.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for this email address.'**
  String get emailAlreadyRegisteredError;

  /// No description provided for @invalidOrExpiredCodeError.
  ///
  /// In en, this message translates to:
  /// **'The code is invalid or expired. Request a new code and try again.'**
  String get invalidOrExpiredCodeError;

  /// No description provided for @tooManyAttemptsError.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Request a new code.'**
  String get tooManyAttemptsError;

  /// No description provided for @cooldownError.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting another code.'**
  String get cooldownError;

  /// No description provided for @requestCancelledError.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled.'**
  String get requestCancelledError;

  /// No description provided for @secureStorageError.
  ///
  /// In en, this message translates to:
  /// **'SmartWallet could not access secure session storage.'**
  String get secureStorageError;

  /// No description provided for @invalidServerResponseError.
  ///
  /// In en, this message translates to:
  /// **'SmartWallet received an invalid server response.'**
  String get invalidServerResponseError;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use default categories or add your own for future income and expense transactions.'**
  String get manageCategoriesSubtitle;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @createCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a category that will appear in the matching income or expense list.'**
  String get createCategorySubtitle;

  /// No description provided for @categoryType.
  ///
  /// In en, this message translates to:
  /// **'Category Type'**
  String get categoryType;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pet Care'**
  String get categoryNameHint;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required.'**
  String get categoryNameRequired;

  /// No description provided for @saveCategory.
  ///
  /// In en, this message translates to:
  /// **'Save Category'**
  String get saveCategory;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @defaultCategory.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultCategory;

  /// No description provided for @customCategory.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customCategory;

  /// No description provided for @categoryActions.
  ///
  /// In en, this message translates to:
  /// **'Category actions'**
  String get categoryActions;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// Confirmation before archiving a custom category.
  ///
  /// In en, this message translates to:
  /// **'{categoryName} will no longer be available for new transactions. Existing transaction history will stay unchanged.'**
  String deleteCategoryBody(String categoryName);

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully.'**
  String get categoryCreated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully.'**
  String get categoryDeleted;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategories;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories are available right now.'**
  String get noCategoriesAvailable;

  /// No description provided for @noCategorySearchResults.
  ///
  /// In en, this message translates to:
  /// **'No categories match your search.'**
  String get noCategorySearchResults;

  /// No description provided for @selectIncomeCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Income Category'**
  String get selectIncomeCategory;

  /// No description provided for @selectExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Expense Category'**
  String get selectExpenseCategory;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get addNewCategory;

  /// No description provided for @categoryAlreadyExistsError.
  ///
  /// In en, this message translates to:
  /// **'A category with this name already exists for this type.'**
  String get categoryAlreadyExistsError;

  /// No description provided for @defaultCategoryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Default categories cannot be deleted.'**
  String get defaultCategoryDeleteError;

  /// No description provided for @categoryNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This category is no longer available.'**
  String get categoryNotFoundError;

  /// No description provided for @walletNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Your wallet could not be found.'**
  String get walletNotFoundError;

  /// No description provided for @walletOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your wallet overview'**
  String get walletOverviewSubtitle;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @showBalance.
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get showBalance;

  /// No description provided for @balanceHidden.
  ///
  /// In en, this message translates to:
  /// **'Balance hidden'**
  String get balanceHidden;

  /// No description provided for @walletReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet and categories are ready'**
  String get walletReadyTitle;

  /// No description provided for @walletReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your balance is connected to the backend. Income, expenses, and Safe to Spend will update from real transactions in the next phase.'**
  String get walletReadyBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
