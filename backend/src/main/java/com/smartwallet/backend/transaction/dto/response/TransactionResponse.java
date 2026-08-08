package com.smartwallet.backend.transaction.dto.response;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.smartwallet.backend.transaction.domain.TransactionType;

public record TransactionResponse(
        Long id,
        long version,
        TransactionType type,
        BigDecimal amount,
        String description,
        LocalDate occurredOn,
        String currencyCode,
        String status,
        TransactionCategoryResponse category
) {
}
