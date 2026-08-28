package com.smartwallet.backend.dashboard.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalAdjusters;
import java.util.Comparator;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.budget.domain.Budget;
import com.smartwallet.backend.budget.domain.BudgetStatus;
import com.smartwallet.backend.budget.repository.BudgetRepository;
import com.smartwallet.backend.budget.service.BudgetService;
import com.smartwallet.backend.dashboard.dto.response.DashboardBudgetPerformanceResponse;
import com.smartwallet.backend.dashboard.dto.response.DashboardBudgetWarningResponse;
import com.smartwallet.backend.dashboard.dto.response.DashboardResponse;
import com.smartwallet.backend.dashboard.dto.response.DashboardTopSpendingCategoryResponse;
import com.smartwallet.backend.dashboard.dto.response.DashboardWeeklyInsightsResponse;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;
import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpenseResponse;
import com.smartwallet.backend.plannedexpense.repository.PlannedExpenseRepository;
import com.smartwallet.backend.plannedexpense.service.PlannedExpenseService;
import com.smartwallet.backend.preference.domain.UserPreference;
import com.smartwallet.backend.preference.repository.UserPreferenceRepository;
import com.smartwallet.backend.transaction.repository.TransactionRepository;
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
    private final TransactionRepository transactionRepository;

    @Transactional(readOnly = true)
    public DashboardResponse get(Long currentUserId) {
        Wallet wallet = walletRepository.findByUserId(currentUserId).orElseThrow(WalletNotFoundException::new);
        LocalDate today = LocalDate.now();
        LocalDate month = today.withDayOfMonth(1);
        LocalDate monthEnd = YearMonth.from(today).atEndOfMonth();

        BigDecimal balance = money(walletRepository.calculateBalance(wallet.getId()));
        BigDecimal outstanding = money(plannedExpenseRepository.sumOutstandingThrough(wallet.getId(), monthEnd));
        BigDecimal safeToSpend = money(balance.subtract(outstanding));
        long upcomingExpenseCount = plannedExpenseRepository
                .countByWalletIdAndStatus(wallet.getId(), PlannedExpenseStatus.UPCOMING);
        BigDecimal upcomingExpenseTotal = money(plannedExpenseRepository
                .sumByWalletIdAndStatus(wallet.getId(), PlannedExpenseStatus.UPCOMING));
        List<PlannedExpenseResponse> upcoming = plannedExpenseRepository
                .findTop3ByWalletIdAndStatusOrderByDueOnAscIdAsc(wallet.getId(), PlannedExpenseStatus.UPCOMING)
                .stream()
                .map(plannedExpenseService::toResponse)
                .toList();

        List<Budget> monthBudgets = budgetRepository.findMonthBudgets(
                wallet.getId(), month, BudgetStatus.ACTIVE
        );
        List<DashboardBudgetWarningResponse> budgetCandidates = monthBudgets.stream()
                .map(budget -> warningCandidate(currentUserId, budget))
                .toList();

        DashboardBudgetWarningResponse warning = buildBudgetWarning(currentUserId, budgetCandidates);
        DashboardWeeklyInsightsResponse weeklyInsights = buildWeeklyInsights(
                wallet.getId(), today, budgetCandidates
        );

        return new DashboardResponse(
                balance,
                safeToSpend,
                outstanding,
                wallet.getCurrencyCode(),
                upcomingExpenseCount,
                upcomingExpenseTotal,
                upcoming,
                warning,
                weeklyInsights
        );
    }

    private DashboardBudgetWarningResponse buildBudgetWarning(
            Long userId,
            List<DashboardBudgetWarningResponse> candidates
    ) {
        boolean enabled = userPreferenceRepository.findByUserId(userId)
                .map(UserPreference::isShowBudgetWarnings)
                .orElse(true);
        if (!enabled) {
            return null;
        }
        return candidates.stream()
                .filter(candidate -> !"SAFE".equals(candidate.health()))
                .max(Comparator.comparing(DashboardBudgetWarningResponse::percentageUsed))
                .orElse(null);
    }

    private DashboardWeeklyInsightsResponse buildWeeklyInsights(
            Long walletId,
            LocalDate today,
            List<DashboardBudgetWarningResponse> budgetCandidates
    ) {
        LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        long elapsedDays = ChronoUnit.DAYS.between(weekStart, today);
        LocalDate previousWeekStart = weekStart.minusWeeks(1);
        LocalDate previousComparableEnd = previousWeekStart.plusDays(elapsedDays);

        BigDecimal currentWeekSpending = money(transactionRepository.sumActiveExpensesBetween(
                walletId, weekStart, today
        ));
        BigDecimal previousComparableSpending = money(transactionRepository.sumActiveExpensesBetween(
                walletId, previousWeekStart, previousComparableEnd
        ));

        boolean comparisonAvailable = previousComparableSpending.signum() > 0;
        String comparisonDirection = null;
        BigDecimal comparisonPercentage = null;
        if (comparisonAvailable) {
            int comparison = currentWeekSpending.compareTo(previousComparableSpending);
            comparisonDirection = comparison > 0
                    ? "INCREASED"
                    : comparison < 0 ? "DECREASED" : "UNCHANGED";
            comparisonPercentage = currentWeekSpending.subtract(previousComparableSpending)
                    .abs()
                    .multiply(BigDecimal.valueOf(100))
                    .divide(previousComparableSpending, 2, RoundingMode.HALF_UP);
        }

        DashboardTopSpendingCategoryResponse topCategory = transactionRepository
                .findTopActiveExpenseCategoryBetween(walletId, weekStart, today)
                .map(row -> new DashboardTopSpendingCategoryResponse(
                        row.getCategoryId(),
                        row.getCategoryName(),
                        row.getIconKey(),
                        money(row.getTotalAmount())
                ))
                .orElse(null);

        int safe = 0;
        int warning = 0;
        int limitReached = 0;
        for (DashboardBudgetWarningResponse candidate : budgetCandidates) {
            switch (candidate.health()) {
                case "WARNING" -> warning++;
                case "LIMIT_REACHED" -> limitReached++;
                default -> safe++;
            }
        }
        DashboardBudgetPerformanceResponse budgetPerformance = new DashboardBudgetPerformanceResponse(
                safe, warning, limitReached
        );

        LocalDate fourteenDayEnd = today.plusDays(14);
        long upcomingFourteenDayCount = plannedExpenseRepository.countByWalletIdAndStatusAndDueOnBetween(
                walletId, PlannedExpenseStatus.UPCOMING, today, fourteenDayEnd
        );
        BigDecimal upcomingFourteenDayTotal = money(plannedExpenseRepository.sumUpcomingBetween(
                walletId, today, fourteenDayEnd
        ));

        return new DashboardWeeklyInsightsResponse(
                weekStart,
                today,
                currentWeekSpending,
                previousComparableSpending,
                comparisonAvailable,
                comparisonDirection,
                comparisonPercentage,
                topCategory,
                budgetPerformance,
                upcomingFourteenDayCount,
                upcomingFourteenDayTotal
        );
    }

    private DashboardBudgetWarningResponse warningCandidate(Long userId, Budget budget) {
        BigDecimal spent = budgetService.calculateSpent(budget);
        BigDecimal percentage = spent.multiply(BigDecimal.valueOf(100))
                .divide(budget.getLimitAmount(), 2, RoundingMode.HALF_UP);
        return new DashboardBudgetWarningResponse(
                budget.getId(),
                budget.getCategory().getName(),
                percentage,
                budgetService.healthFor(userId, percentage)
        );
    }

    private BigDecimal money(BigDecimal value) {
        return (value == null ? BigDecimal.ZERO : value).setScale(2, RoundingMode.HALF_UP);
    }
}
