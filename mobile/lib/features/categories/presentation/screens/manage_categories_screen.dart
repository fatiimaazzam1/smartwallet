import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../data/models/category_model.dart';
import '../../data/models/category_type.dart';
import '../controllers/category_controller.dart';
import '../widgets/category_icon.dart';
import '../widgets/create_category_sheet.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  State<ManageCategoriesScreen> createState() =>
      _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategoryController>().load();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final CreateCategoryInput? input = await showCreateCategorySheet(
      context: context,
    );
    if (!mounted || input == null) {
      return;
    }

    final CategoryController controller = context.read<CategoryController>();
    final CategoryModel? created = await controller.createCategory(
      name: input.name,
      type: input.type,
    );

    if (!mounted) {
      return;
    }

    if (created != null) {
      _showMessage(context.l10n.categoryCreated);
      return;
    }

    _showError(controller);
  }

  Future<void> _confirmArchive(CategoryModel category) async {
    final AppLocalizations l10n = context.l10n;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x260F172A),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.deleteCategoryTitle,
                    style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.deleteCategoryBody(category.name),
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: AppColors.textPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.cancel),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.surface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(l10n.deleteCategory),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final CategoryController controller = context.read<CategoryController>();
    final bool archived = await controller.archiveCategory(category);

    if (!mounted) {
      return;
    }

    if (archived) {
      _showMessage(l10n.categoryDeleted);
      return;
    }

    _showError(controller);
  }

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _showError(CategoryController controller) {
    _showMessage(
      LocalizedErrorMessage.fromException(context, controller.error),
    );
  }

  List<CategoryModel> _filter(List<CategoryModel> categories) {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return categories;
    }
    return categories
        .where(
          (CategoryModel category) =>
              category.name.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final CategoryController controller = context.watch<CategoryController>();
    final List<CategoryModel> income = _filter(
      controller.categoriesOfType(CategoryType.income),
    );
    final List<CategoryModel> expense = _filter(
      controller.categoriesOfType(CategoryType.expense),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.goBack,
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.manageCategories),
        actions: [
          IconButton(
            tooltip: l10n.addCategory,
            onPressed: controller.isCreating ? null : _createCategory,
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: controller.isLoading && !controller.hasLoaded
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => controller.load(force: true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.md,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      l10n.manageCategoriesSubtitle,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: AppSpacing.xl),
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
                    if (controller.error != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppStatusMessage(
                        message: LocalizedErrorMessage.fromException(
                          context,
                          controller.error,
                        ),
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    if (income.isEmpty && expense.isEmpty)
                      _EmptyCategoryState(
                        hasQuery: _query.trim().isNotEmpty,
                        onRetry: () => controller.load(force: true),
                      )
                    else ...[
                      if (income.isNotEmpty)
                        _CategorySection(
                          title: l10n.income,
                          count: income.length,
                          color: AppColors.accent,
                          categories: income,
                          archivingCategoryId: controller.archivingCategoryId,
                          onArchive: _confirmArchive,
                        ),
                      if (income.isNotEmpty && expense.isNotEmpty)
                        const SizedBox(height: AppSpacing.xl),
                      if (expense.isNotEmpty)
                        _CategorySection(
                          title: l10n.expense,
                          count: expense.length,
                          color: AppColors.error,
                          categories: expense,
                          archivingCategoryId: controller.archivingCategoryId,
                          onArchive: _confirmArchive,
                        ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.count,
    required this.color,
    required this.categories,
    required this.archivingCategoryId,
    required this.onArchive,
  });

  final String title;
  final int count;
  final Color color;
  final List<CategoryModel> categories;
  final int? archivingCategoryId;
  final ValueChanged<CategoryModel> onArchive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.screenTitle.copyWith(fontSize: 19),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.helperText.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int index = 0; index < categories.length; index++) ...[
                _CategoryRow(
                  category: categories[index],
                  color: color,
                  isArchiving: archivingCategoryId == categories[index].id,
                  onArchive: () => onArchive(categories[index]),
                ),
                if (index < categories.length - 1)
                  const Divider(height: 1, indent: 66),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.color,
    required this.isArchiving,
    required this.onArchive,
  });

  final CategoryModel category;
  final Color color;
  final bool isArchiving;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: color.withValues(alpha: 0.10),
            foregroundColor: color,
            child: Icon(CategoryIcon.fromKey(category.iconKey), size: 21),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _TypeBadge(isSystem: category.isSystem),
          if (category.isCustom) ...[
            const SizedBox(width: AppSpacing.xs),
            if (isArchiving)
              const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              PopupMenuButton<String>(
                tooltip: context.l10n.categoryActions,
                onSelected: (String value) {
                  if (value == 'delete') {
                    onArchive();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          context.l10n.deleteCategory,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isSystem});

  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
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

class _EmptyCategoryState extends StatelessWidget {
  const _EmptyCategoryState({required this.hasQuery, required this.onRetry});

  final bool hasQuery;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.category_outlined,
            size: 50,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasQuery
                ? context.l10n.noCategorySearchResults
                : context.l10n.noCategoriesAvailable,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          if (!hasQuery) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retryLoad)),
          ],
        ],
      ),
    );
  }
}
