package com.smartwallet.backend.plannedexpense.repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartwallet.backend.plannedexpense.domain.PlannedExpense;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;

public interface PlannedExpenseRepository extends JpaRepository<PlannedExpense, Long> {

    @EntityGraph(attributePaths = {"wallet", "category", "paidTransaction"})
    Optional<PlannedExpense> findByWalletIdAndCreateClientRequestId(
            Long walletId,
            UUID createClientRequestId
    );

    @EntityGraph(attributePaths = {"wallet", "category", "paidTransaction"})
    Optional<PlannedExpense> findByWalletIdAndPaymentClientRequestId(
            Long walletId,
            UUID paymentClientRequestId
    );

    @EntityGraph(attributePaths = {"wallet", "category", "paidTransaction"})
    Optional<PlannedExpense> findByIdAndWalletIdAndStatusNot(
            Long id,
            Long walletId,
            PlannedExpenseStatus status
    );

    @EntityGraph(attributePaths = {"wallet", "category", "paidTransaction"})
    Page<PlannedExpense> findAllByWalletIdAndStatus(
            Long walletId,
            PlannedExpenseStatus status,
            Pageable pageable
    );

    @EntityGraph(attributePaths = {"wallet", "category"})
    List<PlannedExpense> findTop3ByWalletIdAndStatusOrderByDueOnAscIdAsc(
            Long walletId,
            PlannedExpenseStatus status
    );

    @Query("""
            select coalesce(sum(p.amount), 0)
            from PlannedExpense p
            where p.wallet.id = :walletId
              and p.status = :status
            """)
    BigDecimal sumByWalletIdAndStatus(
            @Param("walletId") Long walletId,
            @Param("status") PlannedExpenseStatus status
    );

    @Query(value = """
            select coalesce(sum(amount), 0)
            from planned_expenses
            where wallet_id = :walletId
              and status = 'UPCOMING'
              and due_on <= :endDate
            """, nativeQuery = true)
    BigDecimal sumOutstandingThrough(
            @Param("walletId") Long walletId,
            @Param("endDate") LocalDate endDate
    );

    @Query(value = """
            select coalesce(sum(amount), 0)
            from planned_expenses
            where wallet_id = :walletId
              and status = 'UPCOMING'
              and due_on between :startDate and :endDate
            """, nativeQuery = true)
    BigDecimal sumUpcomingBetween(
            @Param("walletId") Long walletId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );

    long countByWalletIdAndStatusAndDueOnBetween(
            Long walletId,
            PlannedExpenseStatus status,
            LocalDate startDate,
            LocalDate endDate
    );
}
