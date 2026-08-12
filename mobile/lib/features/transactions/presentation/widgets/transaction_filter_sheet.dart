import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/models/category_type.dart';
import '../../../categories/presentation/widgets/category_icon.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../data/models/transaction_filter_model.dart';
import '../../data/models/transaction_type.dart';
import '../../utils/transaction_formatters.dart';

Future<TransactionFilterModel?> showTransactionFilterSheet({
  required BuildContext context,
  required TransactionFilterModel currentFilters,
  required List<CategoryModel> categories,
  required DateFormatPreference dateFormat,
}) {
  return showModalBottomSheet<TransactionFilterModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return _TransactionFilterSheet(
        currentFilters: currentFilters,
        categories: categories,
        dateFormat: dateFormat,
      );
    },
  );
}

class _TransactionFilterSheet extends StatefulWidget {
  const _TransactionFilterSheet({
    required this.currentFilters,
    required this.categories,
    required this.dateFormat,
  });

  final TransactionFilterModel currentFilters;
  final List<CategoryModel> categories;
  final DateFormatPreference dateFormat;

  @override
  State<_TransactionFilterSheet> createState() =>
      _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<_TransactionFilterSheet> {
  TransactionType? _type;
  CategoryModel? _category;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _type = widget.currentFilters.type;
    _category = _validatedInitialCategory(widget.currentFilters.category);
    _startDate = widget.currentFilters.startDate;
    _endDate = widget.currentFilters.endDate;
  }

  CategoryModel? _validatedInitialCategory(CategoryModel? category) {
    if (category == null) {
      return null;
    }
    final bool exists = widget.categories.any(
      (CategoryModel item) => item.id == category.id,
    );
    return exists ? category : null;
  }

  List<CategoryModel> get _compatibleCategories {
    return widget.categories.where((CategoryModel category) {
      return switch (_type) {
        TransactionType.income => category.type == CategoryType.income,
        TransactionType.expense => category.type == CategoryType.expense,
        null => true,
      };
    }).toList(growable: false);
  }

  void _setType(TransactionType? value) {
    setState(() {
      _type = value;
      final CategoryModel? currentCategory = _category;
      if (currentCategory != null &&
          !_compatibleCategories.any(
            (CategoryModel category) => category.id == currentCategory.id,
          )) {
        _category = null;
      }
    });
  }

  Future<void> _pickCategory() async {
    final CategoryModel? selected = await _showFilterCategoryPicker(
      context: context,
      categories: _compatibleCategories,
      selectedCategory: _category,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _category = selected;
    });
  }

  Future<void> _pickStartDate() async {
    final DateTime today = _today();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _startDate ?? _endDate ?? today,
      firstDate: DateTime(2000),
      lastDate: _endDate ?? today,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _startDate = _dateOnly(selected);
      _dateError = null;
    });
  }

  Future<void> _pickEndDate() async {
    final DateTime today = _today();
    final DateTime firstDate = _startDate ?? DateTime(2000);
    final DateTime initialDate = _endDate ??
        (firstDate.isAfter(today) ? today : firstDate);
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: today,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _endDate = _dateOnly(selected);
      _dateError = null;
    });
  }

  void _reset() {
    setState(() {
      _type = null;
      _category = null;
      _startDate = null;
      _endDate = null;
      _dateError = null;
    });
  }

  void _apply() {
    if (_startDate != null &&
        _endDate != null &&
        _startDate!.isAfter(_endDate!)) {
      setState(() {
        _dateError = context.l10n.transactionDateRangeInvalid;
      });
      return;
    }

    Navigator.of(context).pop(
      TransactionFilterModel(
        type: _type,
        category: _category,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.md,
          AppSpacing.screenHorizontal,
          AppSpacing.xl + bottomInset,
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
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.filterTransactions,
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                  ),
                ),
                TextButton(onPressed: _reset, child: Text(l10n.reset)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.transactionType, style: AppTextStyles.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _TypeFilterChip(
                  label: l10n.all,
                  selected: _type == null,
                  onSelected: () => _setType(null),
                ),
                _TypeFilterChip(
                  label: l10n.income,
                  selected: _type == TransactionType.income,
                  onSelected: () => _setType(TransactionType.income),
                ),
                _TypeFilterChip(
                  label: l10n.expense,
                  selected: _type == TransactionType.expense,
                  onSelected: () => _setType(TransactionType.expense),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.categoryName, style: AppTextStyles.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            _FilterField(
              value: _category?.name ?? l10n.allCategories,
              icon: Icons.keyboard_arrow_down_rounded,
              onTap: _pickCategory,
              onClear: _category == null
                  ? null
                  : () {
                      setState(() {
                        _category = null;
                      });
                    },
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _DateFilterField(
                    label: l10n.startDate,
                    value: _startDate,
                    dateFormat: widget.dateFormat,
                    onTap: _pickStartDate,
                    onClear: _startDate == null
                        ? null
                        : () {
                            setState(() {
                              _startDate = null;
                              _dateError = null;
                            });
                          },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DateFilterField(
                    label: l10n.endDate,
                    value: _endDate,
                    dateFormat: widget.dateFormat,
                    onTap: _pickEndDate,
                    onClear: _endDate == null
                        ? null
                        : () {
                            setState(() {
                              _endDate = null;
                              _dateError = null;
                            });
                          },
                  ),
                ),
              ],
            ),
            if (_dateError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_dateError!, style: AppTextStyles.errorText),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: _apply, child: Text(l10n.applyFilters)),
          ],
        ),
      ),
    );
  }

  static DateTime _today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

class _TypeFilterChip extends StatelessWidget {
  const _TypeFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
      labelStyle: AppTextStyles.body.copyWith(
        color: selected ? AppColors.surface : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.value,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.inputText,
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip: context.l10n.clearSelection,
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                )
              else
                Icon(icon, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateFilterField extends StatelessWidget {
  const _DateFilterField({
    required this.label,
    required this.value,
    required this.dateFormat,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final DateFormatPreference dateFormat;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final String text = value == null
        ? context.l10n.selectDate
        : TransactionFormatters.formatDate(value!, dateFormat);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: AppSpacing.sm),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: value == null
                          ? AppTextStyles.inputHint
                          : AppTextStyles.inputText,
                    ),
                  ),
                  if (onClear != null)
                    IconButton(
                      tooltip: context.l10n.clearSelection,
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 18),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
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

Future<CategoryModel?> _showFilterCategoryPicker({
  required BuildContext context,
  required List<CategoryModel> categories,
  required CategoryModel? selectedCategory,
}) {
  return showModalBottomSheet<CategoryModel>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return _FilterCategoryPicker(
        categories: categories,
        selectedCategory: selectedCategory,
      );
    },
  );
}

class _FilterCategoryPicker extends StatefulWidget {
  const _FilterCategoryPicker({
    required this.categories,
    required this.selectedCategory,
  });

  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;

  @override
  State<_FilterCategoryPicker> createState() => _FilterCategoryPickerState();
}

class _FilterCategoryPickerState extends State<_FilterCategoryPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> get _filtered {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.categories;
    }
    return widget.categories
        .where(
          (CategoryModel category) =>
              category.name.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<CategoryModel> categories = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.45,
      maxChildSize: 0.92,
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
                      context.l10n.selectCategory,
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: context.l10n.searchCategories,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: context.l10n.clearSearch,
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
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            _query.trim().isEmpty
                                ? context.l10n.noCategoriesAvailable
                                : context.l10n.noCategorySearchResults,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          AppSpacing.sm,
                          AppSpacing.screenHorizontal,
                          AppSpacing.xl,
                        ),
                        itemCount: categories.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (BuildContext context, int index) {
                          final CategoryModel category = categories[index];
                          final bool selected =
                              widget.selectedCategory?.id == category.id;
                          final bool income =
                              category.type == CategoryType.income;
                          final Color accent = income
                              ? AppColors.accent
                              : AppColors.error;

                          return Material(
                            color: selected
                                ? accent.withValues(alpha: 0.08)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () =>
                                  Navigator.of(context).pop(category),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: accent.withValues(
                                        alpha: 0.10,
                                      ),
                                      foregroundColor: accent,
                                      child: Icon(
                                        CategoryIcon.fromKey(category.iconKey),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            income
                                                ? context.l10n.income
                                                : context.l10n.expense,
                                            style: AppTextStyles.helperText,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (selected)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: accent,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
