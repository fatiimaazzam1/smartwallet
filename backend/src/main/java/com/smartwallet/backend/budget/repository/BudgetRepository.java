package com.smartwallet.backend.budget.repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartwallet.backend.budget.domain.Budget;
import com.smartwallet.backend.budget.domain.BudgetStatus;

public interface BudgetRepository extends JpaRepository<Budget, Long> {

    @EntityGraph(attributePaths = {"wallet", "category"})
    Optional<Budget> findByIdAndWalletIdAndStatus(
            Long id,
            Long walletId,
            BudgetStatus status
    );

    @EntityGraph(attributePaths = {"wallet", "category"})
    @Query("""
            select budget
            from Budget budget
            join budget.category category
            where budget.wallet.id = :walletId
              and budget.budgetMonth = :budgetMonth
              and budget.status = :status
            order by category.displayOrder asc, lower(category.name) asc, budget.id asc
            """)
    List<Budget> findMonthBudgets(
            @Param("walletId") Long walletId,
            @Param("budgetMonth") LocalDate budgetMonth,
            @Param("status") BudgetStatus status
    );

    boolean existsByWalletIdAndCategoryIdAndBudgetMonthAndStatus(
            Long walletId,
            Long categoryId,
            LocalDate budgetMonth,
            BudgetStatus status
    );

    @Query(value = """
            select coalesce(sum(amount), 0)
            from transactions
            where wallet_id = :walletId
              and category_id = :categoryId
              and transaction_type = 'EXPENSE'
              and status = 'ACTIVE'
              and occurred_on between :startDate and :endDate
            """, nativeQuery = true)
    BigDecimal calculateSpent(
            @Param("walletId") Long walletId,
            @Param("categoryId") Long categoryId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
