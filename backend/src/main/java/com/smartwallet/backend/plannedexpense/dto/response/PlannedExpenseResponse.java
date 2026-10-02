package com.smartwallet.backend.plannedexpense.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseRecurrence;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;

public record PlannedExpenseResponse(
        Long id,
        long version,
        String title,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal amount,
        LocalDate dueOn,
        PlannedExpenseRecurrence recurrence,
        PlannedExpenseStatus status,
        String note,
        LocalDate paidOn,
        Long transactionId,
        String currencyCode,
        PlannedExpenseCategoryResponse category
) {
}
