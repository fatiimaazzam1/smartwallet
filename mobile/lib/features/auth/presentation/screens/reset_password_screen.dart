import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_message.dart';
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
  final VoidCallback onResetSuccess;

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
    widget.onResetSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ResetPasswordController controller = context
        .watch<ResetPasswordController>();
    final int expirySeconds = widget.resetSession.expiresInSeconds;
    final String expiryMessage = expirySeconds < 60
        ? l10n.resetSessionLessThanMinute
        : l10n.resetSessionExpiry((expirySeconds / 60).ceil());

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
                                alignment: AlignmentDirectional.centerStart,
                                child: IconButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : widget.onBack,
                                  tooltip: l10n.goBack,
                                  icon: const BackButtonIcon(),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              const _ResetPasswordIcon(),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                l10n.createNewPassword,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.screenTitle,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.createNewPasswordSubtitle,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.subtitle,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                expiryMessage,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.helperText,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              AppTextField(
                                label: l10n.newPassword,
                                hintText: l10n.newPasswordHint,
                                controller: _newPasswordController,
                                validator: (String? value) =>
                                    FormValidators.password(value, l10n),
                                isPassword: true,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                enabled: !controller.isLoading,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.passwordRequirements,
                                style: AppTextStyles.helperText,
                              ),
                              const SizedBox(height: AppSpacing.fieldGap),
                              AppTextField(
                                label: l10n.confirmNewPassword,
                                hintText: l10n.confirmNewPasswordHint,
                                controller: _confirmPasswordController,
                                validator: (String? value) =>
                                    FormValidators.confirmPassword(
                                      value,
                                      _newPasswordController.text,
                                      l10n,
                                    ),
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onFieldSubmitted: (_) => _submitResetPassword(),
                                enabled: !controller.isLoading,
                              ),
                              if (controller.errorMessage != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                AppStatusMessage(
                                  message: LocalizedErrorMessage.fromMessage(
                                    context,
                                    controller.errorMessage,
                                  ),
                                  isError: true,
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xl),
                              AppButton(
                                label: l10n.resetPassword,
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
