package com.smartwallet.backend.plannedexpense.dto.request;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseRecurrence;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdatePlannedExpenseRequest(
        @Min(value = 0, message = "version must not be negative")
        long version,

        @NotBlank(message = "title is required")
        @Size(max = 100, message = "title must not exceed 100 characters")
        @Pattern(regexp = "^[^\\p{Cc}\\p{Cf}]*$", message = "title contains unsupported characters")
        String title,

        @NotNull(message = "amount is required")
        @DecimalMin(value = "0.01", message = "amount must be at least 0.01")
        @DecimalMax(value = "99999999999999999.99", message = "amount is too large")
        @Digits(integer = 17, fraction = 2, message = "amount must have at most 2 decimal places")
        BigDecimal amount,

        @NotNull(message = "category is required")
        Long categoryId,

        @NotNull(message = "due date is required")
        LocalDate dueOn,

        @NotNull(message = "recurrence is required")
        PlannedExpenseRecurrence recurrence,

        @Size(max = 255, message = "note must not exceed 255 characters")
        @Pattern(regexp = "^[^\\p{Cc}\\p{Cf}]*$", message = "note contains unsupported characters")
        String note
) {
}
