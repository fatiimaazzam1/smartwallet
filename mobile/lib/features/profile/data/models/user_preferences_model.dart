import '../../../../core/localization/app_language.dart';

enum DateFormatPreference {
  dayMonthYear('DD_MM_YYYY'),
  monthDayYear('MM_DD_YYYY'),
  yearMonthDay('YYYY_MM_DD');

  const DateFormatPreference(this.apiValue);
  final String apiValue;

  static DateFormatPreference fromApiValue(String value) {
    return DateFormatPreference.values.firstWhere(
      (DateFormatPreference item) => item.apiValue == value,
      orElse: () => DateFormatPreference.dayMonthYear,
    );
  }
}

enum DashboardPeriodPreference {
  currentMonth('CURRENT_MONTH'),
  lastThirtyDays('LAST_30_DAYS');

  const DashboardPeriodPreference(this.apiValue);
  final String apiValue;

  static DashboardPeriodPreference fromApiValue(String value) {
    return DashboardPeriodPreference.values.firstWhere(
      (DashboardPeriodPreference item) => item.apiValue == value,
      orElse: () => DashboardPeriodPreference.currentMonth,
    );
  }
}

final class UserPreferencesModel {
  const UserPreferencesModel({
    required this.hideBalanceByDefault,
    required this.compactTransactionList,
    required this.showBudgetWarnings,
    required this.budgetWarningThreshold,
    required this.dateFormat,
    required this.dashboardPeriod,
    required this.language,
  });

  final bool hideBalanceByDefault;
  final bool compactTransactionList;
  final bool showBudgetWarnings;
  final int budgetWarningThreshold;
  final DateFormatPreference dateFormat;
  final DashboardPeriodPreference dashboardPeriod;
  final AppLanguagePreference language;

  static const UserPreferencesModel defaults = UserPreferencesModel(
    hideBalanceByDefault: false,
    compactTransactionList: false,
    showBudgetWarnings: true,
    budgetWarningThreshold: 70,
    dateFormat: DateFormatPreference.dayMonthYear,
    dashboardPeriod: DashboardPeriodPreference.currentMonth,
    language: AppLanguagePreference.system,
  );

  UserPreferencesModel copyWith({
    bool? hideBalanceByDefault,
    bool? compactTransactionList,
    bool? showBudgetWarnings,
    int? budgetWarningThreshold,
    DateFormatPreference? dateFormat,
    DashboardPeriodPreference? dashboardPeriod,
    AppLanguagePreference? language,
  }) {
    return UserPreferencesModel(
      hideBalanceByDefault:
          hideBalanceByDefault ?? this.hideBalanceByDefault,
      compactTransactionList:
          compactTransactionList ?? this.compactTransactionList,
      showBudgetWarnings: showBudgetWarnings ?? this.showBudgetWarnings,
      budgetWarningThreshold:
          budgetWarningThreshold ?? this.budgetWarningThreshold,
      dateFormat: dateFormat ?? this.dateFormat,
      dashboardPeriod: dashboardPeriod ?? this.dashboardPeriod,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hideBalanceByDefault': hideBalanceByDefault,
      'compactTransactionList': compactTransactionList,
      'showBudgetWarnings': showBudgetWarnings,
      'budgetWarningThreshold': budgetWarningThreshold,
      'dateFormat': dateFormat.apiValue,
      'dashboardPeriod': dashboardPeriod.apiValue,
      'language': language.apiValue,
    };
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    final dynamic hideBalanceValue = json['hideBalanceByDefault'];
    final dynamic compactListValue = json['compactTransactionList'];
    final dynamic warningsValue = json['showBudgetWarnings'];
    final dynamic thresholdValue = json['budgetWarningThreshold'];
    final dynamic dateFormatValue = json['dateFormat'];
    final dynamic dashboardPeriodValue = json['dashboardPeriod'];
    final dynamic languageValue = json['language'];

    if (hideBalanceValue is! bool ||
        compactListValue is! bool ||
        warningsValue is! bool ||
        thresholdValue is! num ||
        dateFormatValue is! String ||
        dashboardPeriodValue is! String ||
        languageValue is! String) {
      throw const FormatException('Invalid user preferences response.');
    }

    final int threshold = thresholdValue.toInt();
    if (!const <int>{70, 80, 90}.contains(threshold)) {
      throw const FormatException('Invalid budget warning threshold.');
    }

    if (!DateFormatPreference.values.any(
          (DateFormatPreference item) => item.apiValue == dateFormatValue,
        ) ||
        !DashboardPeriodPreference.values.any(
          (DashboardPeriodPreference item) =>
              item.apiValue == dashboardPeriodValue,
        ) ||
        !AppLanguagePreference.values.any(
          (AppLanguagePreference item) => item.apiValue == languageValue,
        )) {
      throw const FormatException('Invalid controlled preference value.');
    }

    return UserPreferencesModel(
      hideBalanceByDefault: hideBalanceValue,
      compactTransactionList: compactListValue,
      showBudgetWarnings: warningsValue,
      budgetWarningThreshold: threshold,
      dateFormat: DateFormatPreference.fromApiValue(dateFormatValue),
      dashboardPeriod: DashboardPeriodPreference.fromApiValue(
        dashboardPeriodValue,
      ),
      language: AppLanguagePreference.fromApiValue(languageValue),
    );
  }
}
