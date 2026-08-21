package com.smartwallet.backend.plannedexpense.dto.request;

import java.time.LocalDate;
import java.util.UUID;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;

public record MarkPlannedExpensePaidRequest(
        @Min(value = 0, message = "version must not be negative")
        long version,

        @NotNull(message = "payment date is required")
        @PastOrPresent(message = "payment date cannot be in the future")
        LocalDate paidOn,

        @NotNull(message = "client request ID is required")
        UUID clientRequestId
) {
}
