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
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../../budgets/presentation/controllers/budget_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
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
import '../controllers/add_transaction_controller.dart';
import '../controllers/transaction_history_controller.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({required this.type, super.key});

  final TransactionType type;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late DateTime _occurredOn;
  CategoryModel? _selectedCategory;
  bool _showCategoryError = false;
  bool _allowPop = false;
  bool _isCompletingSuccess = false;

  @override
  void initState() {
    super.initState();
    _occurredOn = _today();
    _amountController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<CategoryController>().load();
      context.read<WalletController>().load();
      context.read<ProfileController>().load();
    });
  }

  @override
  void dispose() {
    _amountController
      ..removeListener(_onFormChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onFormChanged)
      ..dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isDirty {
    return _amountController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _selectedCategory != null ||
        !_sameDate(_occurredOn, _today());
  }

  bool _canSubmit(BuildContext context) {
    final AddTransactionController controller = context
        .read<AddTransactionController>();
    final WalletModel? wallet = context.read<WalletController>().wallet;

    return !controller.isSubmitting &&
        !_isCompletingSuccess &&
        wallet != null &&
        _selectedCategory != null &&
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
        !_occurredOn.isAfter(_today());
  }

  Future<CategoryModel?> _createCategory() async {
    final CreateCategoryInput? input = await showCreateCategorySheet(
      context: context,
      fixedType: widget.type.categoryType,
    );
    if (!mounted || input == null) {
      return null;
    }

    final CategoryController controller = context.read<CategoryController>();
    final CategoryModel? created = await controller.createCategory(
      name: input.name,
      type: widget.type.categoryType,
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

  Future<void> _selectCategory() async {
    final CategoryController controller = context.read<CategoryController>();
    await controller.load();
    if (!mounted) {
      return;
    }

    final CategoryModel? selected = await showCategoryPickerSheet(
      context: context,
      type: widget.type.categoryType,
      categories: controller.categories,
      selectedCategory: _selectedCategory,
      onCreateCategory: _createCategory,
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
    final DateTime today = _today();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _occurredOn,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _occurredOn = DateTime(selected.year, selected.month, selected.day);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final bool formValid = _formKey.currentState?.validate() == true;
    final bool categoryValid = _selectedCategory != null;

    setState(() {
      _showCategoryError = !categoryValid;
    });

    if (!formValid || !categoryValid || !_canSubmit(context)) {
      return;
    }

    final AddTransactionController controller = context
        .read<AddTransactionController>();
    final TransactionModel? created = await controller.create(
      type: widget.type,
      amount: _amountController.text,
      categoryId: _selectedCategory!.id,
      occurredOn: _occurredOn,
      description: _descriptionController.text,
    );

    if (!mounted) {
      return;
    }

    if (created == null) {
      _showMessage(
        LocalizedErrorMessage.fromException(context, controller.error),
      );
      return;
    }

    setState(() {
      _isCompletingSuccess = true;
    });

    await Future.wait<void>(<Future<void>>[
      context.read<WalletController>().load(force: true),
      context.read<TransactionHistoryController>().refreshAfterMutation(),
      context.read<BudgetController>().refresh(),
      context.read<DashboardController>().load(force: true),
    ]);

    if (!mounted) {
      return;
    }

    _showMessage(
      widget.type == TransactionType.income
          ? context.l10n.incomeAddedSuccessfully
          : context.l10n.expenseAddedSuccessfully,
    );
    setState(() {
      _allowPop = true;
    });
    Navigator.of(context).pop(true);
  }

  Future<void> _handleBlockedPop() async {
    final AddTransactionController controller = context
        .read<AddTransactionController>();
    if (controller.isSubmitting || _isCompletingSuccess || !_isDirty) {
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

  Future<bool> _confirmDiscard() => showAppConfirmationDialog(
    context: context,
    title: context.l10n.discardChangesTitle,
    message: context.l10n.discardChangesBody,
    cancelLabel: context.l10n.keepEditing,
    confirmLabel: context.l10n.discard,
    destructive: true,
  );

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
    final AddTransactionController controller = context
        .watch<AddTransactionController>();
    final WalletController walletController = context.watch<WalletController>();
    final WalletModel? wallet = walletController.wallet;
    final ProfileController profileController = context.watch<ProfileController>();
    final DateFormatPreference dateFormat =
        profileController.preferences?.dateFormat ??
        UserPreferencesModel.defaults.dateFormat;
    final bool isIncome = widget.type == TransactionType.income;
    final Color accent = isIncome ? AppColors.accent : AppColors.error;
    final String title = isIncome
        ? context.l10n.addIncome
        : context.l10n.addExpense;
    final String saveLabel = isIncome
        ? context.l10n.saveIncome
        : context.l10n.saveExpense;
    final bool canSubmit = _canSubmit(context);
    final bool isBusy = controller.isSubmitting || _isCompletingSuccess;

    return PopScope<bool>(
      canPop: _allowPop || (!_isDirty && !isBusy),
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (!didPop) {
          unawaited(_handleBlockedPop());
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          bottom: false,
          child: Form(
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
                  _AmountCard(
                    controller: _amountController,
                    currencySymbol: wallet == null
                        ? '—'
                        : TransactionFormatters.currencySymbol(
                            context,
                            wallet.currencyCode,
                          ),
                    currencyCode: wallet?.currencyCode,
                    accent: accent,
                    enabled: !isBusy,
                  ),
                  if (wallet == null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppStatusMessage(
                      message: walletController.isLoading
                          ? context.l10n.loadingWallet
                          : LocalizedErrorMessage.fromException(
                              context,
                              walletController.error,
                            ),
                      isError: !walletController.isLoading,
                    ),
                    if (!walletController.isLoading)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton(
                          onPressed: () => walletController.load(force: true),
                          child: Text(context.l10n.retry),
                        ),
                      ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    isIncome
                        ? context.l10n.incomeCategory
                        : context.l10n.expenseCategory,
                    style: AppTextStyles.fieldLabel,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _SelectionField(
                    value: _selectedCategory?.name,
                    hint: context.l10n.selectCategory,
                    onTap: isBusy ? null : _selectCategory,
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
                  _DateField(
                    value: TransactionFormatters.formatDate(
                      _occurredOn,
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
                    validator: (String? value) =>
                        TransactionInput.validateDescription(
                          value,
                          context.l10n,
                        ),
                    decoration: InputDecoration(
                      hintText: context.l10n.addNote,
                      counterText: '',
                    ),
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
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
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
              label: saveLabel,
              isLoading: isBusy,
              onPressed: canSubmit ? _submit : null,
            ),
          ),
        ),
      ),
    );
  }

  static DateTime _today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.controller,
    required this.currencySymbol,
    required this.currencyCode,
    required this.accent,
    required this.enabled,
  });

  final TextEditingController controller;
  final String currencySymbol;
  final String? currencyCode;
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
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
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: AppTextStyles.brandTitle.copyWith(
                      color: accent.withValues(alpha: 0.45),
                      fontSize: 30,
                    ),
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
          if (currencyCode != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(currencyCode!, style: AppTextStyles.helperText),
          ],
        ],
      ),
    );
  }
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({
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

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

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
