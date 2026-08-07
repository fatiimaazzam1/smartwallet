import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool? _manualShowBalance;

  Future<void> _refresh() async {
    await Future.wait<void>(<Future<void>>[
      context.read<ProfileController>().load(force: true),
      context.read<WalletController>().load(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ProfileController profileController = context
        .watch<ProfileController>();
    final WalletController walletController = context
        .watch<WalletController>();
    final UserProfileModel? profile = profileController.profile;
    final UserPreferencesModel? preferences = profileController.preferences;
    final WalletModel? wallet = walletController.wallet;
    final bool showBalance =
        _manualShowBalance ?? !(preferences?.hideBalanceByDefault ?? false);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            118,
          ),
          children: [
            _HomeHeader(profile: profile),
            const SizedBox(height: AppSpacing.xl),
            if (walletController.isLoading && wallet == null)
              const _WalletLoadingCard()
            else if (wallet == null)
              _WalletErrorCard(
                message: LocalizedErrorMessage.fromException(
                  context,
                  walletController.error,
                ),
                onRetry: () => walletController.load(force: true),
              )
            else
              _WalletBalanceCard(
                wallet: wallet,
                showBalance: showBalance,
                onToggleVisibility: () {
                  setState(() {
                    _manualShowBalance = !showBalance;
                  });
                },
              ),
            if (profileController.error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppStatusMessage(
                message: LocalizedErrorMessage.fromException(
                  context,
                  profileController.error,
                ),
                isError: true,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _PhaseFoundationCard(
              title: l10n.walletReadyTitle,
              body: l10n.walletReadyBody,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.profile});

  final UserProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    final String firstName = profile?.firstName.trim() ?? '';
    final String title = firstName.isEmpty
        ? context.l10n.homeWelcome
        : context.l10n.greetingName(firstName);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.screenTitle),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.walletOverviewSubtitle,
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          child: Text(
            profile?.initials ?? 'SW',
            style: AppTextStyles.body.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({
    required this.wallet,
    required this.showBalance,
    required this.onToggleVisibility,
  });

  final WalletModel wallet;
  final bool showBalance;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      name: wallet.currencyCode,
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260D1B2A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.totalBalance,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: showBalance
                    ? context.l10n.hideBalance
                    : context.l10n.showBalance,
                onPressed: onToggleVisibility,
                color: AppColors.surface,
                icon: Icon(
                  showBalance
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: context.l10n.totalBalance,
            value: showBalance
                ? formatter.format(wallet.balance)
                : context.l10n.balanceHidden,
            child: Text(
              showBalance ? formatter.format(wallet.balance) : '••••••',
              style: AppTextStyles.brandTitle.copyWith(
                color: AppColors.surface,
                fontSize: 34,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.surface,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    wallet.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  wallet.currencyCode,
                  style: AppTextStyles.helperText.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletLoadingCard extends StatelessWidget {
  const _WalletLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.surface),
      ),
    );
  }
}

class _WalletErrorCard extends StatelessWidget {
  const _WalletErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(onPressed: onRetry, child: Text(context.l10n.retryLoad)),
        ],
      ),
    );
  }
}

class _PhaseFoundationCard extends StatelessWidget {
  const _PhaseFoundationCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: AppTextStyles.subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
