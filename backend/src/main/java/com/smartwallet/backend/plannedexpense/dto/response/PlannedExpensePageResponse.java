package com.smartwallet.backend.plannedexpense.dto.response;

import java.math.BigDecimal;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

public record PlannedExpensePageResponse(
        List<PlannedExpenseResponse> content,
        int page,
        int size,
        long totalElements,
        int totalPages,
        boolean last,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal totalAmount
) {
}
