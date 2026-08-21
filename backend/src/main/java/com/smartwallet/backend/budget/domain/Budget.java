package com.smartwallet.backend.budget.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Objects;

import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.common.domain.BaseEntity;
import com.smartwallet.backend.wallet.domain.Wallet;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import jakarta.persistence.Version;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "budgets")
public class Budget extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(name = "limit_amount", nullable = false, precision = 19, scale = 2)
    private BigDecimal limitAmount;

    @Column(name = "budget_month", nullable = false)
    private LocalDate budgetMonth;

    @Column(length = 255)
    private String note;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private BudgetStatus status = BudgetStatus.ACTIVE;

    @Version
    @Column(nullable = false)
    private long version;

    public Budget(
            Wallet wallet,
            Category category,
            BigDecimal limitAmount,
            LocalDate budgetMonth,
            String note
    ) {
        this.wallet = Objects.requireNonNull(wallet, "wallet must not be null");
        this.category = Objects.requireNonNull(category, "category must not be null");
        this.limitAmount = Objects.requireNonNull(limitAmount, "limitAmount must not be null");
        this.budgetMonth = Objects.requireNonNull(budgetMonth, "budgetMonth must not be null");
        this.note = note;
        this.status = BudgetStatus.ACTIVE;
    }

    public boolean isActive() {
        return status == BudgetStatus.ACTIVE;
    }

    public void update(BigDecimal limitAmount, String note) {
        if (!isActive()) {
            throw new IllegalStateException("Archived budgets cannot be edited");
        }
        this.limitAmount = Objects.requireNonNull(limitAmount, "limitAmount must not be null");
        this.note = note;
    }

    public void archive() {
        if (!isActive()) {
            throw new IllegalStateException("Budget is already archived");
        }
        this.status = BudgetStatus.ARCHIVED;
    }
}
