package com.smartwallet.backend.plannedexpense.dto.request;

import jakarta.validation.constraints.Min;

public record VersionedPlannedExpenseRequest(
        @Min(value = 0, message = "version must not be negative")
        long version
) {
}
