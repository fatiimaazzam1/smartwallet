package com.smartwallet.backend.preference.dto.response;

import com.smartwallet.backend.preference.domain.AppLanguage;
import com.smartwallet.backend.preference.domain.DashboardPeriod;
import com.smartwallet.backend.preference.domain.DateFormatPreference;

public record UserPreferenceResponse(

        boolean hideBalanceByDefault,

        boolean compactTransactionList,

        boolean showBudgetWarnings,

        int budgetWarningThreshold,

        DateFormatPreference dateFormat,

        DashboardPeriod dashboardPeriod,

        AppLanguage language

) {
}
