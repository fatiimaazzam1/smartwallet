import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../data/models/dashboard_model.dart';
import '../controllers/dashboard_controller.dart';

class WeeklyInsightsScreen extends StatefulWidget {
  const WeeklyInsightsScreen({
    required this.onBack,
    super.key,
  });

  final VoidCallback onBack;

  @override
  State<WeeklyInsightsScreen> createState() => _WeeklyInsightsScreenState();
}

class _WeeklyInsightsScreenState extends State<WeeklyInsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardController>().load(force: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = context.watch<DashboardController>();
    final DashboardWeeklyInsightsModel? insights =
        controller.data?.weeklyInsights;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          tooltip: context.l10n.goBack,
          icon: const BackButtonIcon(),
        ),
        title: Text(context.l10n.weeklyInsights),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.load(force: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              if (controller.isLoading && insights == null)
                const Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (insights == null)
                _InsightsLoadFailure(
                  message: controller.error == null
                      ? context.l10n.weeklyInsightsUnavailable
                      : LocalizedErrorMessage.fromException(
                          context,
                          controller.error,
                        ),
                  onRetry: () => controller.load(force: true),
                )
              else ...<Widget>[
                _InsightCard(
                  icon: _comparisonIcon(insights),
                  iconBackground: _comparisonBackground(insights),
                  iconColor: _comparisonColor(insights),
                  title: _comparisonTitle(context, insights),
                  message: _comparisonMessage(context, insights),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InsightCard(
                  icon: Icons.circle_outlined,
                  iconBackground: const Color(0xFFFFF4E5),
                  iconColor: const Color(0xFFF59E0B),
                  title: context.l10n.highestCategory,
                  message: insights.topSpendingCategory == null
                      ? context.l10n.highestCategoryUnavailable
                      : context.l10n.highestCategoryMessage(
                          insights.topSpendingCategory!.categoryName,
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InsightCard(
                  icon: Icons.pie_chart_outline_rounded,
                  iconBackground: const Color(0xFFE8F8F0),
                  iconColor: const Color(0xFF10B981),
                  title: context.l10n.budgetPerformance,
                  message: _budgetMessage(context, insights.budgetPerformance),
                ),
                const SizedBox(height: AppSpacing.lg),
                _InsightCard(
                  icon: Icons.calendar_today_outlined,
                  iconBackground: const Color(0xFFE9EEF6),
                  iconColor: AppColors.primary,
                  title: context.l10n.upcoming,
                  message: context.l10n.upcomingFourteenDaysMessage(
                    insights.upcomingFourteenDayCount,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _comparisonIcon(DashboardWeeklyInsightsModel insights) {
    return switch (insights.comparisonDirection) {
      'INCREASED' => Icons.arrow_upward_rounded,
      'DECREASED' => Icons.arrow_downward_rounded,
      _ => Icons.horizontal_rule_rounded,
    };
  }

  Color _comparisonBackground(DashboardWeeklyInsightsModel insights) {
    return switch (insights.comparisonDirection) {
      'INCREASED' => const Color(0xFFFFECEE),
      'DECREASED' => const Color(0xFFE8F8F0),
      _ => const Color(0xFFE9EEF6),
    };
  }

  Color _comparisonColor(DashboardWeeklyInsightsModel insights) {
    return switch (insights.comparisonDirection) {
      'INCREASED' => AppColors.error,
      'DECREASED' => const Color(0xFF10B981),
      _ => AppColors.textSecondary,
    };
  }

  String _comparisonTitle(
    BuildContext context,
    DashboardWeeklyInsightsModel insights,
  ) {
    if (!insights.comparisonAvailable) {
      return context.l10n.spendingComparison;
    }

    return switch (insights.comparisonDirection) {
      'INCREASED' => context.l10n.spendingIncreased,
      'DECREASED' => context.l10n.spendingDecreased,
      _ => context.l10n.spendingUnchanged,
    };
  }

  String _comparisonMessage(
    BuildContext context,
    DashboardWeeklyInsightsModel insights,
  ) {
    if (!insights.comparisonAvailable) {
      return context.l10n.weeklyComparisonUnavailable;
    }

    final String percentage = insights.comparisonPercentage ?? '0.00';
    final String? category = insights.topSpendingCategory?.categoryName;

    if (insights.comparisonDirection == 'INCREASED') {
      return category == null
          ? context.l10n.spendingIncreasedMessage(percentage)
          : context.l10n.spendingIncreasedCategoryMessage(
              percentage,
              category,
            );
    }
    if (insights.comparisonDirection == 'DECREASED') {
      return category == null
          ? context.l10n.spendingDecreasedMessage(percentage)
          : context.l10n.spendingDecreasedCategoryMessage(
              percentage,
              category,
            );
    }
    return context.l10n.spendingUnchangedMessage;
  }

  String _budgetMessage(
    BuildContext context,
    DashboardBudgetPerformanceModel budgets,
  ) {
    if (budgets.totalCount == 0) {
      return context.l10n.noActiveBudgetsThisMonth;
    }
    final int withinLimit = budgets.safeCount + budgets.warningCount;
    return context.l10n.budgetWithinLimitsMessage(
      withinLimit,
      budgets.totalCount,
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF3)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTextStyles.helperText.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
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

class _InsightsLoadFailure extends StatelessWidget {
  const _InsightsLoadFailure({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: <Widget>[
          AppStatusMessage(message: message, isError: true),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
