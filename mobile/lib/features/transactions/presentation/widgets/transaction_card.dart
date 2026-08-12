import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/presentation/widgets/category_icon.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_type.dart';
import '../../utils/transaction_formatters.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    required this.transaction,
    required this.dateFormat,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final TransactionModel transaction;
  final DateFormatPreference dateFormat;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == TransactionType.income;
    final Color accent = isIncome ? AppColors.accent : AppColors.error;
    final String description = transaction.description?.trim() ?? '';
    final String primary = description.isEmpty
        ? transaction.category.name
        : description;
    final String date = TransactionFormatters.formatDate(
      transaction.occurredOn,
      dateFormat,
    );
    final String secondary = description.isEmpty
        ? date
        : '${transaction.category.name} · $date';
    final String amount = TransactionFormatters.formatSignedCurrencyAmount(
      context: context,
      currencyCode: transaction.currencyCode,
      amount: transaction.amount,
      type: transaction.type,
    );

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 64 : 78),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: compact ? AppSpacing.sm : AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 40 : 46,
                height: compact ? 40 : 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  CategoryIcon.fromKey(transaction.category.iconKey),
                  color: accent,
                  size: compact ? 20 : 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primary,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        height: compact ? 1.2 : 1.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      secondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.helperText,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      amount,
                      maxLines: 1,
                      style: AppTextStyles.body.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 13 : 14,
                      ),
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
}
