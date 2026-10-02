import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/presentation/widgets/category_icon.dart';
import '../../../transactions/utils/transaction_formatters.dart';
import '../../data/models/budget_model.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    required this.budget,
    required this.onTap,
    super.key,
  });

  final BudgetModel budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double progress =
        ((double.tryParse(budget.percentageUsed) ?? 0).clamp(0, 100)) / 100;
    final Color accent = switch (budget.health) {
      'LIMIT_REACHED' => AppColors.error,
      'WARNING' => Colors.orange.shade700,
      _ => AppColors.accent,
    };

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      CategoryIcon.fromKey(budget.category.iconKey),
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          budget.category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${budget.percentageUsed}% ${context.l10n.used}',
                          style: AppTextStyles.helperText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        TransactionFormatters.formatCurrencyAmount(
                          context: context,
                          currencyCode: budget.currencyCode,
                          amount: budget.limitAmount,
                        ),
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.background,
                  color: accent,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${context.l10n.spent}: ${TransactionFormatters.formatCurrencyAmount(context: context, currencyCode: budget.currencyCode, amount: budget.spentAmount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.helperText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${context.l10n.daysRemaining}: ${budget.daysRemaining}',
                    style: AppTextStyles.helperText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
