import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/transaction_filter_model.dart';
import '../controllers/transaction_history_controller.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_filter_sheet.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({
    required this.onOpenTransaction,
    super.key,
  });

  final ValueChanged<int> onOpenTransaction;

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final TransactionHistoryController controller = context
        .read<TransactionHistoryController>();
    _searchController = TextEditingController(text: controller.query);
    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    if (position.extentAfter < 320) {
      context.read<TransactionHistoryController>().loadMore();
    }
  }

  Future<void> _openFilters() async {
    final CategoryController categoryController = context
        .read<CategoryController>();
    await categoryController.load();
    if (!mounted) {
      return;
    }

    if (categoryController.categories.isEmpty &&
        categoryController.error != null) {
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              LocalizedErrorMessage.fromException(
                context,
                categoryController.error,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    final ProfileController profileController = context.read<ProfileController>();
    final DateFormatPreference dateFormat =
        profileController.preferences?.dateFormat ??
        UserPreferencesModel.defaults.dateFormat;
    final TransactionHistoryController historyController = context
        .read<TransactionHistoryController>();

    final TransactionFilterModel? filters = await showTransactionFilterSheet(
      context: context,
      currentFilters: historyController.filters,
      categories: categoryController.categories,
      dateFormat: dateFormat,
    );

    if (!mounted || filters == null) {
      return;
    }
    await historyController.applyFilters(filters);
  }

  @override
  Widget build(BuildContext context) {
    final TransactionHistoryController controller = context
        .watch<TransactionHistoryController>();
    final ProfileController profileController = context.watch<ProfileController>();
    final UserPreferencesModel preferences =
        profileController.preferences ?? UserPreferencesModel.defaults;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xl,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.transactions,
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        maxLength: 100,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: context.l10n.searchTransactions,
                          counterText: '',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: context.l10n.clearSearch,
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.setSearchQuery('');
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (String value) {
                          controller.setSearchQuery(value);
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _FilterButton(
                      activeCount: controller.activeFilterCount,
                      onTap: _openFilters,
                    ),
                  ],
                ),
                if (controller.hasActiveFilters) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          context.l10n.activeFiltersCount(
                            controller.activeFilterCount,
                          ),
                          style: AppTextStyles.helperText,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.isInitialLoading
                            ? null
                            : controller.resetFilters,
                        child: Text(context.l10n.reset),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (controller.isInitialLoading && controller.history.isNotEmpty)
            const LinearProgressIndicator(minHeight: 2),
          if (controller.history.isNotEmpty && controller.historyError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      LocalizedErrorMessage.fromException(
                        context,
                        controller.historyError,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.helperText.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.isRefreshing
                        ? null
                        : controller.refreshHistory,
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _HistoryBody(
              controller: controller,
              scrollController: _scrollController,
              preferences: preferences,
              onOpenTransaction: widget.onOpenTransaction,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.controller,
    required this.scrollController,
    required this.preferences,
    required this.onOpenTransaction,
  });

  final TransactionHistoryController controller;
  final ScrollController scrollController;
  final UserPreferencesModel preferences;
  final ValueChanged<int> onOpenTransaction;

  @override
  Widget build(BuildContext context) {
    if (controller.isInitialLoading && controller.history.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.history.isEmpty && controller.historyError != null) {
      return _HistoryErrorState(
        message: LocalizedErrorMessage.fromException(
          context,
          controller.historyError,
        ),
        onRetry: () => controller.loadInitial(force: true),
      );
    }

    if (controller.history.isEmpty) {
      final bool narrowed = controller.hasSearch || controller.hasActiveFilters;
      return RefreshIndicator(
        onRefresh: controller.refreshHistory,
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            118,
          ),
          children: [
            _EmptyHistoryState(
              narrowed: narrowed,
              onReset: controller.hasActiveFilters
                  ? controller.resetFilters
                  : null,
            ),
          ],
        ),
      );
    }

    final int footerItems = controller.isLoadingMore ||
            controller.paginationError != null
        ? 1
        : 0;

    return RefreshIndicator(
      onRefresh: controller.refreshHistory,
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          118,
        ),
        itemCount: controller.history.length + footerItems,
        separatorBuilder: (_, int index) {
          if (index >= controller.history.length - 1) {
            return const SizedBox(height: AppSpacing.md);
          }
          return SizedBox(
            height: preferences.compactTransactionList
                ? AppSpacing.sm
                : AppSpacing.md,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          if (index >= controller.history.length) {
            if (controller.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              );
            }

            return _PaginationError(
              message: LocalizedErrorMessage.fromException(
                context,
                controller.paginationError,
              ),
              onRetry: controller.retryLoadMore,
            );
          }

          final transaction = controller.history[index];
          return TransactionCard(
            transaction: transaction,
            dateFormat: preferences.dateFormat,
            compact: preferences.compactTransactionList,
            onTap: () => onOpenTransaction(transaction.id),
          );
        },
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onTap});

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.filterTransactions,
      child: Material(
        color: activeCount > 0
            ? AppColors.primary
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activeCount > 0
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.filter_alt_outlined,
                  color: activeCount > 0
                      ? AppColors.surface
                      : AppColors.textPrimary,
                ),
                if (activeCount > 0)
                  PositionedDirectional(
                    top: 5,
                    end: 5,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$activeCount',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.helperText.copyWith(
                          color: AppColors.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState({required this.narrowed, this.onReset});

  final bool narrowed;
  final Future<void> Function()? onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              narrowed ? Icons.search_off_rounded : Icons.receipt_long_outlined,
              color: AppColors.textSecondary,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            narrowed
                ? context.l10n.noMatchingTransactions
                : context.l10n.noTransactionsYet,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            narrowed
                ? context.l10n.adjustSearchOrFilters
                : context.l10n.noTransactionsYetBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
          if (onReset != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () => onReset!(),
              child: Text(context.l10n.resetFilters),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryErrorState extends StatelessWidget {
  const _HistoryErrorState({required this.message, required this.onRetry});

  final String message;
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
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
          ],
        ),
      ),
    );
  }
}

class _PaginationError extends StatelessWidget {
  const _PaginationError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.helperText,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}
