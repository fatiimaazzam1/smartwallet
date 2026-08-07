package com.smartwallet.backend.wallet.dto.response;

import java.math.BigDecimal;

public record CurrentWalletResponse(
        Long id,
        String name,
        String currencyCode,
        BigDecimal balance
) {
}
