package com.smartwallet.backend.preference.dto.request;

import com.smartwallet.backend.preference.domain.AppLanguage;
import com.smartwallet.backend.preference.domain.DashboardPeriod;
import com.smartwallet.backend.preference.domain.DateFormatPreference;

import jakarta.validation.constraints.NotNull;

public record UpdateUserPreferenceRequest(

        @NotNull(message = "Hide balance preference is required")
        Boolean hideBalanceByDefault,

        @NotNull(message = "Compact transaction list preference is required")
        Boolean compactTransactionList,

        @NotNull(message = "Budget warning preference is required")
        Boolean showBudgetWarnings,

        @NotNull(message = "Budget warning threshold is required")
        Integer budgetWarningThreshold,

        @NotNull(message = "Date format is required")
        DateFormatPreference dateFormat,

        @NotNull(message = "Dashboard period is required")
        DashboardPeriod dashboardPeriod,

        @NotNull(message = "Language is required")
        AppLanguage language

) {
}
