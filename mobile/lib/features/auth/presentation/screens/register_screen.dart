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
import '../controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    required this.onBack,
    required this.onLogin,
    required this.onRegistrationSuccess,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onLogin;
  final ValueChanged<String> onRegistrationSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    final FormState? formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final RegisterController controller = context.read<RegisterController>();
    final response = await controller.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted || response == null) {
      return;
    }

    widget.onRegistrationSuccess(response.email);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final RegisterController controller = context.watch<RegisterController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          onPressed: controller.isLoading ? null : widget.onBack,
                          tooltip: l10n.goBack,
                          icon: const BackButtonIcon(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.createAccount,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.registerSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final bool stacked = constraints.maxWidth < 390;
                          final Widget firstName = AppTextField(
                            label: l10n.firstName,
                            hintText: l10n.firstNameHint,
                            controller: _firstNameController,
                            validator: (String? value) => FormValidators.name(
                              value,
                              fieldName: l10n.firstName,
                              l10n: l10n,
                            ),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.givenName],
                            enabled: !controller.isLoading,
                          );
                          final Widget lastName = AppTextField(
                            label: l10n.lastName,
                            hintText: l10n.lastNameHint,
                            controller: _lastNameController,
                            validator: (String? value) => FormValidators.name(
                              value,
                              fieldName: l10n.lastName,
                              l10n: l10n,
                            ),
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.familyName],
                            enabled: !controller.isLoading,
                          );

                          if (stacked) {
                            return Column(
                              children: [
                                firstName,
                                const SizedBox(height: AppSpacing.fieldGap),
                                lastName,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: firstName),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: lastName),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
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
                        hintText: l10n.createSecurePassword,
                        controller: _passwordController,
                        validator: (String? value) =>
                            FormValidators.password(value, l10n),
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !controller.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.passwordRequirements,
                        style: AppTextStyles.helperText,
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),
                      AppTextField(
                        label: l10n.confirmPassword,
                        hintText: l10n.confirmPasswordHint,
                        controller: _confirmPasswordController,
                        validator: (String? value) =>
                            FormValidators.confirmPassword(
                              value,
                              _passwordController.text,
                              l10n,
                            ),
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        onFieldSubmitted: (_) => _submitRegistration(),
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
                        label: l10n.register,
                        isLoading: controller.isLoading,
                        onPressed: _submitRegistration,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.xs,
                        children: [
                          Text(
                            l10n.alreadyHaveAccount,
                            style: AppTextStyles.body,
                          ),
                          TextButton(
                            onPressed: controller.isLoading
                                ? null
                                : widget.onLogin,
                            child: Text(l10n.logIn),
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
      ),
    );
  }
}
