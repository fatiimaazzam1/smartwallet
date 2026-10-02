package com.smartwallet.backend.plannedexpense.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.Objects;
import java.util.UUID;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.category.domain.CategoryStatus;
import com.smartwallet.backend.category.domain.CategoryType;
import com.smartwallet.backend.category.exception.CategoryNotFoundException;
import com.smartwallet.backend.category.repository.CategoryRepository;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpense;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseRecurrence;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;
import com.smartwallet.backend.plannedexpense.dto.request.CreatePlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.dto.request.MarkPlannedExpensePaidRequest;
import com.smartwallet.backend.plannedexpense.dto.request.UpdatePlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.dto.request.VersionedPlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpenseCategoryResponse;
import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpensePageResponse;
import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpenseResponse;
import com.smartwallet.backend.plannedexpense.exception.PlannedExpenseConflictException;
import com.smartwallet.backend.plannedexpense.exception.PlannedExpenseNotFoundException;
import com.smartwallet.backend.plannedexpense.repository.PlannedExpenseRepository;
import com.smartwallet.backend.transaction.domain.TransactionStatus;
import com.smartwallet.backend.transaction.domain.TransactionType;
import com.smartwallet.backend.transaction.domain.WalletTransaction;
import com.smartwallet.backend.transaction.dto.request.CreateTransactionRequest;
import com.smartwallet.backend.transaction.dto.response.TransactionResponse;
import com.smartwallet.backend.transaction.repository.TransactionRepository;
import com.smartwallet.backend.transaction.service.TransactionService;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.exception.WalletNotFoundException;
import com.smartwallet.backend.wallet.repository.WalletRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class PlannedExpenseService {

    private static final int MAX_PAGE_SIZE = 50;

    private final PlannedExpenseRepository plannedExpenseRepository;
    private final WalletRepository walletRepository;
    private final CategoryRepository categoryRepository;
    private final TransactionService transactionService;
    private final TransactionRepository transactionRepository;

    @Transactional
    public PlannedExpenseResponse create(Long currentUserId, CreatePlannedExpenseRequest request) {
        Wallet wallet = findWallet(currentUserId);
        String title = normalizeText(request.title(), "Title", 100, true);
        BigDecimal amount = normalizeAmount(request.amount());
        LocalDate dueOn = Objects.requireNonNull(request.dueOn(), "dueOn must not be null");
        PlannedExpenseRecurrence recurrence = Objects.requireNonNull(
                request.recurrence(), "recurrence must not be null");
        String note = normalizeText(request.note(), "Note", 255, false);

        PlannedExpense existing = plannedExpenseRepository
                .findByWalletIdAndCreateClientRequestId(wallet.getId(), request.clientRequestId())
                .orElse(null);
        if (existing != null) {
            return resolveIdempotentCreate(existing, request, title, amount, dueOn, recurrence, note);
        }

        requireNotPastDueDate(dueOn);
        Category category = findExpenseCategory(currentUserId, request.categoryId());
        PlannedExpense entity = new PlannedExpense(
                wallet, category, title, amount, dueOn, recurrence, note, request.clientRequestId());
        try {
            return toResponse(plannedExpenseRepository.saveAndFlush(entity));
        } catch (DataIntegrityViolationException exception) {
            PlannedExpense concurrent = plannedExpenseRepository
                    .findByWalletIdAndCreateClientRequestId(wallet.getId(), request.clientRequestId())
                    .orElseThrow(() -> exception);
            return resolveIdempotentCreate(
                    concurrent, request, title, amount, dueOn, recurrence, note);
        }
    }

    @Transactional(readOnly = true)
    public PlannedExpensePageResponse list(
            Long currentUserId,
            PlannedExpenseStatus status,
            int page,
            int size
    ) {
        if (page < 0 || size < 1 || size > MAX_PAGE_SIZE) {
            throw new IllegalArgumentException("Invalid pagination parameters");
        }
        if (status == null || status == PlannedExpenseStatus.ARCHIVED) {
            throw new IllegalArgumentException("A visible planned expense status is required");
        }
        Wallet wallet = findWallet(currentUserId);
        Sort sort = status == PlannedExpenseStatus.UPCOMING
                ? Sort.by(Sort.Order.asc("dueOn"), Sort.Order.asc("id"))
                : Sort.by(Sort.Order.desc("updatedAt"), Sort.Order.desc("id"));
        Page<PlannedExpense> result = plannedExpenseRepository.findAllByWalletIdAndStatus(
                wallet.getId(), status, PageRequest.of(page, size, sort));
        BigDecimal totalAmount = plannedExpenseRepository
                .sumByWalletIdAndStatus(wallet.getId(), status)
                .setScale(2, RoundingMode.HALF_UP);
        return new PlannedExpensePageResponse(
                result.getContent().stream().map(this::toResponse).toList(),
                result.getNumber(), result.getSize(), result.getTotalElements(),
                result.getTotalPages(), result.isLast(), totalAmount
        );
    }

    @Transactional(readOnly = true)
    public PlannedExpenseResponse get(Long currentUserId, Long id) {
        Wallet wallet = findWallet(currentUserId);
        return toResponse(findVisible(wallet.getId(), id));
    }

    @Transactional
    public PlannedExpenseResponse update(Long currentUserId, Long id, UpdatePlannedExpenseRequest request) {
        Wallet wallet = findWallet(currentUserId);
        PlannedExpense entity = findVisible(wallet.getId(), id);
        if (!entity.isUpcoming()) {
            throw new PlannedExpenseConflictException("Only upcoming planned expenses can be edited");
        }
        requireVersion(entity, request.version());
        LocalDate dueOn = Objects.requireNonNull(request.dueOn(), "dueOn must not be null");
        requireValidUpdatedDueDate(entity, dueOn);
        Category category = findExpenseCategory(currentUserId, request.categoryId());
        entity.update(
                category,
                normalizeText(request.title(), "Title", 100, true),
                normalizeAmount(request.amount()),
                dueOn,
                request.recurrence(),
                normalizeText(request.note(), "Note", 255, false)
        );
        return toResponse(plannedExpenseRepository.saveAndFlush(entity));
    }

    @Transactional
    public PlannedExpenseResponse cancel(Long currentUserId, Long id, VersionedPlannedExpenseRequest request) {
        Wallet wallet = findWallet(currentUserId);
        PlannedExpense entity = findVisible(wallet.getId(), id);
        requireVersion(entity, request.version());
        if (!entity.isUpcoming()) {
            throw new PlannedExpenseConflictException("Only upcoming planned expenses can be cancelled");
        }
        entity.cancel();
        return toResponse(plannedExpenseRepository.saveAndFlush(entity));
    }

    @Transactional
    public PlannedExpenseResponse markPaid(Long currentUserId, Long id, MarkPlannedExpensePaidRequest request) {
        Wallet wallet = findWallet(currentUserId);
        PlannedExpense entity = findVisible(wallet.getId(), id);

        PlannedExpense paymentRequestOwner = plannedExpenseRepository
                .findByWalletIdAndPaymentClientRequestId(wallet.getId(), request.clientRequestId())
                .orElse(null);
        if (paymentRequestOwner != null && !paymentRequestOwner.getId().equals(entity.getId())) {
            throw new PlannedExpenseConflictException(
                    "Payment request ID was already used for another planned expense");
        }

        if (entity.getStatus() == PlannedExpenseStatus.PAID) {
            if (Objects.equals(entity.getPaymentClientRequestId(), request.clientRequestId())) {
                return toResponse(entity);
            }
            throw new PlannedExpenseConflictException("Planned expense has already been paid");
        }
        if (!entity.isUpcoming()) {
            throw new PlannedExpenseConflictException("Only upcoming planned expenses can be marked as paid");
        }
        requireVersion(entity, request.version());
        if (request.paidOn().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Payment date cannot be in the future");
        }

        UUID transactionRequestId = scopedTransactionRequestId(
                wallet.getId(), entity.getId(), request.clientRequestId());
        TransactionResponse transaction = transactionService.createTransaction(
                currentUserId,
                new CreateTransactionRequest(
                        transactionRequestId,
                        TransactionType.EXPENSE,
                        entity.getAmount(),
                        entity.getCategory().getId(),
                        request.paidOn(),
                        entity.getTitle()
                )
        );
        WalletTransaction transactionEntity = transactionRepository
                .findByIdAndWalletIdAndStatus(
                        transaction.id(), wallet.getId(), TransactionStatus.ACTIVE)
                .orElseThrow(() -> new IllegalStateException("Paid transaction could not be resolved"));

        entity.markPaid(request.paidOn(), transactionEntity, request.clientRequestId());
        PlannedExpenseResponse response = toResponse(plannedExpenseRepository.saveAndFlush(entity));

        if (entity.getRecurrence() != PlannedExpenseRecurrence.NONE) {
            PlannedExpense next = new PlannedExpense(
                    wallet,
                    entity.getCategory(),
                    entity.getTitle(),
                    entity.getAmount(),
                    nextDueDate(entity.getDueOn(), entity.getRecurrence()),
                    entity.getRecurrence(),
                    entity.getNote(),
                    UUID.randomUUID()
            );
            plannedExpenseRepository.save(next);
        }

        return response;
    }

    @Transactional
    public void archive(Long currentUserId, Long id, long version) {
        Wallet wallet = findWallet(currentUserId);
        PlannedExpense entity = findVisible(wallet.getId(), id);
        requireVersion(entity, version);
        if (entity.getStatus() == PlannedExpenseStatus.PAID) {
            throw new PlannedExpenseConflictException("Paid planned expenses are retained for financial history");
        }
        entity.archive();
        plannedExpenseRepository.saveAndFlush(entity);
    }

    private PlannedExpense findVisible(Long walletId, Long id) {
        return plannedExpenseRepository.findByIdAndWalletIdAndStatusNot(id, walletId, PlannedExpenseStatus.ARCHIVED)
                .orElseThrow(PlannedExpenseNotFoundException::new);
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

    private PlannedExpenseResponse resolveIdempotentCreate(
            PlannedExpense existing,
            CreatePlannedExpenseRequest request,
            String title,
            BigDecimal amount,
            LocalDate dueOn,
            PlannedExpenseRecurrence recurrence,
            String note
    ) {
        boolean sameRequest = Objects.equals(existing.getTitle(), title)
                && existing.getAmount().compareTo(amount) == 0
                && Objects.equals(existing.getCategory().getId(), request.categoryId())
                && Objects.equals(existing.getDueOn(), dueOn)
                && existing.getRecurrence() == recurrence
                && Objects.equals(existing.getNote(), note);
        if (!sameRequest) {
            throw new PlannedExpenseConflictException(
                    "Client request ID was already used for another planned expense");
        }
        return toResponse(existing);
    }

    private BigDecimal normalizeAmount(BigDecimal value) {
        if (value == null || value.signum() <= 0) {
            throw new IllegalArgumentException("Amount must be greater than zero");
        }
        if (value.precision() - value.scale() > 17 || value.scale() > 2) {
            throw new IllegalArgumentException("Amount must fit within 17 integer digits and 2 decimal places");
        }
        return value.setScale(2, RoundingMode.UNNECESSARY);
    }

    private String normalizeText(String value, String label, int maxLength, boolean required) {
        if (value == null) {
            if (required) {
                throw new IllegalArgumentException(label + " is required");
            }
            return null;
        }
        String normalized = value.strip().replaceAll("[\\p{Zs}\\s]+", " ");
        if (normalized.isBlank()) {
            if (required) {
                throw new IllegalArgumentException(label + " is required");
            }
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

    private void requireVersion(PlannedExpense entity, long version) {
        if (entity.getVersion() != version) {
            throw new PlannedExpenseConflictException("Planned expense changed. Refresh and try again");
        }
    }

    private UUID scopedTransactionRequestId(Long walletId, Long plannedExpenseId, UUID requestId) {
        String value = "planned-payment:" + walletId + ":" + plannedExpenseId + ":" + requestId;
        return UUID.nameUUIDFromBytes(value.getBytes(StandardCharsets.UTF_8));
    }


    private void requireNotPastDueDate(LocalDate dueOn) {
        if (dueOn.isBefore(LocalDate.now())) {
            throw new IllegalArgumentException("Due date cannot be in the past");
        }
    }

    private void requireValidUpdatedDueDate(PlannedExpense entity, LocalDate dueOn) {
        if (dueOn.isBefore(LocalDate.now()) && !dueOn.equals(entity.getDueOn())) {
            throw new IllegalArgumentException("Due date cannot be in the past");
        }
    }

    private LocalDate nextDueDate(LocalDate dueOn, PlannedExpenseRecurrence recurrence) {
        return switch (recurrence) {
            case WEEKLY -> dueOn.plusWeeks(1);
            case MONTHLY -> dueOn.plusMonths(1);
            case YEARLY -> dueOn.plusYears(1);
            case NONE -> throw new IllegalArgumentException("Non-recurring plans do not have a next date");
        };
    }

    public PlannedExpenseResponse toResponse(PlannedExpense entity) {
        Category category = entity.getCategory();
        return new PlannedExpenseResponse(
                entity.getId(), entity.getVersion(), entity.getTitle(),
                entity.getAmount().setScale(2, RoundingMode.HALF_UP), entity.getDueOn(),
                entity.getRecurrence(), entity.getStatus(), entity.getNote(), entity.getPaidOn(),
                entity.getPaidTransaction() == null ? null : entity.getPaidTransaction().getId(),
                entity.getWallet().getCurrencyCode(),
                new PlannedExpenseCategoryResponse(category.getId(), category.getName(), category.getIconKey())
        );
    }
}
