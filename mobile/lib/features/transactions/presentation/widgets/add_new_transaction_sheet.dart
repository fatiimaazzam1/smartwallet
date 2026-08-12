import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/transaction_type.dart';

Future<TransactionType?> showAddNewTransactionSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<TransactionType>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext sheetContext) {
      final AppLocalizations l10n = sheetContext.l10n;
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.addNew,
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _TransactionTypeAction(
                    label: l10n.income,
                    icon: Icons.add_rounded,
                    color: AppColors.accent,
                    onTap: () => Navigator.of(sheetContext).pop(
                      TransactionType.income,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _TransactionTypeAction(
                    label: l10n.expense,
                    icon: Icons.remove_rounded,
                    color: AppColors.error,
                    onTap: () => Navigator.of(sheetContext).pop(
                      TransactionType.expense,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
    },
  );
}

class _TransactionTypeAction extends StatelessWidget {
  const _TransactionTypeAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100F172A),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
