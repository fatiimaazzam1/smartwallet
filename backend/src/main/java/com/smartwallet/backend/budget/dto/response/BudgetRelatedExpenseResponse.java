package com.smartwallet.backend.budget.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.math.BigDecimal;
import java.time.LocalDate;

public record BudgetRelatedExpenseResponse(
        Long id,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal amount,
        LocalDate occurredOn,
        String description
) {
}
