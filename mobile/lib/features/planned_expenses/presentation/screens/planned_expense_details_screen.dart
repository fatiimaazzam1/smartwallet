import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../budgets/presentation/controllers/budget_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../transactions/presentation/controllers/transaction_history_controller.dart';
import '../../../transactions/utils/transaction_formatters.dart';
import '../../../transactions/utils/transaction_request_id.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import '../../data/models/planned_expense_model.dart';
import '../controllers/planned_expense_controller.dart';
import '../controllers/planned_expense_details_controller.dart';

class PlannedExpenseDetailsScreen extends StatefulWidget {
  const PlannedExpenseDetailsScreen({required this.onEdit, super.key});

  final Future<bool?> Function() onEdit;

  @override
  State<PlannedExpenseDetailsScreen> createState() => _State();
}

class _State extends State<PlannedExpenseDetailsScreen> {
  bool _opening = false;
  String? _paymentRequestId;
  DateTime? _paymentDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PlannedExpenseDetailsController>().load();
    });
  }

  Future<void> _edit() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final bool? changed = await widget.onEdit();
      if (changed == true && mounted) {
        await context.read<PlannedExpenseDetailsController>().load(force: true);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _markPaid() async {
    final PlannedExpenseDetailsController controller =
        context.read<PlannedExpenseDetailsController>();
    final PlannedExpenseModel? item = controller.item;
    if (item == null) return;

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    _paymentDate ??= today;

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _paymentDate!,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: context.l10n.confirmPaymentDate,
    );
    if (selected == null || !mounted) return;

    _paymentDate = DateTime(selected.year, selected.month, selected.day);
    _paymentRequestId ??= TransactionRequestId.generate();
    final bool success = await controller.markPaid(
      paidOn: _paymentDate!,
      clientRequestId: _paymentRequestId!,
    );
    if (!mounted) return;

    if (!success) {
      _message(LocalizedErrorMessage.fromException(context, controller.error));
      return;
    }

    _paymentRequestId = null;
    await _refreshFinancial();
    if (mounted) _message(context.l10n.plannedMarkedPaid);
  }

  Future<void> _cancel() async {
    final bool confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.cancelPlannedExpense,
      message: context.l10n.cancelPlannedExpenseBody,
      cancelLabel: context.l10n.keepPlanned,
      confirmLabel: context.l10n.cancelPlannedExpense,
      destructive: true,
    );
    if (!mounted || !confirmed) return;

    final PlannedExpenseDetailsController controller =
        context.read<PlannedExpenseDetailsController>();
    if (!await controller.cancel()) {
      if (mounted) {
        _message(LocalizedErrorMessage.fromException(context, controller.error));
      }
      return;
    }
    await _refreshPlanning();
    if (mounted) _message(context.l10n.plannedCancelled);
  }

  Future<void> _delete() async {
    final bool confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.deletePlannedExpense,
      message: context.l10n.deletePlannedExpenseBody,
      cancelLabel: context.l10n.cancel,
      confirmLabel: context.l10n.delete,
      destructive: true,
    );
    if (!mounted || !confirmed) return;

    final PlannedExpenseDetailsController controller =
        context.read<PlannedExpenseDetailsController>();
    if (!await controller.delete()) {
      if (mounted) {
        _message(LocalizedErrorMessage.fromException(context, controller.error));
      }
      return;
    }

    await _refreshPlanning();
    if (!mounted) return;
    _message(context.l10n.plannedDeleted);
    Navigator.of(context).pop(true);
  }

  Future<void> _refreshPlanning() async {
    await Future.wait<void>(<Future<void>>[
      context.read<PlannedExpenseController>().refreshAll(),
      context.read<DashboardController>().load(force: true),
    ]);
  }

  Future<void> _refreshFinancial() async {
    await Future.wait<void>(<Future<void>>[
      context.read<WalletController>().load(force: true),
      context.read<TransactionHistoryController>().refreshAfterMutation(),
      context.read<BudgetController>().refresh(),
      _refreshPlanning(),
    ]);
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
    final PlannedExpenseDetailsController controller =
        context.watch<PlannedExpenseDetailsController>();
    final PlannedExpenseModel? item = controller.item;
    final DateFormatPreference dateFormat =
        context.watch<ProfileController>().preferences?.dateFormat ??
        UserPreferencesModel.defaults.dateFormat;

    return PopScope<bool>(
      canPop: !controller.isBusy,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          title: Text(
            context.l10n.plannedExpenseDetails,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
          ),
        actions: <Widget>[
          if (item?.status == PlannedExpenseStatus.upcoming)
            TextButton(
              onPressed: controller.isBusy || _opening ? null : _edit,
              child: Text(context.l10n.edit),
            ),
        ],
      ),
      body: SafeArea(
        child: item == null
            ? controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              LocalizedErrorMessage.fromException(
                                context,
                                controller.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: () => controller.load(force: true),
                              child: Text(context.l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.lg,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxxl,
                ),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            TransactionFormatters.formatCurrencyAmount(
                              context: context,
                              currencyCode: item.currencyCode,
                              amount: item.amount,
                            ),
                            style: AppTextStyles.brandTitle.copyWith(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusLabel(context, item),
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _DetailRow(
                    label: context.l10n.category,
                    value: item.category.name,
                  ),
                  _DetailRow(
                    label: context.l10n.dueDate,
                    value: TransactionFormatters.formatDate(
                      item.dueOn,
                      dateFormat,
                    ),
                  ),
                  _DetailRow(
                    label: context.l10n.recurrence,
                    value: _recurrenceLabel(context, item.recurrence),
                  ),
                  if (item.note != null)
                    _DetailRow(label: context.l10n.note, value: item.note!),
                  const SizedBox(height: AppSpacing.xl),
                  if (item.status == PlannedExpenseStatus.upcoming) ...<Widget>[
                    FilledButton.icon(
                      onPressed: controller.isBusy ? null : _markPaid,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(context.l10n.markAsPaid),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: controller.isBusy ? null : _cancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: Text(context.l10n.cancelPlannedExpense),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: controller.isBusy ? null : _delete,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: Text(context.l10n.deletePlannedExpense),
                    ),
                  ] else if (item.status == PlannedExpenseStatus.cancelled)
                    TextButton(
                      onPressed: controller.isBusy ? null : _delete,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: Text(context.l10n.deletePlannedExpense),
                    ),
                ],
              ),
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, PlannedExpenseModel item) {
    if (item.status == PlannedExpenseStatus.upcoming) {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      if (item.dueOn.isBefore(today)) {
        return context.l10n.overdue;
      }
    }
    return switch (item.status) {
      PlannedExpenseStatus.upcoming => context.l10n.upcoming,
      PlannedExpenseStatus.paid => context.l10n.paid,
      PlannedExpenseStatus.cancelled => context.l10n.cancelled,
    };
  }

  String _recurrenceLabel(
    BuildContext context,
    PlannedExpenseRecurrence recurrence,
  ) => switch (recurrence) {
    PlannedExpenseRecurrence.none => context.l10n.recurrenceNone,
    PlannedExpenseRecurrence.weekly => context.l10n.weekly,
    PlannedExpenseRecurrence.monthly => context.l10n.monthly,
    PlannedExpenseRecurrence.yearly => context.l10n.yearly,
  };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(label, style: AppTextStyles.helperText),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              softWrap: true,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
