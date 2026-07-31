import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/verify_email_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    required this.email,
    required this.onBack,
    required this.onVerificationSuccess,
    super.key,
  });

  final String email;
  final VoidCallback onBack;
  final VoidCallback onVerificationSuccess;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const int _resendCooldownSeconds = 60;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController = TextEditingController();

  Timer? _resendTimer;
  int _remainingSeconds = 0;

  bool get _canResend => _remainingSeconds == 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final FormState? formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final VerifyEmailController controller = context
        .read<VerifyEmailController>();

    final response = await controller.verifyEmail(
      email: widget.email,
      code: _codeController.text,
    );

    if (!mounted || response == null) {
      return;
    }

    widget.onVerificationSuccess();
  }

  Future<void> _resendCode() async {
    if (!_canResend) {
      return;
    }

    FocusScope.of(context).unfocus();

    final VerifyEmailController controller = context
        .read<VerifyEmailController>();

    final response = await controller.resendVerificationCode(
      email: widget.email,
    );

    if (!mounted || response == null) {
      return;
    }

    _startResendCooldown();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();

    setState(() {
      _remainingSeconds = _resendCooldownSeconds;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
        });

        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  String? _validateCode(String? value) {
    final String code = value?.trim() ?? '';

    if (code.isEmpty) {
      return 'Verification code is required.';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'Enter the six-digit verification code.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final VerifyEmailController controller = context
        .watch<VerifyEmailController>();

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
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: controller.isLoading ? null : widget.onBack,
                        tooltip: 'Go back',
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    const _EmailVerificationIcon(),

                    const SizedBox(height: AppSpacing.xl),

                    const Text(
                      'Verify Your Email',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    const Text(
                      'We sent a six-digit verification code to',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    const Text(
                      'Verification Code',
                      style: AppTextStyles.fieldLabel,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    TextFormField(
                      controller: _codeController,
                      enabled: !controller.isLoading,
                      validator: _validateCode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.inputText.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 10,
                      ),
                      decoration: const InputDecoration(
                        hintText: '000000',
                        counterText: '',
                      ),
                      maxLength: 6,
                      onFieldSubmitted: (_) {
                        _verifyCode();
                      },
                    ),

                    if (controller.errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _StatusMessage(
                        message: controller.errorMessage!,
                        isError: true,
                      ),
                    ],

                    if (controller.successMessage != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _StatusMessage(
                        message: controller.successMessage!,
                        isError: false,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    AppButton(
                      label: 'Verify Email',
                      isLoading: controller.isVerifying,
                      onPressed: controller.isResending ? null : _verifyCode,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const Text(
                      'Did not receive the code?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    TextButton(
                      onPressed: controller.isLoading || !_canResend
                          ? null
                          : _resendCode,
                      child: Text(
                        controller.isResending
                            ? 'Sending...'
                            : _canResend
                            ? 'Resend Code'
                            : 'Resend in '
                                  '$_remainingSeconds seconds',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailVerificationIcon extends StatelessWidget {
  const _EmailVerificationIcon();

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
          Icons.mark_email_unread_outlined,
          size: 42,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isError ? AppColors.error : AppColors.accent;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            size: 20,
            color: statusColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: isError
                  ? AppTextStyles.errorText
                  : AppTextStyles.body.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
