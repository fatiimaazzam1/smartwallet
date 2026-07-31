import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    required this.onBack,
    required this.onRequestSuccess,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onRequestSuccess;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForgotPassword() async {
    final FormState? formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final ForgotPasswordController controller = context
        .read<ForgotPasswordController>();

    final String normalizedEmail = _emailController.text.trim().toLowerCase();

    final response = await controller.forgotPassword(email: normalizedEmail);

    if (!mounted || response == null) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(response.message),
          behavior: SnackBarBehavior.floating,
        ),
      );

    widget.onRequestSuccess(normalizedEmail);
  }

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = context
        .watch<ForgotPasswordController>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppSpacing.lg * 2),
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : widget.onBack,
                                tooltip: 'Go back',
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            const _PasswordRecoveryIcon(),
                            const SizedBox(height: AppSpacing.xl),
                            const Text(
                              'Forgot Password?',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              'Enter your email address. If the account is '
                              'eligible, we will send a six-digit reset code.',
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
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onFieldSubmitted: (_) {
                                _submitForgotPassword();
                              },
                              enabled: !controller.isLoading,
                            ),
                            if (controller.errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _ForgotPasswordErrorMessage(
                                message: controller.errorMessage!,
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            AppButton(
                              label: 'Send Reset Code',
                              isLoading: controller.isLoading,
                              onPressed: _submitForgotPassword,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextButton.icon(
                              onPressed: controller.isLoading
                                  ? null
                                  : widget.onBack,
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                              ),
                              label: const Text('Back to Login'),
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

class _PasswordRecoveryIcon extends StatelessWidget {
  const _PasswordRecoveryIcon();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_reset_rounded,
          size: 44,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ForgotPasswordErrorMessage extends StatelessWidget {
  const _ForgotPasswordErrorMessage({required this.message});

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
