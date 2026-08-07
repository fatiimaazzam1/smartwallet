package com.smartwallet.backend.wallet.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.dto.response.CurrentWalletResponse;
import com.smartwallet.backend.wallet.exception.WalletNotFoundException;
import com.smartwallet.backend.wallet.repository.WalletRepository;

@ExtendWith(MockitoExtension.class)
class WalletServiceTest {

    @Mock
    private WalletRepository walletRepository;

    private WalletService walletService;

    @BeforeEach
    void setUp() {
        walletService = new WalletService(walletRepository);
    }

    @Test
    void getCurrentUserWalletReturnsWalletAndCalculatedBalance() {
        Wallet wallet = mock(Wallet.class);

        when(wallet.getId()).thenReturn(10L);
        when(wallet.getName()).thenReturn("Personal Wallet");
        when(wallet.getCurrencyCode()).thenReturn("USD");
        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(walletRepository.calculateBalance(10L))
                .thenReturn(new BigDecimal("125.5"));

        CurrentWalletResponse response =
                walletService.getCurrentUserWallet(1L);

        assertThat(response.id()).isEqualTo(10L);
        assertThat(response.name()).isEqualTo("Personal Wallet");
        assertThat(response.currencyCode()).isEqualTo("USD");
        assertThat(response.balance())
                .isEqualByComparingTo("125.50");

        verify(walletRepository).calculateBalance(10L);
    }

    @Test
    void getCurrentUserWalletReturnsZeroWhenThereAreNoTransactions() {
        Wallet wallet = mock(Wallet.class);

        when(wallet.getId()).thenReturn(20L);
        when(wallet.getName()).thenReturn("Personal Wallet");
        when(wallet.getCurrencyCode()).thenReturn("USD");
        when(walletRepository.findByUserId(2L))
                .thenReturn(Optional.of(wallet));
        when(walletRepository.calculateBalance(20L))
                .thenReturn(null);

        CurrentWalletResponse response =
                walletService.getCurrentUserWallet(2L);

        assertThat(response.balance())
                .isEqualByComparingTo("0.00");
    }

    @Test
    void getCurrentUserWalletRejectsMissingWallet() {
        when(walletRepository.findByUserId(99L))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() ->
                walletService.getCurrentUserWallet(99L)
        ).isInstanceOf(WalletNotFoundException.class);

        verify(walletRepository, never())
                .calculateBalance(org.mockito.ArgumentMatchers.anyLong());
    }
}
