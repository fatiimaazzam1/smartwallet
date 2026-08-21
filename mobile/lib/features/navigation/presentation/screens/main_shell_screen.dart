import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../budgets/presentation/controllers/budget_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../planned_expenses/presentation/controllers/planned_expense_controller.dart';
import '../../../planning/presentation/screens/plans_screen.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../transactions/data/models/transaction_type.dart';
import '../../../transactions/presentation/controllers/transaction_history_controller.dart';
import '../../../transactions/presentation/screens/transaction_history_screen.dart';
import '../../../transactions/presentation/widgets/add_new_transaction_sheet.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    required this.onEditProfile,
    required this.onOpenPreferences,
    required this.onOpenCategories,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onOpenTransaction,
    required this.onCreateBudget,
    required this.onOpenBudget,
    required this.onCreatePlannedExpense,
    required this.onOpenPlannedExpense,
    required this.onLogoutSuccess,
    super.key,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onOpenPreferences;
  final VoidCallback onOpenCategories;
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final ValueChanged<int> onOpenTransaction;
  final VoidCallback onCreateBudget;
  final ValueChanged<int> onOpenBudget;
  final VoidCallback onCreatePlannedExpense;
  final ValueChanged<int> onOpenPlannedExpense;
  final VoidCallback onLogoutSuccess;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  bool _isAddSheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileController>().load();
        context.read<WalletController>().load();
        context.read<TransactionHistoryController>().loadRecent();
        context.read<DashboardController>().load();
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

    if (index == 0) {
      context.read<DashboardController>().load(force: true);
    } else if (index == 2) {
      context.read<BudgetController>().load();
      context.read<PlannedExpenseController>().load();
    }
  }

  Future<void> _showAddNew() async {
    if (_isAddSheetOpen) {
      return;
    }

    setState(() {
      _isAddSheetOpen = true;
    });

    TransactionType? type;
    try {
      type = await showAddNewTransactionSheet(context: context);
    } finally {
      if (mounted) {
        setState(() {
          _isAddSheetOpen = false;
        });
      }
    }

    if (!mounted || type == null) {
      return;
    }

    if (type == TransactionType.income) {
      widget.onAddIncome();
    } else {
      widget.onAddExpense();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final List<Widget> pages = <Widget>[
      HomeScreen(
        onAddIncome: widget.onAddIncome,
        onAddExpense: widget.onAddExpense,
        onViewAllTransactions: () => _selectIndex(1),
        onOpenTransaction: widget.onOpenTransaction,
        onOpenPlannedExpense: widget.onOpenPlannedExpense,
        onOpenBudget: widget.onOpenBudget,
      ),
      TransactionHistoryScreen(
        onOpenTransaction: widget.onOpenTransaction,
      ),
      PlansScreen(
        onCreateBudget: widget.onCreateBudget,
        onOpenBudget: widget.onOpenBudget,
        onCreatePlanned: widget.onCreatePlannedExpense,
        onOpenPlanned: widget.onOpenPlannedExpense,
      ),
      ProfileScreen(
        onEditProfile: widget.onEditProfile,
        onOpenPreferences: widget.onOpenPreferences,
        onOpenCategories: widget.onOpenCategories,
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
        onAddTap: () => unawaited(_showAddNew()),
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
