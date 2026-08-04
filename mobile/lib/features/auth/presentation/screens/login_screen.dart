import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_message.dart';
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
    final String email = _emailController.text.trim().toLowerCase();
    final LoginSubmissionResult result = await controller.login(
      email: email,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (result == LoginSubmissionResult.success) {
      widget.onLoginSuccess();
    } else if (result == LoginSubmissionResult.emailVerificationRequired) {
      widget.onEmailVerificationRequired(email);
    }
  }

  void _openForgotPassword() {
    FocusScope.of(context).unfocus();
    context.read<LoginController>().clearError();
    _passwordController.clear();
    widget.onForgotPassword();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
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
                            Text(
                              l10n.welcomeBack,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.screenTitle,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.loginSubtitle,
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
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              enabled: !controller.isLoading,
                            ),
                            const SizedBox(height: AppSpacing.fieldGap),
                            AppTextField(
                              label: l10n.password,
                              hintText: l10n.passwordHint,
                              controller: _passwordController,
                              validator: (String? value) =>
                                  FormValidators.requiredField(
                                    value,
                                    fieldName: l10n.password,
                                    l10n: l10n,
                                  ),
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _submitLogin(),
                              enabled: !controller.isLoading,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : _openForgotPassword,
                                child: Text(
                                  l10n.forgotPasswordQuestion,
                                ),
                              ),
                            ),
                            if (controller.errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
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
                              label: l10n.logInButton,
                              isLoading: controller.isLoading,
                              onPressed: _submitLogin,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: AppSpacing.xs,
                              children: [
                                Text(
                                  l10n.noAccount,
                                  style: AppTextStyles.body,
                                ),
                                TextButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : widget.onRegister,
                                  child: Text(l10n.register),
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
