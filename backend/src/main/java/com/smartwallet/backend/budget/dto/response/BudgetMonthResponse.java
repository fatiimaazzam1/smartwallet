package com.smartwallet.backend.budget.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record BudgetMonthResponse(
        LocalDate month,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal totalPlanned,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal totalSpent,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal totalRemaining,
        String currencyCode,
        List<BudgetResponse> budgets
) {
}
