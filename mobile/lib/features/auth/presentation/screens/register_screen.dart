import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_button.dart';
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
    final RegisterController controller = context.watch<RegisterController>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
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
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : widget.onBack,
                              tooltip: 'Go back',
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          const Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.screenTitle,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          const Text(
                            'Start managing your money with confidence.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitle,
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          _NameFields(
                            firstNameController: _firstNameController,
                            lastNameController: _lastNameController,
                            isEnabled: !controller.isLoading,
                          ),

                          const SizedBox(height: AppSpacing.fieldGap),

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
                            hintText: 'Create a secure password',
                            controller: _passwordController,
                            validator: FormValidators.password,
                            isPassword: true,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
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
                            label: 'Confirm Password',
                            hintText: 'Enter the password again',
                            controller: _confirmPasswordController,
                            validator: (value) {
                              return FormValidators.confirmPassword(
                                value,
                                _passwordController.text,
                              );
                            },
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onFieldSubmitted: (_) {
                              _submitRegistration();
                            },
                            enabled: !controller.isLoading,
                          ),

                          if (controller.errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.lg),
                            _RegistrationErrorMessage(
                              message: controller.errorMessage!,
                            ),
                          ],

                          const SizedBox(height: AppSpacing.xl),

                          AppButton(
                            label: 'Register',
                            isLoading: controller.isLoading,
                            onPressed: _submitRegistration,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.xs,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: AppTextStyles.body,
                              ),
                              TextButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : widget.onLogin,
                                child: const Text('Log in'),
                              ),
                            ],
                          ),
                        ],
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

class _NameFields extends StatelessWidget {
  const _NameFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.isEnabled,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    if (screenWidth < 390) {
      return Column(
        children: [
          AppTextField(
            label: 'First Name',
            hintText: 'First name',
            controller: firstNameController,
            validator: (value) {
              return FormValidators.name(value, fieldName: 'First name');
            },
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.givenName],
            enabled: isEnabled,
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          AppTextField(
            label: 'Last Name',
            hintText: 'Last name',
            controller: lastNameController,
            validator: (value) {
              return FormValidators.name(value, fieldName: 'Last name');
            },
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.familyName],
            enabled: isEnabled,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AppTextField(
            label: 'First Name',
            hintText: 'First name',
            controller: firstNameController,
            validator: (value) {
              return FormValidators.name(value, fieldName: 'First name');
            },
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.givenName],
            enabled: isEnabled,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppTextField(
            label: 'Last Name',
            hintText: 'Last name',
            controller: lastNameController,
            validator: (value) {
              return FormValidators.name(value, fieldName: 'Last name');
            },
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.familyName],
            enabled: isEnabled,
          ),
        ),
      ],
    );
  }
}

class _RegistrationErrorMessage extends StatelessWidget {
  const _RegistrationErrorMessage({required this.message});

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
