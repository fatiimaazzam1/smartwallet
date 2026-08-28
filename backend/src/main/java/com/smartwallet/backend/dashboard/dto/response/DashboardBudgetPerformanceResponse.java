package com.smartwallet.backend.dashboard.dto.response;

public record DashboardBudgetPerformanceResponse(
        int safeCount,
        int warningCount,
        int limitReachedCount
) {
}
