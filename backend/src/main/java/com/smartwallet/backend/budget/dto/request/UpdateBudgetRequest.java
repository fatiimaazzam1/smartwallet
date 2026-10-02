package com.smartwallet.backend.budget.dto.request;

import java.math.BigDecimal;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdateBudgetRequest(
        @Min(value = 0, message = "version must not be negative")
        long version,

        @NotNull(message = "budget limit is required")
        @DecimalMin(value = "0.01", message = "budget limit must be at least 0.01")
        @DecimalMax(value = "99999999999999999.99", message = "budget limit is too large")
        @Digits(integer = 17, fraction = 2, message = "budget limit must have at most 2 decimal places")
        BigDecimal limitAmount,

        @Size(max = 255, message = "note must not exceed 255 characters")
        @Pattern(regexp = "^[^\\p{Cc}\\p{Cf}]*$", message = "note contains unsupported characters")
        String note
) {
}
