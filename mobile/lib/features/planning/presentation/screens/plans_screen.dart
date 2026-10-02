import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../budgets/data/models/budget_month_model.dart';
import '../../../budgets/presentation/controllers/budget_controller.dart';
import '../../../budgets/presentation/widgets/budget_card.dart';
import '../../../planned_expenses/data/models/planned_expense_model.dart';
import '../../../planned_expenses/presentation/controllers/planned_expense_controller.dart';
import '../../../planned_expenses/presentation/widgets/planned_expense_card.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../transactions/utils/transaction_formatters.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({
    required this.onCreateBudget,
    required this.onOpenBudget,
    required this.onCreatePlanned,
    required this.onOpenPlanned,
    super.key,
  });

  final VoidCallback onCreateBudget;
  final ValueChanged<int> onOpenBudget;
  final VoidCallback onCreatePlanned;
  final ValueChanged<int> onOpenPlanned;

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  int _section = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BudgetController>().load();
      context.read<PlannedExpenseController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
              AppSpacing.screenHorizontal,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(context.l10n.plans, style: AppTextStyles.screenTitle),
                const SizedBox(height: AppSpacing.lg),
                SegmentedButton<int>(
                  segments: <ButtonSegment<int>>[
                    ButtonSegment<int>(
                      value: 0,
                      label: Text(context.l10n.budgets),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      label: Text(context.l10n.planned),
                    ),
                  ],
                  selected: <int>{_section},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<int> selection) {
                    setState(() => _section = selection.first);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _section == 0
                ? _BudgetsBody(widget: widget)
                : _PlannedBody(widget: widget),
          ),
        ],
      ),
    );
  }
}

class _BudgetsBody extends StatelessWidget {
  const _BudgetsBody({required this.widget});

  final PlansScreen widget;

  @override
  Widget build(BuildContext context) {
    final BudgetController controller = context.watch<BudgetController>();
    final BudgetMonthModel? data = controller.data;
    final String month = DateFormat.yMMMM(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(controller.month);

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sm,
          AppSpacing.screenHorizontal,
          118,
        ),
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: controller.canGoToPreviousMonth
                    ? controller.goToPreviousMonth
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  month,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.goToNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (controller.isLoading && data == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (data == null)
            _Error(
              message: LocalizedErrorMessage.fromException(
                context,
                controller.error,
              ),
              onRetry: () => controller.load(force: true),
            )
          else ...<Widget>[
            _BudgetSummary(data: data),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: widget.onCreateBudget,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.createBudget),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (data.budgets.isEmpty)
              _Empty(
                icon: Icons.pie_chart_outline_rounded,
                title: context.l10n.noBudgetsYet,
                body: context.l10n.noBudgetsBody,
              )
            else
              for (int index = 0; index < data.budgets.length; index++) ...<Widget>[
                BudgetCard(
                  budget: data.budgets[index],
                  onTap: () => widget.onOpenBudget(data.budgets[index].id),
                ),
                if (index != data.budgets.length - 1)
                  const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ],
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.data});

  final BudgetMonthModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.totalPlannedBudget,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              TransactionFormatters.formatCurrencyAmount(
                context: context,
                currencyCode: data.currencyCode,
                amount: data.totalPlanned,
              ),
              style: AppTextStyles.brandTitle.copyWith(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${context.l10n.spent}: ${TransactionFormatters.formatCurrencyAmount(context: context, currencyCode: data.currencyCode, amount: data.totalSpent)}',
            style: AppTextStyles.helperText.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PlannedBody extends StatelessWidget {
  const _PlannedBody({required this.widget});

  final PlansScreen widget;

  @override
  Widget build(BuildContext context) {
    final PlannedExpenseController controller =
        context.watch<PlannedExpenseController>();
    final DateFormatPreference dateFormat =
        context.watch<ProfileController>().preferences?.dateFormat ??
        UserPreferencesModel.defaults.dateFormat;
    final List<PlannedExpenseModel> items = controller.items;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SegmentedButton<PlannedExpenseStatus>(
                  segments: <ButtonSegment<PlannedExpenseStatus>>[
                    ButtonSegment<PlannedExpenseStatus>(
                      value: PlannedExpenseStatus.upcoming,
                      label: Text(context.l10n.upcoming),
                    ),
                    ButtonSegment<PlannedExpenseStatus>(
                      value: PlannedExpenseStatus.paid,
                      label: Text(context.l10n.paid),
                    ),
                    ButtonSegment<PlannedExpenseStatus>(
                      value: PlannedExpenseStatus.cancelled,
                      label: Text(context.l10n.cancelled),
                    ),
                  ],
                  selected: <PlannedExpenseStatus>{controller.status},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<PlannedExpenseStatus> selection) {
                    unawaited(controller.selectStatus(selection.first));
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: widget.onCreatePlanned,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        if (controller.status == PlannedExpenseStatus.upcoming &&
            items.isNotEmpty &&
            !controller.isLoading) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: _UpcomingSummary(
              count: controller.totalElements,
              totalAmount: controller.totalAmount,
              currencyCode: items.first.currencyCode,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshCurrent,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.extentAfter < 280) {
                  unawaited(controller.loadMore());
                }
                return false;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.sm,
                  AppSpacing.screenHorizontal,
                  118,
                ),
                children: <Widget>[
                  if (controller.isLoading && items.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (items.isEmpty && controller.error != null)
                    _Error(
                      message: LocalizedErrorMessage.fromException(
                        context,
                        controller.error,
                      ),
                      onRetry: () => controller.load(force: true),
                    )
                  else if (items.isEmpty)
                    _Empty(
                      icon: Icons.event_note_outlined,
                      title: context.l10n.noPlannedExpenses,
                      body: context.l10n.noPlannedExpensesBody,
                    )
                  else
                    for (int index = 0; index < items.length; index++) ...<Widget>[
                      PlannedExpenseCard(
                        item: items[index],
                        dateFormat: dateFormat,
                        onTap: () => widget.onOpenPlanned(items[index].id),
                      ),
                      if (index != items.length - 1)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  if (controller.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpcomingSummary extends StatelessWidget {
  const _UpcomingSummary({
    required this.count,
    required this.totalAmount,
    required this.currencyCode,
  });

  final int count;
  final String totalAmount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.l10n.upcoming,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.upcomingExpenseCount(count),
                  style: AppTextStyles.helperText,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(context.l10n.total, style: AppTextStyles.helperText),
              const SizedBox(height: 2),
              Text(
                TransactionFormatters.formatCurrencyAmount(
                  context: context,
                  currencyCode: currencyCode,
                  amount: totalAmount,
                ),
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 42, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTextStyles.helperText,
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.cloud_off_outlined,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
