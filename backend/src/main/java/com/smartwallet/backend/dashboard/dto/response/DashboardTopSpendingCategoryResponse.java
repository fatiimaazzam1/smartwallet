package com.smartwallet.backend.dashboard.dto.response;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonFormat;

public record DashboardTopSpendingCategoryResponse(
        Long categoryId,
        String categoryName,
        String iconKey,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal amount
) {
}
