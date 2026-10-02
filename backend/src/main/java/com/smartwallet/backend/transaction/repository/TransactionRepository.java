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

    @EntityGraph(attributePaths = {"wallet", "category"})
    java.util.List<WalletTransaction> findByWalletIdAndStatusAndTypeAndCategoryIdAndOccurredOnBetween(
            Long walletId,
            TransactionStatus status,
            TransactionType type,
            Long categoryId,
            LocalDate startDate,
            LocalDate endDate,
            Pageable pageable
    );
    @Query(value = """
            select coalesce(sum(amount), 0)
            from transactions
            where wallet_id = :walletId
              and transaction_type = 'EXPENSE'
              and status = 'ACTIVE'
              and occurred_on between :startDate and :endDate
            """, nativeQuery = true)
    java.math.BigDecimal sumActiveExpensesBetween(
            @Param("walletId") Long walletId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    @Query(value = """
            select c.id as categoryId,
                   c.name as categoryName,
                   c.icon_key as iconKey,
                   sum(t.amount) as totalAmount
            from transactions t
            join categories c on c.id = t.category_id
            where t.wallet_id = :walletId
              and t.transaction_type = 'EXPENSE'
              and t.status = 'ACTIVE'
              and t.occurred_on between :startDate and :endDate
            group by c.id, c.name, c.icon_key
            order by sum(t.amount) desc, lower(c.name) asc, c.id asc
            limit 1
            """, nativeQuery = true)
    Optional<CategorySpendingView> findTopActiveExpenseCategoryBetween(
            @Param("walletId") Long walletId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

}
