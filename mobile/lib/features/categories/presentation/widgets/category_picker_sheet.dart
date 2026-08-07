import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/category_model.dart';
import '../../data/models/category_type.dart';
import 'category_icon.dart';

Future<CategoryModel?> showCategoryPickerSheet({
  required BuildContext context,
  required CategoryType type,
  required List<CategoryModel> categories,
  CategoryModel? selectedCategory,
  Future<CategoryModel?> Function()? onCreateCategory,
}) {
  return showModalBottomSheet<CategoryModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return _CategoryPickerSheet(
        type: type,
        categories: categories,
        selectedCategory: selectedCategory,
        onCreateCategory: onCreateCategory,
      );
    },
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    required this.type,
    required this.categories,
    required this.selectedCategory,
    required this.onCreateCategory,
  });

  final CategoryType type;
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final Future<CategoryModel?> Function()? onCreateCategory;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> get _filteredCategories {
    final String query = _query.trim().toLowerCase();
    return widget.categories.where((CategoryModel category) {
      if (category.type != widget.type) {
        return false;
      }
      return query.isEmpty || category.name.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Future<void> _createCategory() async {
    final Future<CategoryModel?> Function()? callback = widget.onCreateCategory;
    if (callback == null || _isCreating) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final CategoryModel? created = await callback();
      if (!mounted || created == null) {
        return;
      }
      Navigator.of(context).pop(created);
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<CategoryModel> categories = _filteredCategories;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.type == CategoryType.income
                          ? l10n.selectIncomeCategory
                          : l10n.selectExpenseCategory,
                      style: AppTextStyles.screenTitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchCategories,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l10n.clearSearch,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _query = '';
                                  });
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _query = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: categories.isEmpty
                    ? _EmptySearchState(query: _query)
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          AppSpacing.sm,
                          AppSpacing.screenHorizontal,
                          AppSpacing.md,
                        ),
                        itemCount: categories.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final CategoryModel category = categories[index];
                          final bool selected =
                              widget.selectedCategory?.id == category.id;
                          return _PickerCategoryTile(
                            category: category,
                            selected: selected,
                            onTap: () => Navigator.of(context).pop(category),
                          );
                        },
                      ),
              ),
              if (widget.onCreateCategory != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.sm,
                      AppSpacing.screenHorizontal,
                      AppSpacing.lg,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: _isCreating ? null : _createCategory,
                      icon: _isCreating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                      label: Text(l10n.addNewCategory),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PickerCategoryTile extends StatelessWidget {
  const _PickerCategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = category.type == CategoryType.income;
    final Color accent = isIncome ? AppColors.accent : AppColors.error;

    return Material(
      color: selected
          ? accent.withValues(alpha: 0.08)
          : AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: accent.withValues(alpha: 0.12),
                foregroundColor: accent,
                child: Icon(CategoryIcon.fromKey(category.iconKey), size: 21),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _CategoryBadge(isSystem: category.isSystem),
              if (selected) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.check_circle_rounded, color: accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.isSystem});

  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        isSystem ? context.l10n.defaultCategory : context.l10n.customCategory,
        style: AppTextStyles.helperText.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              query.trim().isEmpty
                  ? context.l10n.noCategoriesAvailable
                  : context.l10n.noCategorySearchResults,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
