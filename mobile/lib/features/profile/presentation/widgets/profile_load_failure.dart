import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_status_message.dart';

class ProfileLoadFailure extends StatelessWidget {
  const ProfileLoadFailure({
    required this.message,
    required this.error,
    required this.onRetry,
    super.key,
  });

  final String message;
  final AppException? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 52,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.screenTitle,
              ),
              if (error != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppStatusMessage(
                  message: LocalizedErrorMessage.fromException(context, error),
                  isError: true,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onRetry,
                child: Text(l10n.retryLoad),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
