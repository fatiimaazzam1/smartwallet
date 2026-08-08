package com.smartwallet.backend.transaction.repository;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartwallet.backend.transaction.domain.TransactionStatus;
import com.smartwallet.backend.transaction.domain.TransactionType;
import com.smartwallet.backend.transaction.domain.WalletTransaction;

public interface TransactionRepository
        extends JpaRepository<WalletTransaction, Long> {

    @EntityGraph(attributePaths = {"wallet", "category"})
    Optional<WalletTransaction> findByIdAndWalletIdAndStatus(
            Long id,
            Long walletId,
            TransactionStatus status
    );

    @EntityGraph(attributePaths = {"wallet", "category"})
    Optional<WalletTransaction> findByWalletIdAndClientRequestId(
            Long walletId,
            UUID clientRequestId
    );

    @EntityGraph(attributePaths = {"wallet", "category"})
    @Query(
            value = """
                    select walletTransaction
                    from WalletTransaction walletTransaction
                    join walletTransaction.category category
                    where walletTransaction.wallet.id = :walletId
                      and walletTransaction.status = :status
                      and (:type is null or walletTransaction.type = :type)
                      and (:categoryId is null or category.id = :categoryId)
                      and (:startDate is null or walletTransaction.occurredOn >= :startDate)
                      and (:endDate is null or walletTransaction.occurredOn <= :endDate)
                      and (
                          :searchPattern is null
                          or lower(coalesce(walletTransaction.description, ''))
                              like :searchPattern escape '!'
                          or lower(category.name)
                              like :searchPattern escape '!'
                      )
                    """,
            countQuery = """
                    select count(walletTransaction)
                    from WalletTransaction walletTransaction
                    join walletTransaction.category category
                    where walletTransaction.wallet.id = :walletId
                      and walletTransaction.status = :status
                      and (:type is null or walletTransaction.type = :type)
                      and (:categoryId is null or category.id = :categoryId)
                      and (:startDate is null or walletTransaction.occurredOn >= :startDate)
                      and (:endDate is null or walletTransaction.occurredOn <= :endDate)
                      and (
                          :searchPattern is null
                          or lower(coalesce(walletTransaction.description, ''))
                              like :searchPattern escape '!'
                          or lower(category.name)
                              like :searchPattern escape '!'
                      )
                    """
    )
    Page<WalletTransaction> findHistory(
            @Param("walletId") Long walletId,
            @Param("status") TransactionStatus status,
            @Param("type") TransactionType type,
            @Param("categoryId") Long categoryId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("searchPattern") String searchPattern,
            Pageable pageable
    );
}
