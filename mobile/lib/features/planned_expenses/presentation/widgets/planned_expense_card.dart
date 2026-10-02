import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/presentation/widgets/category_icon.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../transactions/utils/transaction_formatters.dart';
import '../../data/models/planned_expense_model.dart';

class PlannedExpenseCard extends StatelessWidget {
  const PlannedExpenseCard({
    required this.item,
    required this.dateFormat,
    required this.onTap,
    super.key,
  });

  final PlannedExpenseModel item;
  final DateFormatPreference dateFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool overdue = _isOverdue(item);
    final Color accent = item.status == PlannedExpenseStatus.paid
        ? AppColors.accent
        : item.status == PlannedExpenseStatus.cancelled
        ? AppColors.disabled
        : AppColors.error;
    final String date = TransactionFormatters.formatDate(item.dueOn, dateFormat);
    final String subtitle = overdue
        ? '${item.category.name} · $date · ${context.l10n.overdue}'
        : '${item.category.name} · $date';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(CategoryIcon.fromKey(item.category.iconKey), color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.helperText.copyWith(
                        color: overdue ? AppColors.error : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    TransactionFormatters.formatCurrencyAmount(
                      context: context,
                      currencyCode: item.currencyCode,
                      amount: item.amount,
                    ),
                    style: AppTextStyles.body.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isOverdue(PlannedExpenseModel item) {
    if (item.status != PlannedExpenseStatus.upcoming) return false;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return item.dueOn.isBefore(today);
  }
}
