import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../data/models/user_profile_model.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.onEditProfile,
    required this.onOpenPreferences,
    required this.onLogoutSuccess,
    super.key,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onOpenPreferences;
  final VoidCallback onLogoutSuccess;

  Future<void> _confirmLogout(BuildContext context) async {
    final AppLocalizations l10n = context.l10n;
    final ProfileController controller = context.read<ProfileController>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !controller.isLoggingOut,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x260F172A),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.logoutTitle,
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.logoutBody, style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: AppColors.surface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.logoutConfirm),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool success = await controller.logout();

    if (!context.mounted) {
      return;
    }

    if (success) {
      onLogoutSuccess();
    }
  }

  void _showCategoriesInfo(BuildContext context) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.categoriesComing),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ProfileController controller = context.watch<ProfileController>();
    final UserProfileModel? profile = controller.profile;

    if (controller.isLoading && profile == null) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    if (profile == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    size: 52,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.profileLoadError,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.screenTitle,
                  ),
                  if (controller.error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppStatusMessage(
                      message: LocalizedErrorMessage.fromException(
                        context,
                        controller.error,
                      ),
                      isError: true,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: () => controller.load(force: true),
                    child: Text(l10n.retryLoad),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => controller.load(force: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            118,
          ),
          children: [
            Text(l10n.profile, style: AppTextStyles.screenTitle),
            const SizedBox(height: AppSpacing.xl),
            _ProfileHeader(profile: profile),
            if (controller.error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppStatusMessage(
                message: LocalizedErrorMessage.fromException(
                  context,
                  controller.error,
                ),
                isError: true,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _ProfileActionCard(
              children: [
                _ProfileActionTile(
                  icon: Icons.edit_outlined,
                  title: l10n.editProfile,
                  onTap: onEditProfile,
                ),
                _ProfileActionTile(
                  icon: Icons.tune_rounded,
                  title: l10n.preferences,
                  onTap: onOpenPreferences,
                ),
                _ProfileActionTile(
                  icon: Icons.category_outlined,
                  title: l10n.manageCategories,
                  onTap: () => _showCategoriesInfo(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _LogoutActionCard(
              isLoading: controller.isLoggingOut,
              label: l10n.logout,
              onTap: controller.isLoggingOut
                  ? null
                  : () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfileModel profile;

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
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            child: Text(
              profile.initials,
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.surface,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: AppTextStyles.screenTitle,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Divider(height: 1, indent: 56),
          ],
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _LogoutActionCard extends StatelessWidget {
  const _LogoutActionCard({
    required this.isLoading,
    required this.label,
    required this.onTap,
  });

  final bool isLoading;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              else
                const Icon(Icons.logout_rounded, color: AppColors.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
