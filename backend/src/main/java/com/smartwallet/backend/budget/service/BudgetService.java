package com.smartwallet.backend.budget.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.budget.domain.Budget;
import com.smartwallet.backend.budget.domain.BudgetStatus;
import com.smartwallet.backend.budget.dto.request.CreateBudgetRequest;
import com.smartwallet.backend.budget.dto.request.UpdateBudgetRequest;
import com.smartwallet.backend.budget.dto.response.BudgetCategoryResponse;
import com.smartwallet.backend.budget.dto.response.BudgetMonthResponse;
import com.smartwallet.backend.budget.dto.response.BudgetRelatedExpenseResponse;
import com.smartwallet.backend.budget.dto.response.BudgetResponse;
import com.smartwallet.backend.budget.exception.BudgetConflictException;
import com.smartwallet.backend.budget.exception.BudgetNotFoundException;
import com.smartwallet.backend.budget.repository.BudgetRepository;
import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.category.domain.CategoryStatus;
import com.smartwallet.backend.category.domain.CategoryType;
import com.smartwallet.backend.category.exception.CategoryNotFoundException;
import com.smartwallet.backend.category.repository.CategoryRepository;
import com.smartwallet.backend.preference.domain.UserPreference;
import com.smartwallet.backend.transaction.domain.TransactionStatus;
import com.smartwallet.backend.transaction.domain.TransactionType;
import com.smartwallet.backend.transaction.repository.TransactionRepository;
import com.smartwallet.backend.preference.repository.UserPreferenceRepository;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.exception.WalletNotFoundException;
import com.smartwallet.backend.wallet.repository.WalletRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class BudgetService {

    private final BudgetRepository budgetRepository;
    private final WalletRepository walletRepository;
    private final CategoryRepository categoryRepository;
    private final UserPreferenceRepository userPreferenceRepository;
    private final TransactionRepository transactionRepository;

    @Transactional
    public BudgetResponse create(Long currentUserId, CreateBudgetRequest request) {
        Wallet wallet = findWallet(currentUserId);
        Category category = findExpenseCategory(currentUserId, request.categoryId());
        LocalDate month = normalizeMonth(request.budgetMonth());
        validateCreateMonth(month);
        BigDecimal limit = normalizeAmount(request.limitAmount());
        String note = normalizeText(request.note(), "Note", 255);

        if (budgetRepository.existsByWalletIdAndCategoryIdAndBudgetMonthAndStatus(
                wallet.getId(), category.getId(), month, BudgetStatus.ACTIVE)) {
            throw new BudgetConflictException("An active budget already exists for this category and month");
        }

        Budget budget = new Budget(wallet, category, limit, month, note);
        try {
            budget = budgetRepository.saveAndFlush(budget);
        } catch (DataIntegrityViolationException exception) {
            throw new BudgetConflictException("An active budget already exists for this category and month");
        }
        return toResponse(currentUserId, budget);
    }

    @Transactional(readOnly = true)
    public BudgetMonthResponse listMonth(Long currentUserId, LocalDate requestedMonth) {
        Wallet wallet = findWallet(currentUserId);
        LocalDate month = normalizeMonth(requestedMonth == null ? LocalDate.now() : requestedMonth);
        List<BudgetResponse> budgets = budgetRepository
                .findMonthBudgets(
                        wallet.getId(), month, BudgetStatus.ACTIVE)
                .stream()
                .map(budget -> toResponse(currentUserId, budget))
                .toList();

        BigDecimal planned = budgets.stream()
                .map(BudgetResponse::limitAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);
        BigDecimal spent = budgets.stream()
                .map(BudgetResponse::spentAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);

        return new BudgetMonthResponse(
                month,
                planned,
                spent,
                planned.subtract(spent).setScale(2, RoundingMode.HALF_UP),
                wallet.getCurrencyCode(),
                budgets
        );
    }

    @Transactional(readOnly = true)
    public BudgetResponse get(Long currentUserId, Long budgetId) {
        Wallet wallet = findWallet(currentUserId);
        return toResponse(currentUserId, findActive(wallet.getId(), budgetId));
    }

    @Transactional(readOnly = true)
    public List<BudgetRelatedExpenseResponse> relatedExpenses(
            Long currentUserId,
            Long budgetId,
            int size
    ) {
        if (size < 1 || size > 20) {
            throw new IllegalArgumentException("Related expense page size must be between 1 and 20");
        }
        Wallet wallet = findWallet(currentUserId);
        Budget budget = findActive(wallet.getId(), budgetId);
        LocalDate start = budget.getBudgetMonth();
        LocalDate end = YearMonth.from(start).atEndOfMonth();
        return transactionRepository.findByWalletIdAndStatusAndTypeAndCategoryIdAndOccurredOnBetween(
                        wallet.getId(),
                        TransactionStatus.ACTIVE,
                        TransactionType.EXPENSE,
                        budget.getCategory().getId(),
                        start,
                        end,
                        PageRequest.of(
                                0,
                                size,
                                Sort.by(Sort.Order.desc("occurredOn"), Sort.Order.desc("id"))
                        )
                )
                .stream()
                .map(transaction -> new BudgetRelatedExpenseResponse(
                        transaction.getId(),
                        transaction.getAmount().setScale(2, RoundingMode.HALF_UP),
                        transaction.getOccurredOn(),
                        transaction.getDescription()
                ))
                .toList();
    }

    @Transactional
    public BudgetResponse update(Long currentUserId, Long budgetId, UpdateBudgetRequest request) {
        Wallet wallet = findWallet(currentUserId);
        Budget budget = findActive(wallet.getId(), budgetId);
        requireVersion(budget, request.version());
        budget.update(normalizeAmount(request.limitAmount()), normalizeText(request.note(), "Note", 255));
        return toResponse(currentUserId, budgetRepository.saveAndFlush(budget));
    }

    @Transactional
    public void archive(Long currentUserId, Long budgetId, long version) {
        Wallet wallet = findWallet(currentUserId);
        Budget budget = findActive(wallet.getId(), budgetId);
        requireVersion(budget, version);
        budget.archive();
        budgetRepository.saveAndFlush(budget);
    }

    public BigDecimal calculateSpent(Budget budget) {
        LocalDate start = budget.getBudgetMonth();
        LocalDate end = YearMonth.from(start).atEndOfMonth();
        return budgetRepository.calculateSpent(
                budget.getWallet().getId(), budget.getCategory().getId(), start, end)
                .setScale(2, RoundingMode.HALF_UP);
    }

    public String healthFor(long currentUserId, BigDecimal percentage) {
        int threshold = userPreferenceRepository.findByUserId(currentUserId)
                .map(UserPreference::getBudgetWarningThreshold)
                .orElse(70);
        if (percentage.compareTo(BigDecimal.valueOf(100)) >= 0) {
            return "LIMIT_REACHED";
        }
        if (percentage.compareTo(BigDecimal.valueOf(threshold)) >= 0) {
            return "WARNING";
        }
        return "SAFE";
    }

    private BudgetResponse toResponse(Long currentUserId, Budget budget) {
        BigDecimal spent = calculateSpent(budget);
        BigDecimal limit = budget.getLimitAmount().setScale(2, RoundingMode.HALF_UP);
        BigDecimal remaining = limit.subtract(spent).setScale(2, RoundingMode.HALF_UP);
        BigDecimal percentage = spent.multiply(BigDecimal.valueOf(100))
                .divide(limit, 2, RoundingMode.HALF_UP);
        YearMonth budgetYearMonth = YearMonth.from(budget.getBudgetMonth());
        YearMonth currentYearMonth = YearMonth.now();
        LocalDate end = budgetYearMonth.atEndOfMonth();
        int daysRemaining;
        if (budgetYearMonth.isBefore(currentYearMonth)) {
            daysRemaining = 0;
        } else if (budgetYearMonth.isAfter(currentYearMonth)) {
            daysRemaining = budgetYearMonth.lengthOfMonth();
        } else {
            daysRemaining = (int) ChronoUnit.DAYS.between(LocalDate.now(), end) + 1;
        }

        Category category = budget.getCategory();
        return new BudgetResponse(
                budget.getId(), budget.getVersion(), budget.getBudgetMonth(), limit,
                spent, remaining, percentage, daysRemaining,
                budget.getWallet().getCurrencyCode(), healthFor(currentUserId, percentage),
                budget.getNote(),
                new BudgetCategoryResponse(category.getId(), category.getName(), category.getIconKey())
        );
    }

    private Budget findActive(Long walletId, Long budgetId) {
        return budgetRepository.findByIdAndWalletIdAndStatus(budgetId, walletId, BudgetStatus.ACTIVE)
                .orElseThrow(BudgetNotFoundException::new);
    }

    private Wallet findWallet(Long userId) {
        return walletRepository.findByUserId(userId).orElseThrow(WalletNotFoundException::new);
    }

    private Category findExpenseCategory(Long userId, Long categoryId) {
        Category category = categoryRepository.findVisibleCategoryById(categoryId, userId)
                .orElseThrow(CategoryNotFoundException::new);
        if (category.getStatus() != CategoryStatus.ACTIVE || category.getType() != CategoryType.EXPENSE) {
            throw new CategoryNotFoundException();
        }
        return category;
    }

    private LocalDate normalizeMonth(LocalDate value) {
        if (value == null) {
            throw new IllegalArgumentException("Budget month is required");
        }
        return value.withDayOfMonth(1);
    }

    private void validateCreateMonth(LocalDate month) {
        LocalDate current = LocalDate.now().withDayOfMonth(1);
        if (month.isBefore(current)) {
            throw new IllegalArgumentException("Budget month cannot be in the past");
        }
    }

    private BigDecimal normalizeAmount(BigDecimal value) {
        if (value == null || value.signum() <= 0) {
            throw new IllegalArgumentException("Budget limit must be greater than zero");
        }
        if (value.precision() - value.scale() > 17 || value.scale() > 2) {
            throw new IllegalArgumentException("Budget limit must fit within 17 integer digits and 2 decimal places");
        }
        return value.setScale(2, RoundingMode.UNNECESSARY);
    }

    private String normalizeText(String value, String label, int maxLength) {
        if (value == null) {
            return null;
        }
        String normalized = value.strip().replaceAll("[\\p{Zs}\\s]+", " ");
        if (normalized.isBlank()) {
            return null;
        }
        if (normalized.length() > maxLength) {
            throw new IllegalArgumentException(label + " must not exceed " + maxLength + " characters");
        }
        if (normalized.codePoints().anyMatch(codePoint -> Character.isISOControl(codePoint)
                || Character.getType(codePoint) == Character.FORMAT)) {
            throw new IllegalArgumentException(label + " contains unsupported characters");
        }
        return normalized;
    }

    private void requireVersion(Budget budget, long version) {
        if (budget.getVersion() != version) {
            throw new BudgetConflictException("Budget changed. Refresh and try again");
        }
    }
}
