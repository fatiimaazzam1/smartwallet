import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../categories/presentation/widgets/category_icon.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../transactions/utils/transaction_formatters.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/budget_related_expense_model.dart';
import '../controllers/budget_controller.dart';
import '../controllers/budget_details_controller.dart';

class BudgetDetailsScreen extends StatefulWidget {
  const BudgetDetailsScreen({required this.onEdit, super.key});

  final Future<bool?> Function() onEdit;

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  bool _openingEdit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BudgetDetailsController>().load();
      }
    });
  }

  Future<void> _edit() async {
    if (_openingEdit) return;
    setState(() => _openingEdit = true);
    try {
      final bool? changed = await widget.onEdit();
      if (changed == true && mounted) {
        await context.read<BudgetDetailsController>().load(force: true);
      }
    } finally {
      if (mounted) setState(() => _openingEdit = false);
    }
  }

  Future<void> _delete() async {
    final bool confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.deleteBudget,
      message: context.l10n.deleteBudgetBody,
      cancelLabel: context.l10n.cancel,
      confirmLabel: context.l10n.delete,
      destructive: true,
    );
    if (!mounted || !confirmed) return;

    final BudgetDetailsController controller =
        context.read<BudgetDetailsController>();
    final BudgetController budgetController = context.read<BudgetController>();
    final DashboardController dashboardController =
        context.read<DashboardController>();
    if (!await controller.delete()) {
      if (mounted) {
        _message(LocalizedErrorMessage.fromException(context, controller.error));
      }
      return;
    }

    await Future.wait<void>(<Future<void>>[
      budgetController.refresh(),
      dashboardController.load(force: true),
    ]);
    if (!mounted) return;
    _message(context.l10n.budgetDeleted);
    Navigator.of(context).pop(true);
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final BudgetDetailsController controller =
        context.watch<BudgetDetailsController>();
    final BudgetModel? budget = controller.budget;

    return PopScope<bool>(
      canPop: !controller.isDeleting,
      child: Scaffold(
        appBar: AppBar(
        title: Text(context.l10n.budgetDetails),
        actions: <Widget>[
          if (budget != null)
            TextButton(
              onPressed: controller.isDeleting || _openingEdit ? null : _edit,
              child: Text(context.l10n.edit),
            ),
        ],
      ),
      body: SafeArea(
        child: budget == null
            ? controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ErrorState(
                      message: LocalizedErrorMessage.fromException(
                        context,
                        controller.error,
                      ),
                      onRetry: () => controller.load(force: true),
                    )
            : _BudgetDetailsBody(
                budget: budget,
                relatedExpenses: controller.relatedExpenses,
                relatedError: controller.relatedError,
                loadingRelated: controller.isLoadingRelated,
                onRetryRelated: () => controller.loadRelatedExpenses(force: true),
                deleting: controller.isDeleting,
                onDelete: _delete,
              ),
        ),
      ),
    );
  }
}

class _BudgetDetailsBody extends StatelessWidget {
  const _BudgetDetailsBody({
    required this.budget,
    required this.relatedExpenses,
    required this.relatedError,
    required this.loadingRelated,
    required this.onRetryRelated,
    required this.deleting,
    required this.onDelete,
  });

  final BudgetModel budget;
  final List<BudgetRelatedExpenseModel> relatedExpenses;
  final AppException? relatedError;
  final bool loadingRelated;
  final VoidCallback onRetryRelated;
  final bool deleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final DateFormatPreference dateFormat =
        context.watch<ProfileController>().preferences?.dateFormat ??
        UserPreferencesModel.defaults.dateFormat;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      children: <Widget>[
        _BudgetHero(budget: budget),
        const SizedBox(height: AppSpacing.xl),
        _MetricCard(
          children: <Widget>[
            _MetricRow(
              label: context.l10n.spent,
              value: TransactionFormatters.formatCurrencyAmount(
                context: context,
                currencyCode: budget.currencyCode,
                amount: budget.spentAmount,
              ),
            ),
            const Divider(height: AppSpacing.xl),
            _MetricRow(
              label: context.l10n.remaining,
              value: TransactionFormatters.formatCurrencyAmount(
                context: context,
                currencyCode: budget.currencyCode,
                amount: budget.remainingAmount,
              ),
            ),
            const Divider(height: AppSpacing.xl),
            _MetricRow(
              label: context.l10n.daysRemaining,
              value: '${budget.daysRemaining}',
            ),
          ],
        ),
        if (budget.note != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xl),
          Text(context.l10n.note, style: AppTextStyles.fieldLabel),
          const SizedBox(height: AppSpacing.sm),
          Text(budget.note!, style: AppTextStyles.body),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          context.l10n.relatedExpenses,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.relatedExpensesHelper,
          style: AppTextStyles.helperText,
        ),
        const SizedBox(height: AppSpacing.md),
        if (loadingRelated && relatedExpenses.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (relatedError != null && relatedExpenses.isEmpty)
          _InlineError(
            message: context.l10n.relatedExpensesLoadError,
            onRetry: onRetryRelated,
          )
        else if (relatedExpenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              context.l10n.noRelatedExpensesForMonth,
              textAlign: TextAlign.center,
              style: AppTextStyles.helperText,
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: List<Widget>.generate(relatedExpenses.length, (int index) {
                final BudgetRelatedExpenseModel expense = relatedExpenses[index];
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.error.withValues(alpha: .08),
                        child: Icon(
                          CategoryIcon.fromKey(budget.category.iconKey),
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        expense.description ?? budget.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        TransactionFormatters.formatDate(
                          expense.occurredOn,
                          dateFormat,
                        ),
                        style: AppTextStyles.helperText,
                      ),
                      trailing: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '-${TransactionFormatters.formatCurrencyAmount(context: context, currencyCode: budget.currencyCode, amount: expense.amount)}',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                    if (index != relatedExpenses.length - 1)
                      const Divider(height: 1),
                  ],
                );
              }),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
        OutlinedButton.icon(
          onPressed: deleting ? null : onDelete,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
          ),
          icon: const Icon(Icons.delete_outline_rounded),
          label: Text(context.l10n.deleteBudget),
        ),
      ],
    );
  }
}

class _BudgetHero extends StatelessWidget {
  const _BudgetHero({required this.budget});

  final BudgetModel budget;

  @override
  Widget build(BuildContext context) {
    final double progress =
        ((double.tryParse(budget.percentageUsed) ?? 0).clamp(0, 100)) / 100;
    final Color accent = switch (budget.health) {
      'LIMIT_REACHED' => AppColors.error,
      'WARNING' => Colors.orange.shade700,
      _ => AppColors.accent,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  CategoryIcon.fromKey(budget.category.iconKey),
                  color: accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  budget.category.name,
                  style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(context.l10n.monthlyLimit, style: AppTextStyles.helperText),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              TransactionFormatters.formatCurrencyAmount(
                context: context,
                currencyCode: budget.currencyCode,
                amount: budget.limitAmount,
              ),
              style: AppTextStyles.brandTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: accent,
              backgroundColor: AppColors.background,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${budget.percentageUsed}% ${context.l10n.used}',
            style: AppTextStyles.helperText.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(label, style: AppTextStyles.body)),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.helperText,
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
