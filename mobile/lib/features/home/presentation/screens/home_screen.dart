import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/smartwallet_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const SmartWalletLogo(size: 52),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        l10n.appTitle,
                        style: AppTextStyles.brandTitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  l10n.homeWelcome,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.homeSessionActive,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.successBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 48,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.authenticationSuccessful,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.authenticationSuccessfulBody,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.dashboard_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.dashboardComingBody,
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
