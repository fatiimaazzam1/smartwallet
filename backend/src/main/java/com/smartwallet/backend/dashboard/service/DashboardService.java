package com.smartwallet.backend.dashboard.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.Comparator;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.budget.domain.Budget;
import com.smartwallet.backend.budget.domain.BudgetStatus;
import com.smartwallet.backend.budget.repository.BudgetRepository;
import com.smartwallet.backend.budget.service.BudgetService;
import com.smartwallet.backend.dashboard.dto.response.DashboardBudgetWarningResponse;
import com.smartwallet.backend.dashboard.dto.response.DashboardResponse;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;
import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpenseResponse;
import com.smartwallet.backend.plannedexpense.repository.PlannedExpenseRepository;
import com.smartwallet.backend.plannedexpense.service.PlannedExpenseService;
import com.smartwallet.backend.preference.domain.UserPreference;
import com.smartwallet.backend.preference.repository.UserPreferenceRepository;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.exception.WalletNotFoundException;
import com.smartwallet.backend.wallet.repository.WalletRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final WalletRepository walletRepository;
    private final PlannedExpenseRepository plannedExpenseRepository;
    private final PlannedExpenseService plannedExpenseService;
    private final BudgetRepository budgetRepository;
    private final BudgetService budgetService;
    private final UserPreferenceRepository userPreferenceRepository;

    @Transactional(readOnly = true)
    public DashboardResponse get(Long currentUserId) {
        Wallet wallet = walletRepository.findByUserId(currentUserId).orElseThrow(WalletNotFoundException::new);
        LocalDate today = LocalDate.now();
        LocalDate month = today.withDayOfMonth(1);
        LocalDate monthEnd = YearMonth.from(today).atEndOfMonth();

        BigDecimal balance = walletRepository.calculateBalance(wallet.getId()).setScale(2, RoundingMode.HALF_UP);
        BigDecimal outstanding = plannedExpenseRepository.sumOutstandingThrough(wallet.getId(), monthEnd)
                .setScale(2, RoundingMode.HALF_UP);
        BigDecimal safeToSpend = balance.subtract(outstanding).setScale(2, RoundingMode.HALF_UP);
        List<PlannedExpenseResponse> upcoming = plannedExpenseRepository
                .findTop3ByWalletIdAndStatusOrderByDueOnAscIdAsc(wallet.getId(), PlannedExpenseStatus.UPCOMING)
                .stream().map(plannedExpenseService::toResponse).toList();

        DashboardBudgetWarningResponse warning = buildBudgetWarning(currentUserId, wallet.getId(), month);
        return new DashboardResponse(balance, safeToSpend, outstanding, wallet.getCurrencyCode(), upcoming, warning);
    }

    private DashboardBudgetWarningResponse buildBudgetWarning(Long userId, Long walletId, LocalDate month) {
        boolean enabled = userPreferenceRepository.findByUserId(userId)
                .map(UserPreference::isShowBudgetWarnings)
                .orElse(true);
        if (!enabled) {
            return null;
        }
        return budgetRepository
                .findMonthBudgets(
                        walletId, month, BudgetStatus.ACTIVE)
                .stream()
                .map(budget -> warningCandidate(userId, budget))
                .filter(candidate -> !"SAFE".equals(candidate.health()))
                .max(Comparator.comparing(DashboardBudgetWarningResponse::percentageUsed))
                .orElse(null);
    }

    private DashboardBudgetWarningResponse warningCandidate(Long userId, Budget budget) {
        BigDecimal spent = budgetService.calculateSpent(budget);
        BigDecimal percentage = spent.multiply(BigDecimal.valueOf(100))
                .divide(budget.getLimitAmount(), 2, RoundingMode.HALF_UP);
        return new DashboardBudgetWarningResponse(
                budget.getId(), budget.getCategory().getName(), percentage,
                budgetService.healthFor(userId, percentage)
        );
    }
}
