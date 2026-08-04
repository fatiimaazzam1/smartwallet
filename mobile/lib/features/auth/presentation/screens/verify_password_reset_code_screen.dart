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
    final AppLocalizations l10n = context.l10n;
    final String code = value?.trim() ?? '';

    if (code.isEmpty) {
      return l10n.resetCodeRequired;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return l10n.enterSixDigitResetCode;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
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
                      const _ResetCodeIcon(),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.verifyResetCode,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.resetCodeSubtitle,
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
                        l10n.resetCode,
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
                          message: l10n.resetCodeResent,
                          isError: false,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: l10n.verifyCode,
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
