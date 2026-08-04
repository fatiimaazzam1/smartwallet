import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/errors/localized_error_message.dart';
import '../../../../core/localization/app_language.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_status_message.dart';
import '../../data/models/user_preferences_model.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_load_failure.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  UserPreferencesModel? _draft;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<ProfileController>().preferences == null) {
        context.read<ProfileController>().load();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft ??= context.read<ProfileController>().preferences;
  }

  Future<void> _save() async {
    final UserPreferencesModel? draft =
        _draft ?? context.read<ProfileController>().preferences;
    if (draft == null) {
      return;
    }

    final ProfileController controller = context.read<ProfileController>();
    final bool success = await controller.updatePreferences(draft);

    if (!mounted || !success) {
      return;
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.preferencesUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _update(UserPreferencesModel value) {
    setState(() {
      _draft = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ProfileController controller = context.watch<ProfileController>();
    final UserPreferencesModel? draft = _draft ?? controller.preferences;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.isSavingPreferences ? null : widget.onBack,
          tooltip: l10n.goBack,
          icon: const BackButtonIcon(),
        ),
        title: Text(l10n.preferences),
      ),
      body: SafeArea(
        child: draft == null
            ? controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ProfileLoadFailure(
                      message: l10n.profileLoadError,
                      error: controller.error,
                      onRetry: () => controller.load(force: true),
                    )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xxl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.preferencesSubtitle,
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionCard(
                          title: l10n.displaySection,
                          children: [
                            SwitchListTile.adaptive(
                              value: draft.hideBalanceByDefault,
                              onChanged: controller.isSavingPreferences
                                  ? null
                                  : (bool value) => _update(
                                      draft.copyWith(
                                        hideBalanceByDefault: value,
                                      ),
                                    ),
                              title: Text(l10n.hideBalance),
                              subtitle: Text(l10n.hideBalanceBody),
                            ),
                            const Divider(height: 1),
                            SwitchListTile.adaptive(
                              value: draft.compactTransactionList,
                              onChanged: controller.isSavingPreferences
                                  ? null
                                  : (bool value) => _update(
                                      draft.copyWith(
                                        compactTransactionList: value,
                                      ),
                                    ),
                              title: Text(l10n.compactTransactions),
                              subtitle: Text(
                                l10n.compactTransactionsBody,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SectionCard(
                          title: l10n.budgetSection,
                          children: [
                            SwitchListTile.adaptive(
                              value: draft.showBudgetWarnings,
                              onChanged: controller.isSavingPreferences
                                  ? null
                                  : (bool value) => _update(
                                      draft.copyWith(showBudgetWarnings: value),
                                    ),
                              title: Text(l10n.showBudgetWarnings),
                              subtitle: Text(
                                l10n.showBudgetWarningsBody,
                              ),
                            ),
                            const Divider(height: 1),
                            _DropdownTile<int>(
                              label: l10n.warningThreshold,
                              value: draft.budgetWarningThreshold,
                              enabled:
                                  draft.showBudgetWarnings &&
                                  !controller.isSavingPreferences,
                              items: const <int>[70, 80, 90],
                              itemLabel: (int value) => '$value%',
                              onChanged: (int value) => _update(
                                draft.copyWith(
                                  budgetWarningThreshold: value,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SectionCard(
                          title: l10n.formatSection,
                          children: [
                            _DropdownTile<DateFormatPreference>(
                              label: l10n.dateFormat,
                              value: draft.dateFormat,
                              enabled: !controller.isSavingPreferences,
                              items: DateFormatPreference.values,
                              itemLabel: _dateFormatLabel,
                              onChanged: (DateFormatPreference value) => _update(
                                draft.copyWith(dateFormat: value),
                              ),
                            ),
                            const Divider(height: 1),
                            _DropdownTile<DashboardPeriodPreference>(
                              label: l10n.dashboardPeriod,
                              value: draft.dashboardPeriod,
                              enabled: !controller.isSavingPreferences,
                              items: DashboardPeriodPreference.values,
                              itemLabel: (DashboardPeriodPreference value) {
                                switch (value) {
                                  case DashboardPeriodPreference.currentMonth:
                                    return l10n.currentMonth;
                                  case DashboardPeriodPreference.lastThirtyDays:
                                    return l10n.lastThirtyDays;
                                }
                              },
                              onChanged:
                                  (DashboardPeriodPreference value) => _update(
                                    draft.copyWith(dashboardPeriod: value),
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SectionCard(
                          title: l10n.languageSection,
                          children: [
                            _DropdownTile<AppLanguagePreference>(
                              label: l10n.language,
                              value: draft.language,
                              enabled: !controller.isSavingPreferences,
                              items: AppLanguagePreference.values,
                              itemLabel: (AppLanguagePreference value) {
                                switch (value) {
                                  case AppLanguagePreference.system:
                                    return l10n.systemLanguage;
                                  case AppLanguagePreference.english:
                                    return l10n.englishLanguage;
                                  case AppLanguagePreference.arabic:
                                    return l10n.arabicLanguage;
                                }
                              },
                              onChanged: (AppLanguagePreference value) =>
                                  _update(draft.copyWith(language: value)),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.lg,
                              ),
                              child: Text(
                                l10n.systemLanguageHelp,
                                style: AppTextStyles.helperText,
                              ),
                            ),
                          ],
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
                        AppButton(
                          label: l10n.save,
                          isLoading: controller.isSavingPreferences,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  static String _dateFormatLabel(DateFormatPreference value) {
    switch (value) {
      case DateFormatPreference.dayMonthYear:
        return 'DD/MM/YYYY';
      case DateFormatPreference.monthDayYear:
        return 'MM/DD/YYYY';
      case DateFormatPreference.yearMonthDay:
        return 'YYYY-MM-DD';
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
          child: Text(title, style: AppTextStyles.fieldLabel),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  const _DropdownTile({
    required this.label,
    required this.value,
    required this.enabled,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final bool enabled;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              alignment: AlignmentDirectional.centerEnd,
              underline: const SizedBox.shrink(),
              borderRadius: BorderRadius.circular(12),
              onChanged: enabled
                  ? (T? selected) {
                      if (selected != null) {
                        onChanged(selected);
                      }
                    }
                  : null,
              items: items
                  .map(
                    (T item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        itemLabel(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
