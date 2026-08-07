package com.smartwallet.backend.wallet.service;

import java.math.BigDecimal;
import java.math.RoundingMode;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.dto.response.CurrentWalletResponse;
import com.smartwallet.backend.wallet.exception.WalletNotFoundException;
import com.smartwallet.backend.wallet.repository.WalletRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class WalletService {

    private static final int MONEY_SCALE = 2;

    private final WalletRepository walletRepository;

    @Transactional(readOnly = true)
    public CurrentWalletResponse getCurrentUserWallet(
            Long currentUserId
    ) {
        Wallet wallet = walletRepository.findByUserId(currentUserId)
                .orElseThrow(WalletNotFoundException::new);

        BigDecimal balance = walletRepository.calculateBalance(
                wallet.getId()
        );

        if (balance == null) {
            balance = BigDecimal.ZERO;
        }

        return new CurrentWalletResponse(
                wallet.getId(),
                wallet.getName(),
                wallet.getCurrencyCode(),
                balance.setScale(
                        MONEY_SCALE,
                        RoundingMode.HALF_UP
                )
        );
    }
}
