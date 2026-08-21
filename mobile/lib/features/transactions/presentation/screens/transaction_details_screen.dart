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
import '../../../categories/presentation/widgets/category_icon.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_type.dart';
import '../../utils/transaction_formatters.dart';
import '../controllers/transaction_details_controller.dart';
import '../controllers/transaction_history_controller.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({required this.onEdit, super.key});

  final Future<bool?> Function() onEdit;

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  bool _isOpeningEdit = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionDetailsController>().load();
      }
    });
  }

  Future<void> _edit() async {
    if (_isOpeningEdit) {
      return;
    }

    setState(() {
      _isOpeningEdit = true;
    });

    try {
      final bool? updated = await widget.onEdit();
      if (!mounted || updated != true) {
        return;
      }
      await context.read<TransactionDetailsController>().load(force: true);
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningEdit = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    final bool confirmed = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.deleteTransactionTitle,
      message: context.l10n.deleteTransactionBody,
      cancelLabel: context.l10n.cancel,
      confirmLabel: context.l10n.delete,
      destructive: true,
    );

    if (!mounted || !confirmed) {
      return;
    }

    final TransactionDetailsController controller = context
        .read<TransactionDetailsController>();
    final bool deleted = await controller.delete();
    if (!mounted) {
      return;
    }

    if (!deleted) {
      _showMessage(
        LocalizedErrorMessage.fromException(context, controller.error),
      );
      return;
    }

    final TransactionHistoryController historyController = context
        .read<TransactionHistoryController>();
    historyController.removeTransaction(controller.transactionId);

    await Future.wait<void>(<Future<void>>[
      context.read<WalletController>().load(force: true),
      historyController.refreshAfterMutation(),
      context.read<BudgetController>().refresh(),
      context.read<DashboardController>().load(force: true),
    ]);

    if (!mounted) {
      return;
    }
    _showMessage(context.l10n.transactionDeletedSuccessfully);
    Navigator.of(context).pop(true);
  }

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final TransactionDetailsController controller = context
        .watch<TransactionDetailsController>();
    final ProfileController profileController = context.watch<ProfileController>();
    final DateFormatPreference dateFormat =
        profileController.preferences?.dateFormat ??
        UserPreferencesModel.defaults.dateFormat;
    final TransactionModel? transaction = controller.transaction;

    return PopScope<bool>(
      canPop: !controller.isDeleting,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.transactionDetails),
          actions: [
            if (transaction != null)
              TextButton(
                onPressed: controller.isDeleting || _isOpeningEdit ? null : _edit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                ),
                child: Text(context.l10n.edit),
              ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
        body: SafeArea(
          child: _buildBody(context, controller, transaction, dateFormat),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransactionDetailsController controller,
    TransactionModel? transaction,
    DateFormatPreference dateFormat,
  ) {
    if (transaction == null &&
        (controller.isLoading || controller.error == null)) {
      return const _DetailsLoading();
    }

    if (transaction == null) {
      final bool unavailable = controller.error?.statusCode == 404;
      return _DetailsError(
        title: unavailable
            ? context.l10n.transactionUnavailable
            : context.l10n.unableToLoadTransaction,
        message: unavailable
            ? context.l10n.transactionUnavailableBody
            : LocalizedErrorMessage.fromException(context, controller.error),
        showRetry: !unavailable,
        onRetry: () => controller.load(force: true),
      );
    }

    final bool income = transaction.type == TransactionType.income;
    final Color accent = income ? AppColors.accent : AppColors.error;
    final String amount = TransactionFormatters.formatSignedCurrencyAmount(
      context: context,
      currencyCode: transaction.currencyCode,
      amount: transaction.amount,
      type: transaction.type,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    CategoryIcon.fromKey(transaction.category.iconKey),
                    color: accent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      amount,
                      maxLines: 1,
                      style: AppTextStyles.brandTitle.copyWith(
                        fontSize: 32,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  transaction.category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: context.l10n.status,
                  value: context.l10n.recorded,
                  valueColor: AppColors.accent,
                  leadingValue: const Icon(
                    Icons.circle,
                    size: 8,
                    color: AppColors.accent,
                  ),
                ),
                _DetailRow(
                  label: context.l10n.date,
                  value: TransactionFormatters.formatDate(
                    transaction.occurredOn,
                    dateFormat,
                  ),
                ),
                _DetailRow(
                  label: context.l10n.description,
                  value: transaction.description?.trim().isNotEmpty == true
                      ? transaction.description!.trim()
                      : context.l10n.noDescription,
                  allowMultipleLines: true,
                ),
                _DetailRow(
                  label: context.l10n.type,
                  value: income ? context.l10n.income : context.l10n.expense,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: controller.isDeleting || _isOpeningEdit
                ? null
                : _delete,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              minimumSize: const Size.fromHeight(48),
            ),
            child: controller.isDeleting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Text(context.l10n.deleteTransaction),
          ),
          if (controller.error != null && !controller.isDeleting) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              LocalizedErrorMessage.fromException(context, controller.error),
              textAlign: TextAlign.center,
              style: AppTextStyles.errorText,
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.leadingValue,
    this.allowMultipleLines = false,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Widget? leadingValue;
  final bool allowMultipleLines;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: allowMultipleLines
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(label, style: AppTextStyles.helperText),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (leadingValue != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: leadingValue!,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        value,
                        maxLines: allowMultipleLines ? 5 : 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.body.copyWith(
                          color: valueColor ?? AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ],
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({
    required this.title,
    required this.message,
    required this.showRetry,
    required this.onRetry,
  });

  final String title;
  final String message;
  final bool showRetry;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            if (showRetry) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
            ],
          ],
        ),
      ),
    );
  }
}
