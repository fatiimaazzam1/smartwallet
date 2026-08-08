package com.smartwallet.backend.transaction.domain;

import com.smartwallet.backend.category.domain.CategoryType;

public enum TransactionType {
    INCOME,
    EXPENSE;

    public boolean matches(CategoryType categoryType) {
        return categoryType != null && name().equals(categoryType.name());
    }
}
