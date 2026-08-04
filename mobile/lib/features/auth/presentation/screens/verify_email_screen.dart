import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_message.dart';
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
    final AppLocalizations l10n = context.l10n;
    final String code = value?.trim() ?? '';

    if (code.isEmpty) {
      return l10n.verificationCodeRequired;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return l10n.enterSixDigitVerificationCode;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
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
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: controller.isLoading ? null : widget.onBack,
                        tooltip: l10n.goBack,
                        icon: const BackButtonIcon(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _EmailVerificationIcon(),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.verifyYourEmail,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.screenTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.verificationSentTo,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      l10n.verificationCode,
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
                      inputFormatters: <TextInputFormatter>[
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
                      onFieldSubmitted: (_) => _verifyCode(),
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
                    if (controller.successMessage != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppStatusMessage(
                        message: l10n.verificationCodeResent,
                        isError: false,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: l10n.verifyEmail,
                      isLoading: controller.isVerifying,
                      onPressed: controller.isResending ? null : _verifyCode,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.didNotReceiveCode,
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
                            ? l10n.sending
                            : _canResend
                            ? l10n.resendCode
                            : l10n.resendIn(_remainingSeconds),
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
