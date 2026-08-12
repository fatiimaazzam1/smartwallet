package com.smartwallet.backend.transaction.domain;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Objects;
import java.util.UUID;

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
@Table(name = "transactions")
public class WalletTransaction extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "wallet_id", nullable = false)
    private Wallet wallet;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Enumerated(EnumType.STRING)
    @Column(name = "transaction_type", nullable = false, length = 20)
    private TransactionType type;

    @Column(nullable = false, precision = 19, scale = 2)
    private BigDecimal amount;

    @Column(length = 255)
    private String description;

    @Column(name = "occurred_on", nullable = false)
    private LocalDate occurredOn;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TransactionStatus status = TransactionStatus.ACTIVE;

    @Version
    @Column(nullable = false)
    private long version;

    @Column(name = "client_request_id", updatable = false)
    private UUID clientRequestId;

    public WalletTransaction(
            Wallet wallet,
            Category category,
            TransactionType type,
            BigDecimal amount,
            String description,
            LocalDate occurredOn,
            UUID clientRequestId
    ) {
        this.wallet = Objects.requireNonNull(wallet, "wallet must not be null");
        this.category = Objects.requireNonNull(category, "category must not be null");
        this.type = Objects.requireNonNull(type, "type must not be null");
        this.amount = Objects.requireNonNull(amount, "amount must not be null");
        this.description = description;
        this.occurredOn = Objects.requireNonNull(
                occurredOn,
                "occurredOn must not be null"
        );
        this.clientRequestId = Objects.requireNonNull(
                clientRequestId,
                "clientRequestId must not be null"
        );
        this.status = TransactionStatus.ACTIVE;
    }

    public boolean isActive() {
        return status == TransactionStatus.ACTIVE;
    }

    public void update(
            Category category,
            BigDecimal amount,
            String description,
            LocalDate occurredOn
    ) {
        if (!isActive()) {
            throw new IllegalStateException("Archived transactions cannot be edited");
        }

        this.category = Objects.requireNonNull(
                category,
                "category must not be null"
        );
        this.amount = Objects.requireNonNull(amount, "amount must not be null");
        this.description = description;
        this.occurredOn = Objects.requireNonNull(
                occurredOn,
                "occurredOn must not be null"
        );
    }

    public void archive() {
        if (!isActive()) {
            throw new IllegalStateException("Transaction is already archived");
        }
        status = TransactionStatus.ARCHIVED;
    }
}
