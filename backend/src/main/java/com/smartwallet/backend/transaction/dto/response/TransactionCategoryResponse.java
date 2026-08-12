package com.smartwallet.backend.transaction.dto.response;

public record TransactionCategoryResponse(
        Long id,
        String name,
        String iconKey
) {
}
