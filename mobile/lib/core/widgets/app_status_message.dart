import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppStatusMessage extends StatelessWidget {
  const AppStatusMessage({
    required this.message,
    required this.isError,
    super.key,
  });

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
