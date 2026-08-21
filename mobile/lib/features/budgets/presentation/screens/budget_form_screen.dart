import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_confirmation_dialog.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/models/category_type.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../categories/presentation/widgets/category_picker_sheet.dart';
import '../../../categories/presentation/widgets/create_category_sheet.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../transactions/utils/transaction_decimal.dart';
import '../../../transactions/utils/transaction_input.dart';
import '../../data/models/budget_model.dart';
import '../controllers/budget_controller.dart';
import '../controllers/budget_form_controller.dart';

class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({this.budgetId, super.key});
  final int? budgetId;
  bool get isEdit => budgetId != null;

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  CategoryModel? _category;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _initialized = false;
  bool _allowPop = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_markDirty);
    _noteController.addListener(_markDirty);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<CategoryController>().load();
      if (widget.budgetId != null) {
        await _loadExistingAndInitialize();
      } else {
        setState(() => _initialized = true);
      }
    });
  }

  Future<void> _loadExistingAndInitialize() async {
    await context.read<BudgetFormController>().loadExisting(widget.budgetId!);
    if (mounted) {
      _initializeExisting();
    }
  }

  void _initializeExisting() {
    final BudgetModel? budget = context.read<BudgetFormController>().existing;
    if (budget == null) return;
    final CategoryController categories = context.read<CategoryController>();
    CategoryModel? category;
    for (final CategoryModel item in categories.categoriesOfType(CategoryType.expense)) {
      if (item.id == budget.category.id) { category = item; break; }
    }
    _amountController.text = budget.limitAmount;
    _noteController.text = budget.note ?? '';
    _category = category;
    _month = budget.budgetMonth;
    setState(() { _initialized = true; _dirty = false; });
  }

  void _markDirty() { if (_initialized && !_dirty) setState(() => _dirty = true); }

  @override
  void dispose() { _amountController.dispose(); _noteController.dispose(); super.dispose(); }

  Future<CategoryModel?> _createCategory() async {
    final CreateCategoryInput? input = await showCreateCategorySheet(context: context, fixedType: CategoryType.expense);
    if (!mounted || input == null) return null;
    final CategoryController controller = context.read<CategoryController>();
    final CategoryModel? created = await controller.createCategory(name: input.name, type: CategoryType.expense);
    if (!mounted) return null;
    if (created == null) _message(LocalizedErrorMessage.fromException(context, controller.error));
    return created;
  }

  Future<void> _pickCategory() async {
    if (widget.isEdit) return;
    final CategoryController controller = context.read<CategoryController>();
    await controller.load(); if (!mounted) return;
    final CategoryModel? selected = await showCategoryPickerSheet(context: context, type: CategoryType.expense, categories: controller.categories, selectedCategory: _category, onCreateCategory: _createCategory);
    if (selected != null && mounted) setState(() { _category = selected; _dirty = true; });
  }

  Future<void> _pickMonth() async {
    if (widget.isEdit) return;
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(context: context, initialDate: _month.isBefore(DateTime(now.year, now.month, 1)) ? DateTime(now.year, now.month, 1) : _month, firstDate: DateTime(now.year, now.month, 1), lastDate: DateTime(now.year + 5, 12, 31), helpText: context.l10n.selectBudgetMonth);
    if (selected != null && mounted) setState(() { _month = DateTime(selected.year, selected.month, 1); _dirty = true; });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true || (!widget.isEdit && _category == null)) { setState(() {}); return; }
    final BudgetFormController controller = context.read<BudgetFormController>();
    final BudgetModel? result = widget.isEdit
        ? await controller.update(amount: _amountController.text.trim(), note: _normalize(_noteController.text))
        : await controller.create(categoryId: _category!.id, amount: _amountController.text.trim(), month: _month, note: _normalize(_noteController.text));
    if (!mounted) return;
    if (result == null) { _message(LocalizedErrorMessage.fromException(context, controller.error)); return; }
    await Future.wait<void>(<Future<void>>[
      context.read<BudgetController>().refresh(),
      context.read<DashboardController>().load(force: true),

    ]);
    if (!mounted) return;
    _allowPop = true;
    _message(widget.isEdit ? context.l10n.budgetUpdated : context.l10n.budgetCreated);
    Navigator.of(context).pop(true);
  }

  Future<void> _blockedBack() async {
    if (!_dirty || context.read<BudgetFormController>().isSubmitting) return;
    final bool discard = await _confirmDiscard();
    if (discard && mounted) { setState(() => _allowPop = true); Navigator.of(context).pop(); }
  }

  Future<bool> _confirmDiscard() => showAppConfirmationDialog(
    context: context,
    title: context.l10n.discardChangesTitle,
    message: context.l10n.discardChangesBody,
    cancelLabel: context.l10n.keepEditing,
    confirmLabel: context.l10n.discard,
    destructive: true,
  );

  void _message(String text) { ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating)); }
  static String? _normalize(String value) { final String v=value.trim().replaceAll(RegExp(r'\s+'),' '); return v.isEmpty?null:v; }

  @override
  Widget build(BuildContext context) {
    final BudgetFormController controller = context.watch<BudgetFormController>();
    if (widget.isEdit && !_initialized) {
      return Scaffold(appBar: AppBar(title: Text(context.l10n.editBudget)), body: Center(child: controller.isLoading ? const CircularProgressIndicator() : Column(mainAxisSize: MainAxisSize.min, children:[Text(LocalizedErrorMessage.fromException(context, controller.error)), TextButton(onPressed: _loadExistingAndInitialize, child: Text(context.l10n.retry))])));
    }
    final bool busy = controller.isSubmitting;
    final String monthLabel = DateFormat.yMMMM(Localizations.localeOf(context).toLanguageTag()).format(_month);
    final bool amountValid = TransactionDecimal.isValidPositive(_amountController.text);
    return PopScope<bool>(canPop: _allowPop || (!_dirty && !busy), onPopInvokedWithResult: (didPop, _) { if (!didPop) unawaited(_blockedBack()); }, child: Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? context.l10n.editBudget : context.l10n.createBudget)),
      body: SafeArea(bottom:false, child: Form(key:_formKey, autovalidateMode:AutovalidateMode.onUserInteraction, child: ListView(keyboardDismissBehavior:ScrollViewKeyboardDismissBehavior.onDrag,padding:const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal,AppSpacing.lg,AppSpacing.screenHorizontal,AppSpacing.xxxl),children:[
        Text(context.l10n.expenseCategory,style:AppTextStyles.fieldLabel),const SizedBox(height:8),_Selection(value:_category?.name ?? (widget.isEdit ? controller.existing?.category.name : null),hint:context.l10n.selectCategory,onTap:busy||widget.isEdit?null:_pickCategory),
        const SizedBox(height:AppSpacing.lg),Text(context.l10n.monthlyLimit,style:AppTextStyles.fieldLabel),const SizedBox(height:8),TextFormField(controller:_amountController,enabled:!busy,keyboardType:const TextInputType.numberWithOptions(decimal:true),inputFormatters:const <TextInputFormatter>[FinancialAmountInputFormatter()],validator:(value)=>TransactionInput.validateAmount(value,context.l10n),decoration:InputDecoration(hintText:'0.00',prefixIcon:const Icon(Icons.payments_outlined))),
        const SizedBox(height:AppSpacing.lg),Text(context.l10n.budgetMonth,style:AppTextStyles.fieldLabel),const SizedBox(height:8),_Selection(value:monthLabel,hint:monthLabel,onTap:busy||widget.isEdit?null:_pickMonth,icon:Icons.calendar_month_outlined),
        const SizedBox(height:AppSpacing.lg),Text(context.l10n.noteOptional,style:AppTextStyles.fieldLabel),const SizedBox(height:8),TextFormField(controller:_noteController,enabled:!busy,maxLength:255,maxLines:3,decoration:InputDecoration(hintText:context.l10n.addNote,counterText:'')),
        if(controller.error!=null)...[const SizedBox(height:AppSpacing.md),Text(LocalizedErrorMessage.fromException(context,controller.error),style:AppTextStyles.errorText)],
      ]))),
      bottomNavigationBar:SafeArea(top:false,child:Container(color:AppColors.surface,padding:const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal,AppSpacing.md,AppSpacing.screenHorizontal,AppSpacing.lg),child:AppButton(label:widget.isEdit?context.l10n.saveChanges:context.l10n.createBudget,isLoading:busy,onPressed:amountValid&&(_category!=null||widget.isEdit)?_submit:null)))
    ));
  }
}

class _Selection extends StatelessWidget { const _Selection({required this.value,required this.hint,required this.onTap,this.icon=Icons.keyboard_arrow_down_rounded});final String? value;final String hint;final VoidCallback? onTap;final IconData icon;@override Widget build(BuildContext context)=>Material(color:AppColors.surface,borderRadius:BorderRadius.circular(14),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(14),child:Container(constraints:const BoxConstraints(minHeight:56),padding:const EdgeInsets.symmetric(horizontal:16),decoration:BoxDecoration(border:Border.all(color:AppColors.border),borderRadius:BorderRadius.circular(14)),child:Row(children:[Expanded(child:Text(value??hint,maxLines:1,overflow:TextOverflow.ellipsis,style:AppTextStyles.body.copyWith(color:value==null?AppColors.textSecondary:AppColors.textPrimary))),Icon(icon,color:AppColors.textSecondary)])))); }
