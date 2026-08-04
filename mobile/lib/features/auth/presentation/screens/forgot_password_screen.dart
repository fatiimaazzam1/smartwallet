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
    final String email = _emailController.text.trim().toLowerCase();
    final response = await controller.forgotPassword(email: email);

    if (!mounted || response == null) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.resetCodeSent),
          behavior: SnackBarBehavior.floating,
        ),
      );

    widget.onRequestSuccess(email);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
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
                            const _PasswordRecoveryIcon(),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              l10n.forgotPasswordTitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.forgotPasswordSubtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.subtitle,
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            AppTextField(
                              label: l10n.emailAddress,
                              hintText: l10n.emailHint,
                              controller: _emailController,
                              validator: (String? value) =>
                                  FormValidators.email(value, l10n),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onFieldSubmitted: (_) => _submitForgotPassword(),
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
                              label: l10n.sendResetCode,
                              isLoading: controller.isLoading,
                              onPressed: _submitForgotPassword,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextButton.icon(
                              onPressed: controller.isLoading
                                  ? null
                                  : widget.onBack,
                              icon: const BackButtonIcon(),
                              label: Text(l10n.backToLogin),
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
