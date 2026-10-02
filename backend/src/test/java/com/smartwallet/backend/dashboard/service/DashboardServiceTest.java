package com.smartwallet.backend.dashboard.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.verify;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.smartwallet.backend.budget.domain.BudgetStatus;
import com.smartwallet.backend.budget.repository.BudgetRepository;
import com.smartwallet.backend.budget.service.BudgetService;
import com.smartwallet.backend.dashboard.dto.response.DashboardResponse;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;
import com.smartwallet.backend.plannedexpense.repository.PlannedExpenseRepository;
import com.smartwallet.backend.plannedexpense.service.PlannedExpenseService;
import com.smartwallet.backend.preference.repository.UserPreferenceRepository;
import com.smartwallet.backend.transaction.repository.CategorySpendingView;
import com.smartwallet.backend.transaction.repository.TransactionRepository;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.repository.WalletRepository;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private WalletRepository walletRepository;
    @Mock
    private PlannedExpenseRepository plannedExpenseRepository;
    @Mock
    private PlannedExpenseService plannedExpenseService;
    @Mock
    private BudgetRepository budgetRepository;
    @Mock
    private BudgetService budgetService;
    @Mock
    private UserPreferenceRepository userPreferenceRepository;
    @Mock
    private TransactionRepository transactionRepository;

    private DashboardService service;

    @BeforeEach
    void setUp() {
        service = new DashboardService(
                walletRepository,
                plannedExpenseRepository,
                plannedExpenseService,
                budgetRepository,
                budgetService,
                userPreferenceRepository,
                transactionRepository
        );
    }

    @Test
    void returnsRealWeeklyInsightsForAuthenticatedWallet() {
        Wallet wallet = mock(Wallet.class);
        when(wallet.getId()).thenReturn(10L);
        when(wallet.getCurrencyCode()).thenReturn("USD");
        when(walletRepository.findByUserId(1L)).thenReturn(Optional.of(wallet));
        when(walletRepository.calculateBalance(10L)).thenReturn(new BigDecimal("900.00"));

        when(plannedExpenseRepository.sumOutstandingThrough(eq(10L), any(LocalDate.class)))
                .thenReturn(new BigDecimal("100.00"));
        when(plannedExpenseRepository.countByWalletIdAndStatus(10L, PlannedExpenseStatus.UPCOMING))
                .thenReturn(2L);
        when(plannedExpenseRepository.sumByWalletIdAndStatus(10L, PlannedExpenseStatus.UPCOMING))
                .thenReturn(new BigDecimal("130.00"));
        when(plannedExpenseRepository.findTop3ByWalletIdAndStatusOrderByDueOnAscIdAsc(
                10L, PlannedExpenseStatus.UPCOMING
        )).thenReturn(List.of());
        when(plannedExpenseRepository.countByWalletIdAndStatusAndDueOnBetween(
                eq(10L), eq(PlannedExpenseStatus.UPCOMING), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(2L);
        when(plannedExpenseRepository.sumUpcomingBetween(
                eq(10L), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(new BigDecimal("130.00"));

        when(budgetRepository.findMonthBudgets(eq(10L), any(LocalDate.class), eq(BudgetStatus.ACTIVE)))
                .thenReturn(List.of());
        when(userPreferenceRepository.findByUserId(1L)).thenReturn(Optional.empty());

        when(transactionRepository.sumActiveExpensesBetween(eq(10L), any(LocalDate.class), any(LocalDate.class)))
                .thenReturn(new BigDecimal("125.50"), new BigDecimal("100.00"));
        CategorySpendingView top = mock(CategorySpendingView.class);
        when(top.getCategoryId()).thenReturn(5L);
        when(top.getCategoryName()).thenReturn("Food");
        when(top.getIconKey()).thenReturn("restaurant");
        when(top.getTotalAmount()).thenReturn(new BigDecimal("80.00"));
        when(transactionRepository.findTopActiveExpenseCategoryBetween(
                eq(10L), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(Optional.of(top));

        DashboardResponse result = service.get(1L);

        ArgumentCaptor<LocalDate> upcomingStart = ArgumentCaptor.forClass(LocalDate.class);
        ArgumentCaptor<LocalDate> upcomingEnd = ArgumentCaptor.forClass(LocalDate.class);
        verify(plannedExpenseRepository).countByWalletIdAndStatusAndDueOnBetween(
                eq(10L),
                eq(PlannedExpenseStatus.UPCOMING),
                upcomingStart.capture(),
                upcomingEnd.capture()
        );
        assertThat(upcomingEnd.getValue()).isEqualTo(upcomingStart.getValue().plusDays(14));

        assertThat(result.currentBalance()).isEqualByComparingTo("900.00");
        assertThat(result.safeToSpend()).isEqualByComparingTo("800.00");
        assertThat(result.weeklyInsights().currentWeekSpending()).isEqualByComparingTo("125.50");
        assertThat(result.weeklyInsights().previousComparableSpending()).isEqualByComparingTo("100.00");
        assertThat(result.weeklyInsights().comparisonAvailable()).isTrue();
        assertThat(result.weeklyInsights().comparisonDirection()).isEqualTo("INCREASED");
        assertThat(result.weeklyInsights().comparisonPercentage()).isEqualByComparingTo("25.50");
        assertThat(result.weeklyInsights().topSpendingCategory().categoryName()).isEqualTo("Food");
        assertThat(result.weeklyInsights().upcomingFourteenDayCount()).isEqualTo(2L);
        assertThat(result.weeklyInsights().upcomingFourteenDayTotal()).isEqualByComparingTo("130.00");
    }

    @Test
    void doesNotInventPercentageWhenPreviousComparableSpendingIsZero() {
        Wallet wallet = mock(Wallet.class);
        when(wallet.getId()).thenReturn(10L);
        when(wallet.getCurrencyCode()).thenReturn("USD");
        when(walletRepository.findByUserId(1L)).thenReturn(Optional.of(wallet));
        when(walletRepository.calculateBalance(10L)).thenReturn(BigDecimal.ZERO);

        when(plannedExpenseRepository.sumOutstandingThrough(eq(10L), any(LocalDate.class)))
                .thenReturn(BigDecimal.ZERO);
        when(plannedExpenseRepository.countByWalletIdAndStatus(10L, PlannedExpenseStatus.UPCOMING))
                .thenReturn(0L);
        when(plannedExpenseRepository.sumByWalletIdAndStatus(10L, PlannedExpenseStatus.UPCOMING))
                .thenReturn(BigDecimal.ZERO);
        when(plannedExpenseRepository.findTop3ByWalletIdAndStatusOrderByDueOnAscIdAsc(
                10L, PlannedExpenseStatus.UPCOMING
        )).thenReturn(List.of());
        when(plannedExpenseRepository.countByWalletIdAndStatusAndDueOnBetween(
                eq(10L), eq(PlannedExpenseStatus.UPCOMING), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(0L);
        when(plannedExpenseRepository.sumUpcomingBetween(
                eq(10L), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(BigDecimal.ZERO);

        when(budgetRepository.findMonthBudgets(eq(10L), any(LocalDate.class), eq(BudgetStatus.ACTIVE)))
                .thenReturn(List.of());
        when(userPreferenceRepository.findByUserId(1L)).thenReturn(Optional.empty());
        when(transactionRepository.sumActiveExpensesBetween(eq(10L), any(LocalDate.class), any(LocalDate.class)))
                .thenReturn(new BigDecimal("40.00"), BigDecimal.ZERO);
        when(transactionRepository.findTopActiveExpenseCategoryBetween(
                eq(10L), any(LocalDate.class), any(LocalDate.class)
        )).thenReturn(Optional.empty());

        DashboardResponse result = service.get(1L);

        assertThat(result.weeklyInsights().comparisonAvailable()).isFalse();
        assertThat(result.weeklyInsights().comparisonDirection()).isNull();
        assertThat(result.weeklyInsights().comparisonPercentage()).isNull();
    }
}
