import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/category_type.dart';

final class CreateCategoryInput {
  const CreateCategoryInput({required this.name, required this.type});

  final String name;
  final CategoryType type;
}

Future<CreateCategoryInput?> showCreateCategorySheet({
  required BuildContext context,
  CategoryType? fixedType,
}) {
  return showModalBottomSheet<CreateCategoryInput>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return _CreateCategorySheet(fixedType: fixedType);
    },
  );
}

class _CreateCategorySheet extends StatefulWidget {
  const _CreateCategorySheet({this.fixedType});

  final CategoryType? fixedType;

  @override
  State<_CreateCategorySheet> createState() => _CreateCategorySheetState();
}

class _CreateCategorySheetState extends State<_CreateCategorySheet> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late CategoryType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.fixedType ?? CategoryType.expense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.of(context).pop(
      CreateCategoryInput(
        name: _nameController.text.trim(),
        type: _selectedType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final double bottomSafeInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xl + keyboardInset + bottomSafeInset,
        ),
        child: Form(
          key: _formKey,
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
                l10n.createCategory,
                style: AppTextStyles.screenTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.createCategorySubtitle,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (widget.fixedType == null) ...[
                Text(l10n.categoryType, style: AppTextStyles.fieldLabel),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<CategoryType>(
                  segments: <ButtonSegment<CategoryType>>[
                    ButtonSegment<CategoryType>(
                      value: CategoryType.income,
                      icon: const Icon(Icons.arrow_downward_rounded),
                      label: Text(l10n.income),
                    ),
                    ButtonSegment<CategoryType>(
                      value: CategoryType.expense,
                      icon: const Icon(Icons.arrow_upward_rounded),
                      label: Text(l10n.expense),
                    ),
                  ],
                  selected: <CategoryType>{_selectedType},
                  showSelectedIcon: false,
                  onSelectionChanged: (Set<CategoryType> selection) {
                    setState(() {
                      _selectedType = selection.first;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ] else ...[
                _FixedTypeCard(type: _selectedType),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(l10n.categoryName, style: AppTextStyles.fieldLabel),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                maxLength: 50,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: l10n.categoryNameHint,
                  counterText: '',
                ),
                validator: (String? value) {
                  final String normalized = (value ?? '')
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' ');
                  if (normalized.isEmpty) {
                    return l10n.categoryNameRequired;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _submit,
                child: Text(l10n.saveCategory),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FixedTypeCard extends StatelessWidget {
  const _FixedTypeCard({required this.type});

  final CategoryType type;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = type == CategoryType.income;
    final Color color = isIncome ? AppColors.accent : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            isIncome ? context.l10n.income : context.l10n.expense,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
