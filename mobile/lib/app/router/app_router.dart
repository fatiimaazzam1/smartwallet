import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/localized_error_message.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../../core/storage/onboarding_storage.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/auth/data/models/password_reset_token_response_model.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/forgot_password_controller.dart';
import '../../features/auth/presentation/controllers/login_controller.dart';
import '../../features/auth/presentation/controllers/register_controller.dart';
import '../../features/auth/presentation/controllers/reset_password_controller.dart';
import '../../features/auth/presentation/controllers/verify_email_controller.dart';
import '../../features/auth/presentation/controllers/verify_password_reset_code_controller.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/verify_password_reset_code_screen.dart';
import '../../features/categories/data/repositories/category_repository.dart';
import '../../features/categories/presentation/controllers/category_controller.dart';
import '../../features/categories/presentation/screens/manage_categories_screen.dart';
import '../../features/navigation/presentation/screens/main_shell_screen.dart';
import '../../features/onboarding/presentation/screens/get_started_screen.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/preferences_screen.dart';
import '../../features/wallet/presentation/controllers/wallet_controller.dart';
import 'app_routes.dart';

final class AppRouter {
  AppRouter({
    required OnboardingStorage onboardingStorage,
    required AuthRepository authRepository,
    required ProfileController profileController,
    required WalletController walletController,
    required CategoryRepository categoryRepository,
  }) : _onboardingStorage = onboardingStorage,
       _authRepository = authRepository,
       _profileController = profileController,
       _walletController = walletController,
       _categoryRepository = categoryRepository {
    router = GoRouter(
      initialLocation: AppRoutes.startupPath,
      redirect: _redirect,
      routes: _buildRoutes(),
      errorBuilder: (BuildContext context, GoRouterState state) {
        return _NavigationErrorScreen(
          onReturnToLogin: () => context.goNamed(AppRoutes.loginName),
        );
      },
    );
  }

  final OnboardingStorage _onboardingStorage;
  final AuthRepository _authRepository;
  final ProfileController _profileController;
  final WalletController _walletController;
  final CategoryRepository _categoryRepository;

  late final GoRouter router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final String location = state.matchedLocation;

    final bool isProtectedRoute =
        location == AppRoutes.homePath ||
        location == AppRoutes.editProfilePath ||
        location == AppRoutes.preferencesPath ||
        location == AppRoutes.categoriesPath;

    if (isProtectedRoute && !_authRepository.hasAccessToken) {
      return AppRoutes.loginPath;
    }

    final bool isGuestRoute =
        location == AppRoutes.getStartedPath ||
        location == AppRoutes.registerPath ||
        location == AppRoutes.verifyEmailPath ||
        location == AppRoutes.loginPath ||
        location == AppRoutes.forgotPasswordPath ||
        location == AppRoutes.verifyResetCodePath ||
        location == AppRoutes.resetPasswordPath;

    if (_authRepository.hasAccessToken && isGuestRoute) {
      return AppRoutes.homePath;
    }

    return null;
  }

  List<RouteBase> _buildRoutes() {
    return <RouteBase>[
      GoRoute(
        name: AppRoutes.startupName,
        path: AppRoutes.startupPath,
        builder: (BuildContext context, GoRouterState state) {
          return _StartupScreen(
            onboardingStorage: _onboardingStorage,
            authRepository: _authRepository,
          );
        },
      ),
      GoRoute(
        name: AppRoutes.getStartedName,
        path: AppRoutes.getStartedPath,
        builder: (BuildContext context, GoRouterState state) {
          return GetStartedScreen(
            onGetStarted: () async {
              await _onboardingStorage.markOnboardingAsSeen();
              if (context.mounted) {
                context.pushNamed(AppRoutes.registerName);
              }
            },
            onLogin: () async {
              await _onboardingStorage.markOnboardingAsSeen();
              if (context.mounted) {
                context.goNamed(AppRoutes.loginName);
              }
            },
          );
        },
      ),
      GoRoute(
        name: AppRoutes.registerName,
        path: AppRoutes.registerPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<RegisterController>(
            create: (_) => RegisterController(authRepository: _authRepository),
            child: RegisterScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.loginName);
                }
              },
              onLogin: () => context.goNamed(AppRoutes.loginName),
              onRegistrationSuccess: (String email) {
                context.goNamed(AppRoutes.verifyEmailName, extra: email);
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.verifyEmailName,
        path: AppRoutes.verifyEmailPath,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;

          if (extra is! String || extra.trim().isEmpty) {
            return _MissingDataScreen(
              title: (AppLocalizations l10n) => l10n.emailMissingTitle,
              message: (AppLocalizations l10n) =>
                  l10n.verificationEmailMissingMessage,
              onReturnToLogin: () =>
                  context.goNamed(AppRoutes.loginName),
            );
          }

          final String email = extra.trim().toLowerCase();

          return ChangeNotifierProvider<VerifyEmailController>(
            create: (_) =>
                VerifyEmailController(authRepository: _authRepository),
            child: VerifyEmailScreen(
              email: email,
              onBack: () => context.goNamed(AppRoutes.loginName),
              onVerificationSuccess: () =>
                  context.goNamed(AppRoutes.loginName),
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.loginName,
        path: AppRoutes.loginPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<LoginController>(
            create: (_) => LoginController(authRepository: _authRepository),
            child: LoginScreen(
              onLoginSuccess: () => context.goNamed(AppRoutes.homeName),
              onEmailVerificationRequired: (String email) {
                context.goNamed(AppRoutes.verifyEmailName, extra: email);
              },
              onForgotPassword: () {
                context.pushNamed(AppRoutes.forgotPasswordName);
              },
              onRegister: () => context.pushNamed(AppRoutes.registerName),
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.forgotPasswordName,
        path: AppRoutes.forgotPasswordPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<ForgotPasswordController>(
            create: (_) =>
                ForgotPasswordController(authRepository: _authRepository),
            child: ForgotPasswordScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.loginName);
                }
              },
              onRequestSuccess: (String email) {
                context.pushNamed(AppRoutes.verifyResetCodeName, extra: email);
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.verifyResetCodeName,
        path: AppRoutes.verifyResetCodePath,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;

          if (extra is! String || extra.trim().isEmpty) {
            return _MissingDataScreen(
              title: (AppLocalizations l10n) => l10n.emailMissingTitle,
              message: (AppLocalizations l10n) =>
                  l10n.passwordRecoveryEmailMissingMessage,
              onReturnToLogin: () =>
                  context.goNamed(AppRoutes.loginName),
            );
          }

          final String email = extra.trim().toLowerCase();

          return ChangeNotifierProvider<VerifyPasswordResetCodeController>(
            create: (_) => VerifyPasswordResetCodeController(
              authRepository: _authRepository,
            ),
            child: VerifyPasswordResetCodeScreen(
              email: email,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.loginName);
                }
              },
              onVerificationSuccess:
                  (PasswordResetTokenResponseModel resetSession) {
                    context.pushReplacementNamed(
                      AppRoutes.resetPasswordName,
                      extra: resetSession,
                    );
                  },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.resetPasswordName,
        path: AppRoutes.resetPasswordPath,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;

          if (extra is! PasswordResetTokenResponseModel ||
              extra.resetToken.isEmpty ||
              extra.expiresInSeconds <= 0) {
            return _MissingDataScreen(
              title: (AppLocalizations l10n) =>
                  l10n.resetSessionMissingTitle,
              message: (AppLocalizations l10n) =>
                  l10n.resetSessionMissingMessage,
              onReturnToLogin: () =>
                  context.goNamed(AppRoutes.loginName),
            );
          }

          return ChangeNotifierProvider<ResetPasswordController>(
            create: (_) =>
                ResetPasswordController(authRepository: _authRepository),
            child: ResetPasswordScreen(
              resetSession: extra,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.loginName);
                }
              },
              onResetSuccess: () {
                final ScaffoldMessengerState messenger =
                    ScaffoldMessenger.of(context);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.passwordResetSuccess,
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                context.goNamed(AppRoutes.loginName);
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.homeName,
        path: AppRoutes.homePath,
        builder: (BuildContext context, GoRouterState state) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<ProfileController>.value(
                value: _profileController,
              ),
              ChangeNotifierProvider<WalletController>.value(
                value: _walletController,
              ),
            ],
            child: MainShellScreen(
              onEditProfile: () =>
                  context.pushNamed(AppRoutes.editProfileName),
              onOpenPreferences: () =>
                  context.pushNamed(AppRoutes.preferencesName),
              onOpenCategories: () =>
                  context.pushNamed(AppRoutes.categoriesName),
              onLogoutSuccess: () {
                _walletController.clear();
                context.goNamed(AppRoutes.loginName);
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.editProfileName,
        path: AppRoutes.editProfilePath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<ProfileController>.value(
            value: _profileController,
            child: EditProfileScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.homeName);
                }
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.preferencesName,
        path: AppRoutes.preferencesPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<ProfileController>.value(
            value: _profileController,
            child: PreferencesScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.homeName);
                }
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.categoriesName,
        path: AppRoutes.categoriesPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<CategoryController>(
            create: (_) => CategoryController(
              categoryRepository: _categoryRepository,
            ),
            child: ManageCategoriesScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.homeName);
                }
              },
            ),
          );
        },
      ),
    ];
  }
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen({
    required this.onboardingStorage,
    required this.authRepository,
  });

  final OnboardingStorage onboardingStorage;
  final AuthRepository authRepository;

  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  bool _isResolving = false;
  AppException? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveStartup());
  }

  Future<void> _resolveStartup() async {
    if (_isResolving) {
      return;
    }

    setState(() {
      _isResolving = true;
      _error = null;
    });

    try {
      final bool restored = await widget.authRepository.restoreSession();
      if (!mounted) {
        return;
      }

      if (restored) {
        context.goNamed(AppRoutes.homeName);
        return;
      }

      final bool seen = await widget.onboardingStorage.hasSeenOnboarding();
      if (!mounted) {
        return;
      }

      context.goNamed(
        seen ? AppRoutes.loginName : AppRoutes.getStartedName,
      );
    } on AppException catch (exception) {
      if (mounted) {
        setState(() {
          _error = exception;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = const AppException(
            message: 'SmartWallet could not restore your session. Please try again.',
            type: AppExceptionType.unknown,
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResolving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: _error == null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.preparingSmartWallet,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 48),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.unableRestoreSession,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          LocalizedErrorMessage.fromException(context, _error),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton(
                          onPressed: _isResolving ? null : _resolveStartup,
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingDataScreen extends StatelessWidget {
  const _MissingDataScreen({
    required this.title,
    required this.message,
    required this.onReturnToLogin,
  });

  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) message;
  final VoidCallback onReturnToLogin;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 48),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title(l10n),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.screenTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message(l10n),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: onReturnToLogin,
                    child: Text(l10n.returnToLogin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationErrorScreen extends StatelessWidget {
  const _NavigationErrorScreen({required this.onReturnToLogin});

  final VoidCallback onReturnToLogin;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 48),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.navigationError,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onReturnToLogin,
                  child: Text(l10n.returnToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
