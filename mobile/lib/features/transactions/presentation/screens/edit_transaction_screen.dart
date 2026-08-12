import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../categories/presentation/widgets/category_picker_sheet.dart';
import '../../../categories/presentation/widgets/create_category_sheet.dart';
import '../../../profile/data/models/user_preferences_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_type.dart';
import '../../utils/transaction_formatters.dart';
import '../../utils/transaction_input.dart';
import '../controllers/edit_transaction_controller.dart';
import '../controllers/transaction_history_controller.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  EditTransactionController? _networkController;
  int? _hydratedVersion;
  CategoryModel? _selectedCategory;
  DateTime? _occurredOn;
  String _initialAmount = '';
  String _initialDescription = '';
  int? _initialCategoryId;
  DateTime? _initialDate;
  bool _showCategoryError = false;
  bool _allowPop = false;
  bool _isCompletingSuccess = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<EditTransactionController>().load();
      context.read<CategoryController>().load();
      context.read<WalletController>().load();
      context.read<ProfileController>().load();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final EditTransactionController controller = context
        .read<EditTransactionController>();
    if (!identical(_networkController, controller)) {
      _networkController?.removeListener(_onNetworkStateChanged);
      _networkController = controller;
      controller.addListener(_onNetworkStateChanged);
      _onNetworkStateChanged();
    }
  }

  @override
  void dispose() {
    _networkController?.removeListener(_onNetworkStateChanged);
    _amountController
      ..removeListener(_onFormChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onFormChanged)
      ..dispose();
    super.dispose();
  }

  void _onNetworkStateChanged() {
    final TransactionModel? transaction = _networkController?.transaction;
    if (!mounted ||
        transaction == null ||
        _hydratedVersion == transaction.version) {
      return;
    }

    final CategoryController categories = context.read<CategoryController>();
    CategoryModel? selected;
    for (final CategoryModel category in categories.categories) {
      if (category.id == transaction.category.id) {
        selected = category;
        break;
      }
    }
    selected ??= CategoryModel(
      id: transaction.category.id,
      name: transaction.category.name,
      type: transaction.type.categoryType,
      iconKey: transaction.category.iconKey,
      isSystem: false,
    );

    final String amount = TransactionFormatters.amountForEditing(
      transaction.amount,
    );
    final String description = transaction.description ?? '';
    final DateTime date = DateTime(
      transaction.occurredOn.year,
      transaction.occurredOn.month,
      transaction.occurredOn.day,
    );

    setState(() {
      _hydratedVersion = transaction.version;
      _amountController.text = amount;
      _descriptionController.text = description;
      _selectedCategory = selected;
      _occurredOn = date;
      _initialAmount = amount;
      _initialDescription = description;
      _initialCategoryId = selected!.id;
      _initialDate = date;
      _showCategoryError = false;
    });
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isDirty {
    if (_hydratedVersion == null) {
      return false;
    }
    return _amountController.text.trim() != _initialAmount.trim() ||
        _descriptionController.text != _initialDescription ||
        _selectedCategory?.id != _initialCategoryId ||
        !_sameNullableDate(_occurredOn, _initialDate);
  }

  bool _canSubmit(BuildContext context) {
    final EditTransactionController controller = context
        .read<EditTransactionController>();
    return !controller.isSaving &&
        !_isCompletingSuccess &&
        !controller.hasConflict &&
        _isDirty &&
        controller.transaction != null &&
        _selectedCategory != null &&
        _occurredOn != null &&
        TransactionInput.validateAmount(
              _amountController.text,
              context.l10n,
            ) ==
            null &&
        TransactionInput.validateDescription(
              _descriptionController.text,
              context.l10n,
            ) ==
            null &&
        !_occurredOn!.isAfter(_today());
  }

  Future<CategoryModel?> _createCategory(TransactionType type) async {
    final CreateCategoryInput? input = await showCreateCategorySheet(
      context: context,
      fixedType: type.categoryType,
    );
    if (!mounted || input == null) {
      return null;
    }

    final CategoryController controller = context.read<CategoryController>();
    final CategoryModel? created = await controller.createCategory(
      name: input.name,
      type: type.categoryType,
    );
    if (!mounted) {
      return null;
    }
    if (created == null) {
      _showMessage(
        LocalizedErrorMessage.fromException(context, controller.error),
      );
      return null;
    }
    _showMessage(context.l10n.categoryCreated);
    return created;
  }

  Future<void> _selectCategory(TransactionType type) async {
    final CategoryController controller = context.read<CategoryController>();
    await controller.load();
    if (!mounted) {
      return;
    }

    final CategoryModel? selected = await showCategoryPickerSheet(
      context: context,
      type: type.categoryType,
      categories: controller.categories,
      selectedCategory: _selectedCategory,
      onCreateCategory: () => _createCategory(type),
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _selectedCategory = selected;
      _showCategoryError = false;
    });
  }

  Future<void> _pickDate() async {
    final DateTime current = _occurredOn ?? _today();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: _today(),
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _occurredOn = DateTime(selected.year, selected.month, selected.day);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final bool formValid = _formKey.currentState?.validate() == true;
    final bool categoryValid = _selectedCategory != null;
    setState(() {
      _showCategoryError = !categoryValid;
    });

    if (!formValid || !categoryValid || !_canSubmit(context)) {
      return;
    }

    final EditTransactionController controller = context
        .read<EditTransactionController>();
    final TransactionModel? updated = await controller.save(
      amount: _amountController.text,
      categoryId: _selectedCategory!.id,
      occurredOn: _occurredOn!,
      description: _descriptionController.text,
    );
    if (!mounted) {
      return;
    }

    if (updated == null) {
      if (!controller.hasConflict) {
        _showMessage(
          LocalizedErrorMessage.fromException(context, controller.error),
        );
      }
      return;
    }

    setState(() {
      _isCompletingSuccess = true;
    });

    await Future.wait<void>(<Future<void>>[
      context.read<WalletController>().load(force: true),
      context.read<TransactionHistoryController>().refreshAfterMutation(),
    ]);

    if (!mounted) {
      return;
    }
    _showMessage(context.l10n.transactionUpdatedSuccessfully);
    setState(() {
      _allowPop = true;
    });
    Navigator.of(context).pop(true);
  }

  Future<void> _reloadLatest() async {
    await context.read<EditTransactionController>().reloadLatest();
  }

  Future<void> _handleBlockedPop() async {
    final EditTransactionController controller = context
        .read<EditTransactionController>();
    if (controller.isSaving || _isCompletingSuccess || !_isDirty) {
      return;
    }
    final bool discard = await _confirmDiscard();
    if (!mounted || !discard) {
      return;
    }
    setState(() {
      _allowPop = true;
    });
    Navigator.of(context).pop();
  }

  Future<bool> _confirmDiscard() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.discardChangesTitle),
          content: Text(context.l10n.discardChangesBody),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    child: Text(context.l10n.keepEditing),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: Text(context.l10n.discard),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return result == true;
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
    final EditTransactionController controller = context
        .watch<EditTransactionController>();
    final TransactionModel? transaction = controller.transaction;
    final ProfileController profileController = context.watch<ProfileController>();
    final DateFormatPreference dateFormat =
        profileController.preferences?.dateFormat ??
        UserPreferencesModel.defaults.dateFormat;
    final bool isBusy = controller.isSaving || _isCompletingSuccess;

    return PopScope<bool>(
      canPop: _allowPop || (!_isDirty && !isBusy),
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (!didPop) {
          unawaited(_handleBlockedPop());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.editTransaction)),
        body: SafeArea(
          bottom: false,
          child: _buildBody(
            context,
            controller,
            transaction,
            dateFormat,
            isBusy,
          ),
        ),
        bottomNavigationBar:
            transaction == null || _hydratedVersion == null
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    AppSpacing.md,
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                  ),
                  child: AppButton(
                    label: context.l10n.saveChanges,
                    isLoading: isBusy,
                    onPressed: _canSubmit(context) ? _save : null,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    EditTransactionController controller,
    TransactionModel? transaction,
    DateFormatPreference dateFormat,
    bool isBusy,
  ) {
    if (_hydratedVersion == null &&
        (transaction != null || controller.isLoading || controller.error == null)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transaction == null) {
      final bool unavailable = controller.error?.statusCode == 404;
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
                unavailable
                    ? context.l10n.transactionUnavailable
                    : context.l10n.unableToLoadTransaction,
                textAlign: TextAlign.center,
                style: AppTextStyles.screenTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                unavailable
                    ? context.l10n.transactionUnavailableBody
                    : LocalizedErrorMessage.fromException(
                        context,
                        controller.error,
                      ),
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              if (!unavailable) ...[
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () => controller.load(force: true),
                  child: Text(context.l10n.tryAgain),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final bool income = transaction.type == TransactionType.income;
    final Color accent = income ? AppColors.accent : AppColors.error;
    final WalletModel? wallet = context.watch<WalletController>().wallet;
    final String currencyCode = wallet?.currencyCode ?? transaction.currencyCode;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.22)),
              ),
              child: Row(
                children: [
                  Icon(
                    income
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: accent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      income ? context.l10n.income : context.l10n.expense,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      context.l10n.transactionTypeLocked,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.helperText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _EditAmountCard(
              controller: _amountController,
              currencySymbol: TransactionFormatters.currencySymbol(
                context,
                currencyCode,
              ),
              currencyCode: currencyCode,
              accent: accent,
              enabled: !isBusy,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              income
                  ? context.l10n.incomeCategory
                  : context.l10n.expenseCategory,
              style: AppTextStyles.fieldLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            _EditSelectionField(
              value: _selectedCategory?.name,
              hint: context.l10n.selectCategory,
              onTap: isBusy
                  ? null
                  : () => _selectCategory(transaction.type),
              hasError: _showCategoryError,
            ),
            if (_showCategoryError) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.transactionCategoryRequired,
                style: AppTextStyles.errorText,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(context.l10n.date, style: AppTextStyles.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            _EditDateField(
              value: TransactionFormatters.formatDate(
                _occurredOn!,
                dateFormat,
              ),
              onTap: isBusy ? null : _pickDate,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.descriptionOptional,
              style: AppTextStyles.fieldLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _descriptionController,
              maxLength: 255,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              enabled: !isBusy,
              validator: (String? value) => TransactionInput.validateDescription(
                value,
                context.l10n,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.addNote,
                counterText: '',
              ),
            ),
            if (controller.hasConflict) ...[
              const SizedBox(height: AppSpacing.lg),
              AppStatusMessage(
                message: context.l10n.transactionEditConflict,
                isError: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: controller.isLoading ? null : _reloadLatest,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.l10n.reloadLatest),
              ),
            ] else if (controller.error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppStatusMessage(
                message: LocalizedErrorMessage.fromException(
                  context,
                  controller.error,
                ),
                isError: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static DateTime _today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _sameNullableDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return a == b;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _EditAmountCard extends StatelessWidget {
  const _EditAmountCard({
    required this.controller,
    required this.currencySymbol,
    required this.currencyCode,
    required this.accent,
    required this.enabled,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final String currencyCode;
  final Color accent;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(context.l10n.amount, style: AppTextStyles.helperText),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  currencySymbol,
                  style: AppTextStyles.screenTitle.copyWith(
                    color: accent,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: const <TextInputFormatter>[
                    FinancialAmountInputFormatter(),
                  ],
                  validator: (String? value) =>
                      TransactionInput.validateAmount(value, context.l10n),
                  style: AppTextStyles.brandTitle.copyWith(
                    color: accent,
                    fontSize: 30,
                  ),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(currencyCode, style: AppTextStyles.helperText),
        ],
      ),
    );
  }
}

class _EditSelectionField extends StatelessWidget {
  const _EditSelectionField({
    required this.value,
    required this.hint,
    required this.onTap,
    required this.hasError,
  });

  final String? value;
  final String hint;
  final VoidCallback? onTap;
  final bool hasError;

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
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: value == null
                      ? AppTextStyles.inputHint
                      : AppTextStyles.inputText,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditDateField extends StatelessWidget {
  const _EditDateField({required this.value, required this.onTap});

  final String value;
  final VoidCallback? onTap;

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
              Expanded(child: Text(value, style: AppTextStyles.inputText)),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
