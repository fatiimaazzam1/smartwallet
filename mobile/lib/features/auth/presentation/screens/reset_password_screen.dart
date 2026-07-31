import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/password_reset_token_response_model.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.resetSession,
    required this.onBack,
    required this.onResetSuccess,
    super.key,
  });

  final PasswordResetTokenResponseModel resetSession;
  final VoidCallback onBack;
  final ValueChanged<String> onResetSuccess;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitResetPassword() async {
    final FormState? formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final ResetPasswordController controller = context
        .read<ResetPasswordController>();

    final response = await controller.resetPassword(
      resetToken: widget.resetSession.resetToken,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted || response == null) {
      return;
    }

    _newPasswordController.clear();
    _confirmPasswordController.clear();

    widget.onResetSuccess(response.message);
  }

  String get _expiryText {
    final int seconds = widget.resetSession.expiresInSeconds;

    if (seconds < 60) {
      return 'This secure reset session expires in less than one minute.';
    }

    final int minutes = (seconds / 60).ceil();

    return 'This secure reset session expires in about '
        '$minutes ${minutes == 1 ? 'minute' : 'minutes'}.';
  }

  @override
  Widget build(BuildContext context) {
    final ResetPasswordController controller = context
        .watch<ResetPasswordController>();

    return PopScope(
      canPop: !controller.isLoading,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                              const _ResetPasswordIcon(),
                              const SizedBox(height: AppSpacing.xl),
                              const Text(
                                'Create New Password',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.screenTitle,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const Text(
                                'Choose a strong password that you have not '
                                'shared with anyone.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.subtitle,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _expiryText,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.helperText,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              AppTextField(
                                label: 'New Password',
                                hintText: 'Enter your new password',
                                controller: _newPasswordController,
                                validator: FormValidators.password,
                                isPassword: true,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                enabled: !controller.isLoading,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const Text(
                                'Use 8–72 characters with uppercase, '
                                'lowercase, number, and special character.',
                                style: AppTextStyles.helperText,
                              ),
                              const SizedBox(height: AppSpacing.fieldGap),
                              AppTextField(
                                label: 'Confirm New Password',
                                hintText: 'Enter the new password again',
                                controller: _confirmPasswordController,
                                validator: (String? value) {
                                  return FormValidators.confirmPassword(
                                    value,
                                    _newPasswordController.text,
                                  );
                                },
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onFieldSubmitted: (_) {
                                  _submitResetPassword();
                                },
                                enabled: !controller.isLoading,
                              ),
                              if (controller.errorMessage != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                _ResetPasswordErrorMessage(
                                  message: controller.errorMessage!,
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xl),
                              AppButton(
                                label: 'Reset Password',
                                isLoading: controller.isLoading,
                                onPressed: _submitResetPassword,
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
      ),
    );
  }
}

class _ResetPasswordIcon extends StatelessWidget {
  const _ResetPasswordIcon();

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
          Icons.lock_open_rounded,
          size: 42,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ResetPasswordErrorMessage extends StatelessWidget {
  const _ResetPasswordErrorMessage({required this.message});

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
