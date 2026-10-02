package com.smartwallet.backend.plannedexpense.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Objects;
import java.util.UUID;

import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.common.domain.BaseEntity;
import com.smartwallet.backend.transaction.domain.WalletTransaction;
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
@Table(name = "planned_expenses")
public class PlannedExpense extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    @Column(name = "due_on", nullable = false)
    private LocalDate dueOn;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PlannedExpenseRecurrence recurrence = PlannedExpenseRecurrence.NONE;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private PlannedExpenseStatus status = PlannedExpenseStatus.UPCOMING;

    @Column(length = 255)
    private String note;

    @Column(name = "create_client_request_id", nullable = false, updatable = false)
    private UUID createClientRequestId;

    @Column(name = "paid_on")
    private LocalDate paidOn;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "paid_transaction_id")
    private WalletTransaction paidTransaction;

    @Column(name = "payment_client_request_id")
    private UUID paymentClientRequestId;

    @Version
    @Column(nullable = false)
    private long version;

    public PlannedExpense(
            Wallet wallet,
            Category category,
            String title,
            BigDecimal amount,
            LocalDate dueOn,
            PlannedExpenseRecurrence recurrence,
            String note,
            UUID createClientRequestId
    ) {
        this.wallet = Objects.requireNonNull(wallet, "wallet must not be null");
        this.category = Objects.requireNonNull(category, "category must not be null");
        this.title = Objects.requireNonNull(title, "title must not be null");
        this.amount = Objects.requireNonNull(amount, "amount must not be null");
        this.dueOn = Objects.requireNonNull(dueOn, "dueOn must not be null");
        this.recurrence = Objects.requireNonNull(recurrence, "recurrence must not be null");
        this.note = note;
        this.createClientRequestId = Objects.requireNonNull(
                createClientRequestId, "createClientRequestId must not be null");
        this.status = PlannedExpenseStatus.UPCOMING;
    }

    public boolean isUpcoming() {
        return status == PlannedExpenseStatus.UPCOMING;
    }

    public void update(
            Category category,
            String title,
            BigDecimal amount,
            LocalDate dueOn,
            PlannedExpenseRecurrence recurrence,
            String note
    ) {
        if (!isUpcoming()) {
            throw new IllegalStateException("Only upcoming planned expenses can be edited");
        }
        this.category = Objects.requireNonNull(category, "category must not be null");
        this.title = Objects.requireNonNull(title, "title must not be null");
        this.amount = Objects.requireNonNull(amount, "amount must not be null");
        this.dueOn = Objects.requireNonNull(dueOn, "dueOn must not be null");
        this.recurrence = Objects.requireNonNull(recurrence, "recurrence must not be null");
        this.note = note;
    }

    public void cancel() {
        if (!isUpcoming()) {
            throw new IllegalStateException("Only upcoming planned expenses can be cancelled");
        }
        this.status = PlannedExpenseStatus.CANCELLED;
    }

    public void markPaid(LocalDate paidOn, WalletTransaction transaction, UUID clientRequestId) {
        if (!isUpcoming()) {
            throw new IllegalStateException("Only upcoming planned expenses can be marked as paid");
        }
        this.paidOn = Objects.requireNonNull(paidOn, "paidOn must not be null");
        this.paidTransaction = Objects.requireNonNull(transaction, "transaction must not be null");
        this.paymentClientRequestId = Objects.requireNonNull(clientRequestId, "clientRequestId must not be null");
        this.status = PlannedExpenseStatus.PAID;
    }

    public void archive() {
        if (status == PlannedExpenseStatus.ARCHIVED) {
            throw new IllegalStateException("Planned expense is already archived");
        }
        this.status = PlannedExpenseStatus.ARCHIVED;
        this.paidOn = null;
        this.paidTransaction = null;
        this.paymentClientRequestId = null;
    }
}
