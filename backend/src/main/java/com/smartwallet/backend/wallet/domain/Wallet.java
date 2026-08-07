package com.smartwallet.backend.wallet.domain;

import com.smartwallet.backend.common.domain.BaseEntity;
import com.smartwallet.backend.user.domain.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
@Table(name = "wallets")
public class Wallet extends BaseEntity {

    public static final String DEFAULT_NAME = "Personal Wallet";
    public static final String DEFAULT_CURRENCY_CODE = "USD";

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            unique = true
    )
    private User user;

    @Column(nullable = false, length = 80)
    private String name = DEFAULT_NAME;

    @Column(name = "currency_code", nullable = false, length = 3)
    private String currencyCode = DEFAULT_CURRENCY_CODE;

    public Wallet(User user) {
        this.user = user;
        this.name = DEFAULT_NAME;
        this.currencyCode = DEFAULT_CURRENCY_CODE;
    }
}
