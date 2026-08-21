package com.smartwallet.backend.dashboard.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.math.BigDecimal;
import java.util.List;

import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpenseResponse;

public record DashboardResponse(
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal currentBalance,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal safeToSpend,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal outstandingPlannedThroughMonthEnd,
        String currencyCode,
        List<PlannedExpenseResponse> upcomingExpenses,
        DashboardBudgetWarningResponse budgetWarning
) {
}
