package com.smartwallet.backend.transaction.repository;

import java.math.BigDecimal;

public interface CategorySpendingView {
    Long getCategoryId();
    String getCategoryName();
    String getIconKey();
    BigDecimal getTotalAmount();
}
