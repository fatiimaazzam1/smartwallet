package com.smartwallet.backend.dashboard.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.math.BigDecimal;

public record DashboardBudgetWarningResponse(
        Long budgetId,
        String categoryName,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal percentageUsed,
        String health
) {
}
