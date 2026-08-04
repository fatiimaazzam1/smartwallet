import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    required this.onEditProfile,
    required this.onOpenPreferences,
    required this.onLogoutSuccess,
    super.key,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onOpenPreferences;
  final VoidCallback onLogoutSuccess;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileController>().load();
      }
    });
  }

  void _selectIndex(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddInformation() {
    final AppLocalizations l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.add_card_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.addTransactionTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.addTransactionBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.close),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final List<Widget> pages = <Widget>[
      const HomeScreen(),
      _ComingSoonScreen(
        icon: Icons.receipt_long_outlined,
        title: l10n.historyComingTitle,
        body: l10n.historyComingBody,
      ),
      _ComingSoonScreen(
        icon: Icons.flag_outlined,
        title: l10n.plansComingTitle,
        body: l10n.plansComingBody,
      ),
      ProfileScreen(
        onEditProfile: widget.onEditProfile,
        onOpenPreferences: widget.onOpenPreferences,
        onLogoutSuccess: widget.onLogoutSuccess,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _SmartWalletBottomNavigationBar(
        selectedIndex: _selectedIndex,
        homeLabel: l10n.home,
        historyLabel: l10n.history,
        plansLabel: l10n.plans,
        profileLabel: l10n.profile,
        addLabel: l10n.add,
        onHomeTap: () => _selectIndex(0),
        onHistoryTap: () => _selectIndex(1),
        onAddTap: _showAddInformation,
        onPlansTap: () => _selectIndex(2),
        onProfileTap: () => _selectIndex(3),
      ),
    );
  }
}

class _SmartWalletBottomNavigationBar extends StatelessWidget {
  const _SmartWalletBottomNavigationBar({
    required this.selectedIndex,
    required this.homeLabel,
    required this.historyLabel,
    required this.plansLabel,
    required this.profileLabel,
    required this.addLabel,
    required this.onHomeTap,
    required this.onHistoryTap,
    required this.onAddTap,
    required this.onPlansTap,
    required this.onProfileTap,
  });

  static const double _barHeight = 92;
  static const double _buttonSize = 56;
  static const Color _addButtonColor = Color(0xFF087F5B);

  final int selectedIndex;
  final String homeLabel;
  final String historyLabel;
  final String plansLabel;
  final String profileLabel;
  final String addLabel;
  final VoidCallback onHomeTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onAddTap;
  final VoidCallback onPlansTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                top: 18,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 18,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _NavigationItem(
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home_rounded,
                          label: homeLabel,
                          isSelected: selectedIndex == 0,
                          onTap: onHomeTap,
                        ),
                      ),
                      Expanded(
                        child: _NavigationItem(
                          icon: Icons.history_rounded,
                          selectedIcon: Icons.history_rounded,
                          label: historyLabel,
                          isSelected: selectedIndex == 1,
                          onTap: onHistoryTap,
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: _NavigationItem(
                          icon: Icons.attach_money_rounded,
                          selectedIcon: Icons.attach_money_rounded,
                          label: plansLabel,
                          isSelected: selectedIndex == 2,
                          onTap: onPlansTap,
                        ),
                      ),
                      Expanded(
                        child: _NavigationItem(
                          icon: Icons.person_outline_rounded,
                          selectedIcon: Icons.person_rounded,
                          label: profileLabel,
                          isSelected: selectedIndex == 3,
                          onTap: onProfileTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Semantics(
                  button: true,
                  label: addLabel,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: addLabel,
                        child: Material(
                          color: _addButtonColor,
                          elevation: 8,
                          shadowColor: const Color(0x330F172A),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onAddTap,
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: _buttonSize,
                              height: _buttonSize,
                              child: Icon(
                                Icons.add_rounded,
                                size: 30,
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        width: 64,
                        child: Text(
                          addLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.helperText.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
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

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.helperText.copyWith(
                  color: color,
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 52, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.screenTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
