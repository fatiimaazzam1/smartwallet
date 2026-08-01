package com.smartwallet.backend.preference.domain;

import com.smartwallet.backend.common.domain.BaseEntity;
import com.smartwallet.backend.user.domain.User;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "user_preferences")
public class UserPreference extends BaseEntity {

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            unique = true
    )
    private User user;

    @Column(name = "hide_balance_by_default", nullable = false)
    private boolean hideBalanceByDefault = false;

    @Column(name = "compact_transaction_list", nullable = false)
    private boolean compactTransactionList = false;

    @Column(name = "show_budget_warnings", nullable = false)
    private boolean showBudgetWarnings = true;

    @Column(name = "budget_warning_threshold", nullable = false)
    private int budgetWarningThreshold = 70;

    @Convert(converter = DateFormatPreferenceConverter.class)
    @Column(name = "date_format", nullable = false, length = 20)
    private DateFormatPreference dateFormat = DateFormatPreference.DD_MM_YYYY;

    @Enumerated(EnumType.STRING)
    @Column(name = "dashboard_period", nullable = false, length = 30)
    private DashboardPeriod dashboardPeriod = DashboardPeriod.CURRENT_MONTH;

    @Enumerated(EnumType.STRING)
    @Column(name = "language", nullable = false, length = 20)
    private AppLanguage language = AppLanguage.SYSTEM;

    public UserPreference(
            User user
    ) {
        this.user = user;
    }
}
