package com.smartwallet.backend.dashboard.dto.response;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.fasterxml.jackson.annotation.JsonFormat;

public record DashboardWeeklyInsightsResponse(
        LocalDate weekStart,
        LocalDate throughDate,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal currentWeekSpending,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal previousComparableSpending,
        boolean comparisonAvailable,
        String comparisonDirection,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal comparisonPercentage,
        DashboardTopSpendingCategoryResponse topSpendingCategory,
        DashboardBudgetPerformanceResponse budgetPerformance,
        long upcomingFourteenDayCount,
        @JsonFormat(shape = JsonFormat.Shape.STRING)
        BigDecimal upcomingFourteenDayTotal
) {
}
