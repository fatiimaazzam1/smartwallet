smartwallet_mobile

The project has since been extended into the SmartWallet mobile client for thepersonal-finance application.

Overview

SmartWallet Mobile is a Flutter application connected to the SmartWalletSpring Boot REST API.

The current mobile checkpoint includes:

Onboarding

Registration and email verification

Login and secure session restoration

Forgot-password and password-reset flows

English and Arabic localization

System-language selection with English fallback

Responsive bottom navigation

Authenticated Profile and Edit Profile

User Preferences

Secure logout

Localized validation, status, and error messages

The finance modules for transactions, history, dashboard calculations,budgets, plans, and insights are developed in later milestones.

Technology Stack

Flutter

Dart

Dio

Provider

GoRouter

Flutter Secure Storage

Shared Preferences

Flutter Localizations

Intl

Material Design

Requirements

Before running the mobile application, install:

Flutter SDK

Dart SDK included with Flutter

Android Studio or another supported development environment

Android SDK and platform tools

A connected Android device or configured emulator

A running SmartWallet backend

Verify the Flutter installation with:

flutter doctor

Install Dependencies

From the mobile directory, run:

flutter pub get

Backend Connection

The application reads the backend base URL from the compile-timeAPI_BASE_URL value.

The value must include the protocol and port:

http://<host>:8080

A malformed value such as the following is invalid:

http//192.168.1.100:8080

Real Android Device

The phone and development computer must be connected to the same localnetwork.

Find the computer's local IPv4 address, then run:

flutter run --dart-define=API_BASE_URL=http://<COMPUTER_IPV4>:8080

Example:

flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080

Do not use 127.0.0.1 for a physical phone because that address points to thephone itself.

Android Emulator

For the standard Android emulator, run:

flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

The backend must be running and reachable before API-backed screens aretested.

Localization

SmartWallet uses Flutter's ARB localization workflow.

Configuration:

mobile/l10n.yaml

Translation files:

mobile/lib/l10n/app_en.arb
mobile/lib/l10n/app_ar.arb

Generate the typed localization source with:

flutter gen-l10n

The generated localization source must not be manually edited.

Supported Language Options

SYSTEM
ENGLISH
ARABIC

Behavior:

ENGLISH forces English.

ARABIC forces Arabic and enables right-to-left layout.

SYSTEM follows a supported device language.

Unsupported device languages, such as French, fall back to English.

Visible onboarding, authentication, password-recovery, navigation, Profile,Preferences, validation, dialog, snackbar, loading, and common error text islocalized.

Authentication and Session Security

The application supports:

Registration

Email verification

Verification-code resend

Login

Access-token authentication

Access-token refresh

Session restoration after reopening the app

Forgot-password

Password-reset code verification

Password reset

Secure logout

The access token is held in memory.

The refresh token is stored using Flutter Secure Storage and must never beprinted, logged, committed, or shared.

On logout, the application:

Sends the logout request to the backend.

Uses the securely stored refresh token for revocation.

Deletes the local refresh token.

Clears the in-memory access token.

Clears authenticated Profile state.

Returns the user to Login.

Profile

Authenticated Profile data is loaded from:

GET /api/v1/users/me

The Profile screen displays:

First name

Last name

Email

Initials avatar fallback

The initials use the first character of the first name and the first characterof the last name.

Profile updates use:

PATCH /api/v1/users/me

The current editable fields are:

First name

Last name

The email address is not edited through the Profile endpoint.

Persistent profile-photo upload is not part of this checkpoint. The initialsavatar is the current MVP fallback.

Preferences

Preferences are loaded from:

GET /api/v1/users/me/preferences

Preferences are updated through:

PUT /api/v1/users/me/preferences

Supported settings include:

Hide balance by default

Compact transaction list

Budget warnings

Budget warning threshold

Date format

Dashboard period

Application language

Supported controlled values include:

Budget warning threshold:
70
80
90

Date format:
DD_MM_YYYY
MM_DD_YYYY
YYYY_MM_DD

Dashboard period:
CURRENT_MONTH
LAST_30_DAYS

Language:
SYSTEM
ENGLISH
ARABIC

Preferences are persisted through the backend and remain available after theapplication is reopened.

Bottom Navigation

The authenticated shell contains:

Home
History
Add
Plans
Profile

The center Add action uses the raised SmartWallet action button and keeps thelocalized Add label visible.

At this checkpoint:

Profile and Preferences are functional.

Home is the authenticated starting area.

History, Add, and Plans are navigation foundations for future financemilestones.

Fake backend-backed finance data is not used.

Routing

The application uses GoRouter for onboarding, guest, recovery, andauthenticated navigation.

Protected routes require a valid authenticated session. Guest authenticationroutes redirect authenticated users to the main application area.

Session restoration is resolved during startup without blocking the firstFlutter frame.

Error Handling

Known client and API failures are mapped to localized user-facing messages.

Examples include:

Invalid input

Invalid credentials

Email verification required

Unauthorized or expired session

Network connection failure

Invalid server response

Profile load failure

Preferences load failure

Secure-storage failure

Raw tokens, credentials, Java stack traces, and internal backend details mustnot be shown in the mobile UI or logs.

Testing and Quality Checks

Run static analysis from the mobile directory:

flutter analyze

Run automated tests:

flutter test

Current checkpoint results:

flutter analyze: No issues found
flutter test: 6 tests passed
real Android device functional QA: Passed

The automated localization tests verify:

English and Arabic ARB key parity

Supported locale behavior

System-language fallback behavior

Real-device QA verified:

Application startup with a valid backend URL

Responsive bottom navigation without overflow

Profile data and initials

Profile editing and persistence

Preferences loading, update, and persistence

English and Arabic localization

Secure logout

Correct navigation back to Login

Current Development Status

Onboarding: Complete
Registration: Complete
Email verification: Complete
Login: Complete
Forgot-password flow: Complete
Password-reset flow: Complete
Secure session restoration: Complete
English localization: Complete
Arabic localization and RTL: Complete
System-language fallback: Complete
Bottom navigation shell: Complete
Profile retrieval: Complete
Profile update: Complete
Preferences retrieval and update: Complete
Secure logout: Complete
Profile-photo upload: Deferred enhancement
Transactions and categories: Next finance milestone
History: Planned
Dashboard calculations: Planned
Budgets and plans: Planned
Insights: Planned

## Native Branding

SmartWallet native branding is implemented and verified on a real Android device.

- Visible launcher name: `SWallet`
- Android launcher and adaptive icons: Complete
- Android native splash, including Android 12+: Complete
- iOS launcher icon and native splash: Complete
- In-app brand name: `SmartWallet`
- Brand colors: navy `#0D1B2A`, green `#22C55E`, and white

Branding source assets are stored in `mobile/assets/branding/`.

## Project Structure

```text

mobile/
├── l10n.yaml
├── lib/
│   ├── app/
│   │   └── router/
│   ├── core/
│   │   ├── config/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── localization/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── theme/
│   │   ├── validation/
│   │   └── widgets/
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── navigation/
│   │   ├── onboarding/
│   │   └── profile/
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_ar.arb
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md

Security Rules

Never commit or share:

Passwords
Access tokens
Refresh tokens
Verification codes
Password-reset codes
Password-reset tokens
Backend credentials
JWT signing secrets
SMTP credentials
Database credentials

The Flutter application communicates only with the SmartWallet REST API. Itmust never contain backend private credentials or the JWT signing secret.