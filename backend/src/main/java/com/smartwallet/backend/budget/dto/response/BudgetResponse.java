package com.smartwallet.backend.budget.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.math.BigDecimal;
import java.time.LocalDate;

public record BudgetResponse(
        Long id,
        long version,
        LocalDate budgetMonth,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal limitAmount,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal spentAmount,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal remainingAmount,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal percentageUsed,
        int daysRemaining,
        String currencyCode,
        String health,
        String note,
        BudgetCategoryResponse category
) {
}
