package com.smartwallet.backend.budget.dto.response;

public record BudgetCategoryResponse(
        Long id,
        String name,
        String iconKey
) {
}
