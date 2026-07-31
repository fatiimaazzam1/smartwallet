import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/errors/app_exception.dart';
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
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/get_started_screen.dart';
import 'app_routes.dart';

final class AppRouter {
  AppRouter({
    required OnboardingStorage onboardingStorage,
    required AuthRepository authRepository,
  }) : _onboardingStorage = onboardingStorage,
       _authRepository = authRepository {
    router = GoRouter(
      initialLocation: AppRoutes.startupPath,
      redirect: _redirect,
      routes: _buildRoutes(),
      errorBuilder: (BuildContext context, GoRouterState state) {
        return _NavigationErrorScreen(
          onReturnToLogin: () {
            context.goNamed(AppRoutes.loginName);
          },
        );
      },
    );
  }

  final OnboardingStorage _onboardingStorage;
  final AuthRepository _authRepository;

  late final GoRouter router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final String location = state.matchedLocation;

    if (location == AppRoutes.homePath && !_authRepository.hasAccessToken) {
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

              if (!context.mounted) {
                return;
              }

              context.pushNamed(AppRoutes.registerName);
            },
            onLogin: () async {
              await _onboardingStorage.markOnboardingAsSeen();

              if (!context.mounted) {
                return;
              }

              context.goNamed(AppRoutes.loginName);
            },
          );
        },
      ),
      GoRoute(
        name: AppRoutes.registerName,
        path: AppRoutes.registerPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<RegisterController>(
            create: (_) {
              return RegisterController(authRepository: _authRepository);
            },
            child: RegisterScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }

                context.goNamed(AppRoutes.loginName);
              },
              onLogin: () {
                context.goNamed(AppRoutes.loginName);
              },
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
            return _MissingVerificationEmailScreen(
              onReturnToLogin: () {
                context.goNamed(AppRoutes.loginName);
              },
            );
          }

          final String email = extra.trim().toLowerCase();

          return ChangeNotifierProvider<VerifyEmailController>(
            create: (_) {
              return VerifyEmailController(authRepository: _authRepository);
            },
            child: VerifyEmailScreen(
              email: email,
              onBack: () {
                context.goNamed(AppRoutes.loginName);
              },
              onVerificationSuccess: () {
                context.goNamed(AppRoutes.loginName);
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.loginName,
        path: AppRoutes.loginPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<LoginController>(
            create: (_) {
              return LoginController(authRepository: _authRepository);
            },
            child: LoginScreen(
              onLoginSuccess: () {
                context.goNamed(AppRoutes.homeName);
              },
              onEmailVerificationRequired: (String email) {
                context.goNamed(AppRoutes.verifyEmailName, extra: email);
              },
              onForgotPassword: () {
                context.pushNamed(AppRoutes.forgotPasswordName);
              },
              onRegister: () {
                context.pushNamed(AppRoutes.registerName);
              },
            ),
          );
        },
      ),
      GoRoute(
        name: AppRoutes.forgotPasswordName,
        path: AppRoutes.forgotPasswordPath,
        builder: (BuildContext context, GoRouterState state) {
          return ChangeNotifierProvider<ForgotPasswordController>(
            create: (_) {
              return ForgotPasswordController(authRepository: _authRepository);
            },
            child: ForgotPasswordScreen(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }

                context.goNamed(AppRoutes.loginName);
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
            return _MissingPasswordRecoveryDataScreen(
              title: 'Email Address Missing',
              message: 'Return to Login and start password recovery again.',
              onReturnToLogin: () {
                context.goNamed(AppRoutes.loginName);
              },
            );
          }

          final String email = extra.trim().toLowerCase();

          return ChangeNotifierProvider<VerifyPasswordResetCodeController>(
            create: (_) {
              return VerifyPasswordResetCodeController(
                authRepository: _authRepository,
              );
            },
            child: VerifyPasswordResetCodeScreen(
              email: email,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }

                context.goNamed(AppRoutes.loginName);
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
            return _MissingPasswordRecoveryDataScreen(
              title: 'Reset Session Missing',
              message:
                  'For your security, return to Login and request a new '
                  'password reset code.',
              onReturnToLogin: () {
                context.goNamed(AppRoutes.loginName);
              },
            );
          }

          return ChangeNotifierProvider<ResetPasswordController>(
            create: (_) {
              return ResetPasswordController(authRepository: _authRepository);
            },
            child: ResetPasswordScreen(
              resetSession: extra,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }

                context.goNamed(AppRoutes.loginName);
              },
              onResetSuccess: (String message) {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );

                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(message),
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
          return const HomeScreen();
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
  State<_StartupScreen> createState() {
    return _StartupScreenState();
  }
}

class _StartupScreenState extends State<_StartupScreen> {
  bool _isResolving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveStartup();
    });
  }

  Future<void> _resolveStartup() async {
    if (_isResolving) {
      return;
    }

    setState(() {
      _isResolving = true;
      _errorMessage = null;
    });

    try {
      final bool sessionRestored = await widget.authRepository.restoreSession();

      if (!mounted) {
        return;
      }

      if (sessionRestored) {
        context.goNamed(AppRoutes.homeName);
        return;
      }

      final bool hasSeenOnboarding = await widget.onboardingStorage
          .hasSeenOnboarding();

      if (!mounted) {
        return;
      }

      if (hasSeenOnboarding) {
        context.goNamed(AppRoutes.loginName);
        return;
      }

      context.goNamed(AppRoutes.getStartedName);
    } on AppException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = exception.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'SmartWallet could not restore your session. '
            'Please try again.';
      });
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
    final String? errorMessage = _errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: errorMessage == null
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppSpacing.lg),
                        Text(
                          'Preparing SmartWallet...',
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
                        const Text(
                          'Unable to Restore Session',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton(
                          onPressed: _isResolving
                              ? null
                              : () {
                                  _resolveStartup();
                                },
                          child: const Text('Try Again'),
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

class _MissingVerificationEmailScreen extends StatelessWidget {
  const _MissingVerificationEmailScreen({required this.onReturnToLogin});

  final VoidCallback onReturnToLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email_outlined, size: 48),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Email Address Missing',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Return to Login and enter your account '
                  'email again.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: onReturnToLogin,
                  child: const Text('Return to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingPasswordRecoveryDataScreen extends StatelessWidget {
  const _MissingPasswordRecoveryDataScreen({
    required this.title,
    required this.message,
    required this.onReturnToLogin,
  });

  final String title;
  final String message;
  final VoidCallback onReturnToLogin;

  @override
  Widget build(BuildContext context) {
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
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.screenTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: onReturnToLogin,
                    child: const Text('Return to Login'),
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
                const Text(
                  'This page could not be opened.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: onReturnToLogin,
                  child: const Text('Return to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
