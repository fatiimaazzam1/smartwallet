import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/password_reset_token_response_model.dart';
import '../controllers/verify_password_reset_code_controller.dart';

class VerifyPasswordResetCodeScreen extends StatefulWidget {
  const VerifyPasswordResetCodeScreen({
    required this.email,
    required this.onBack,
    required this.onVerificationSuccess,
    super.key,
  });

  final String email;
  final VoidCallback onBack;
  final ValueChanged<PasswordResetTokenResponseModel> onVerificationSuccess;

  @override
  State<VerifyPasswordResetCodeScreen> createState() =>
      _VerifyPasswordResetCodeScreenState();
}

class _VerifyPasswordResetCodeScreenState
    extends State<VerifyPasswordResetCodeScreen> {
  static const int _resendCooldownSeconds = 60;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  Timer? _resendTimer;
  int _remainingSeconds = _resendCooldownSeconds;

  bool get _canResend => _remainingSeconds == 0;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

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

    final VerifyPasswordResetCodeController controller = context
        .read<VerifyPasswordResetCodeController>();

    final PasswordResetTokenResponseModel? response = await controller
        .verifyPasswordResetCode(
          email: widget.email,
          code: _codeController.text,
        );

    if (!mounted || response == null) {
      return;
    }

    widget.onVerificationSuccess(response);
  }

  Future<void> _resendCode() async {
    if (!_canResend) {
      return;
    }

    FocusScope.of(context).unfocus();

    final VerifyPasswordResetCodeController controller = context
        .read<VerifyPasswordResetCodeController>();

    final response = await controller.resendPasswordResetCode(
      email: widget.email,
    );

    if (!mounted || response == null) {
      return;
    }

    _codeController.clear();
    _formKey.currentState?.reset();
    _restartResendCooldown();
  }

  void _restartResendCooldown() {
    _resendTimer?.cancel();

    setState(() {
      _remainingSeconds = _resendCooldownSeconds;
    });

    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
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
      return 'Reset code is required.';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'Enter the six-digit reset code.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final VerifyPasswordResetCodeController controller = context
        .watch<VerifyPasswordResetCodeController>();

    return PopScope(
      canPop: !controller.isLoading,
      child: Scaffold(
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
                          onPressed: controller.isLoading
                              ? null
                              : widget.onBack,
                          tooltip: 'Go back',
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const _ResetCodeIcon(),
                      const SizedBox(height: AppSpacing.xl),
                      const Text(
                        'Verify Reset Code',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Enter the six-digit reset code if one was sent for',
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
                      const Text('Reset Code', style: AppTextStyles.fieldLabel),
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
                        label: 'Verify Code',
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
                              : 'Resend in $_remainingSeconds seconds',
                        ),
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

class _ResetCodeIcon extends StatelessWidget {
  const _ResetCodeIcon();

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
          Icons.password_rounded,
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
