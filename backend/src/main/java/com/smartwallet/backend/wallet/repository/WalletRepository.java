package com.smartwallet.backend.wallet.repository;

import java.math.BigDecimal;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartwallet.backend.wallet.domain.Wallet;

public interface WalletRepository extends JpaRepository<Wallet, Long> {

    Optional<Wallet> findByUserId(Long userId);

    @Query(
            value = """
                    select coalesce(
                        sum(
                            case
                                when transaction_type = 'INCOME' then amount
                                when transaction_type = 'EXPENSE' then -amount
                                else 0
                            end
                        ),
                        0
                    )
                    from transactions
                    where wallet_id = :walletId
                    """,
            nativeQuery = true
    )
    BigDecimal calculateBalance(
            @Param("walletId") Long walletId
    );
}
