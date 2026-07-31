import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/smartwallet_logo.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onLoginSuccess,
    required this.onEmailVerificationRequired,
    required this.onForgotPassword,
    required this.onRegister,
    super.key,
  });

  final VoidCallback onLoginSuccess;
  final ValueChanged<String> onEmailVerificationRequired;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _submitLogin() async {
    final FormState? formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final LoginController controller = context.read<LoginController>();

    final String normalizedEmail = _emailController.text.trim().toLowerCase();

    final LoginSubmissionResult result = await controller.login(
      email: normalizedEmail,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (result == LoginSubmissionResult.success) {
      widget.onLoginSuccess();
      return;
    }

    if (result == LoginSubmissionResult.emailVerificationRequired) {
      widget.onEmailVerificationRequired(normalizedEmail);
    }
  }

  void _openForgotPassword() {
    final LoginController controller = context.read<LoginController>();

    FocusScope.of(context).unfocus();
    controller.clearError();
    _passwordController.clear();

    widget.onForgotPassword();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LoginController controller = context.watch<LoginController>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.xl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppSpacing.xl * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SmartWalletLogo(size: 88),
                            const SizedBox(height: AppSpacing.xl),
                            const Text(
                              'Welcome Back',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Log in to continue managing '
                              'your money with confidence.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            AppTextField(
                              label: 'Email Address',
                              hintText: 'you@example.com',
                              controller: _emailController,
                              validator: FormValidators.email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              enabled: !controller.isLoading,
                            ),
                            const SizedBox(height: AppSpacing.fieldGap),
                            AppTextField(
                              label: 'Password',
                              hintText: 'Enter your password',
                              controller: _passwordController,
                              validator: _validatePassword,
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) {
                                _submitLogin();
                              },
                              enabled: !controller.isLoading,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : _openForgotPassword,
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            if (controller.errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              _LoginErrorMessage(
                                message: controller.errorMessage!,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            AppButton(
                              label: 'Log In',
                              isLoading: controller.isLoading,
                              onPressed: _submitLogin,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.xs,
                              children: [
                                const Text(
                                  'Do not have an account?',
                                  style: AppTextStyles.body,
                                ),
                                TextButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : widget.onRegister,
                                  child: const Text('Register'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: AppTextStyles.errorText)),
        ],
      ),
    );
  }
}
