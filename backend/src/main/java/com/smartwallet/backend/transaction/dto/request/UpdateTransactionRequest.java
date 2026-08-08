package com.smartwallet.backend.transaction.dto.request;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

public record UpdateTransactionRequest(
        @NotNull(message = "transaction version is required")
        @PositiveOrZero(message = "transaction version is invalid")
        Long version,

        @NotNull(message = "amount is required")
        @DecimalMin(value = "0.01", message = "amount must be at least 0.01")
        @DecimalMax(
                value = "99999999999999999.99",
                message = "amount is too large"
        )
        @Digits(
                integer = 17,
                fraction = 2,
                message = "amount must have at most 2 decimal places"
        )
        BigDecimal amount,

        @NotNull(message = "category is required")
        Long categoryId,

        @NotNull(message = "transaction date is required")
        @PastOrPresent(message = "transaction date cannot be in the future")
        LocalDate occurredOn,

        @Size(max = 255, message = "description must not exceed 255 characters")
        @Pattern(
                regexp = "^[^\\p{Cc}\\p{Cf}]*$",
                message = "description contains unsupported characters"
        )
        String description
) {
}
