package com.smartwallet.backend.transaction.service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.Locale;
import java.util.Objects;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.category.domain.CategoryStatus;
import com.smartwallet.backend.category.exception.CategoryNotFoundException;
import com.smartwallet.backend.category.repository.CategoryRepository;
import com.smartwallet.backend.transaction.domain.TransactionStatus;
import com.smartwallet.backend.transaction.domain.TransactionType;
import com.smartwallet.backend.transaction.domain.WalletTransaction;
import com.smartwallet.backend.transaction.dto.request.CreateTransactionRequest;
import com.smartwallet.backend.transaction.dto.request.UpdateTransactionRequest;
import com.smartwallet.backend.transaction.dto.response.TransactionCategoryResponse;
import com.smartwallet.backend.transaction.dto.response.TransactionPageResponse;
import com.smartwallet.backend.transaction.dto.response.TransactionResponse;
import com.smartwallet.backend.transaction.exception.TransactionConflictException;
import com.smartwallet.backend.transaction.exception.TransactionNotFoundException;
import com.smartwallet.backend.transaction.repository.TransactionRepository;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.exception.WalletNotFoundException;
import com.smartwallet.backend.wallet.repository.WalletRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class TransactionService {

    private static final int MAX_PAGE_SIZE = 50;
    private static final String RECORDED_STATUS = "RECORDED";

    private final TransactionRepository transactionRepository;
    private final WalletRepository walletRepository;
    private final CategoryRepository categoryRepository;

    @Transactional
    public TransactionResponse createTransaction(
            Long currentUserId,
            CreateTransactionRequest request
    ) {
        Wallet wallet = findCurrentUserWallet(currentUserId);
        BigDecimal amount = normalizeAmount(request.amount());
        String description = normalizeDescription(request.description());
        validateOccurredOn(request.occurredOn());

        WalletTransaction existing = transactionRepository
                .findByWalletIdAndClientRequestId(
                        wallet.getId(),
                        request.clientRequestId()
                )
                .orElse(null);

        if (existing != null) {
            return resolveIdempotentCreate(
                    existing,
                    request,
                    amount,
                    description
            );
        }

        Category category = findUsableCategory(
                currentUserId,
                request.categoryId(),
                request.type(),
                true
        );

        WalletTransaction transaction = new WalletTransaction(
                wallet,
                category,
                request.type(),
                amount,
                description,
                request.occurredOn(),
                request.clientRequestId()
        );

        try {
            return toResponse(
                    transactionRepository.saveAndFlush(transaction)
            );
        } catch (DataIntegrityViolationException exception) {
            WalletTransaction concurrent = transactionRepository
                    .findByWalletIdAndClientRequestId(
                            wallet.getId(),
                            request.clientRequestId()
                    )
                    .orElseThrow(() -> exception);

            return resolveIdempotentCreate(
                    concurrent,
                    request,
                    amount,
                    description
            );
        }
    }

    @Transactional(readOnly = true)
    public TransactionResponse getTransaction(
            Long currentUserId,
            Long transactionId
    ) {
        Wallet wallet = findCurrentUserWallet(currentUserId);
        return toResponse(findActiveTransaction(wallet.getId(), transactionId));
    }

    @Transactional(readOnly = true)
    public TransactionPageResponse getTransactions(
            Long currentUserId,
            TransactionType type,
            Long categoryId,
            LocalDate startDate,
            LocalDate endDate,
            String query,
            int page,
            int size
    ) {
        validatePage(page, size);
        validateDateRange(startDate, endDate);

        Wallet wallet = findCurrentUserWallet(currentUserId);
        PageRequest pageRequest = PageRequest.of(
                page,
                size,
                Sort.by(
                        Sort.Order.desc("occurredOn"),
                        Sort.Order.desc("id")
                )
        );

        Page<WalletTransaction> result = transactionRepository.findHistory(
                wallet.getId(),
                TransactionStatus.ACTIVE,
                type,
                categoryId,
                startDate,
                endDate,
                toSearchPattern(query),
                pageRequest
        );

        return new TransactionPageResponse(
                result.getContent().stream().map(this::toResponse).toList(),
                result.getNumber(),
                result.getSize(),
                result.getTotalElements(),
                result.getTotalPages(),
                result.isFirst(),
                result.isLast()
        );
    }

    @Transactional
    public TransactionResponse updateTransaction(
            Long currentUserId,
            Long transactionId,
            UpdateTransactionRequest request
    ) {
        Wallet wallet = findCurrentUserWallet(currentUserId);
        WalletTransaction transaction = findActiveTransaction(
                wallet.getId(),
                transactionId
        );

        if (transaction.getVersion() != request.version()) {
            throw new TransactionConflictException(
                    "Transaction changed. Refresh and try again"
            );
        }

        validateOccurredOn(request.occurredOn());
        BigDecimal amount = normalizeAmount(request.amount());
        String description = normalizeDescription(request.description());

        boolean categoryUnchanged = Objects.equals(
                transaction.getCategory().getId(),
                request.categoryId()
        );

        Category category = findUsableCategory(
                currentUserId,
                request.categoryId(),
                transaction.getType(),
                !categoryUnchanged
        );

        transaction.update(
                category,
                amount,
                description,
                request.occurredOn()
        );

        return toResponse(transactionRepository.saveAndFlush(transaction));
    }

    @Transactional
    public void archiveTransaction(
            Long currentUserId,
            Long transactionId
    ) {
        Wallet wallet = findCurrentUserWallet(currentUserId);
        WalletTransaction transaction = findActiveTransaction(
                wallet.getId(),
                transactionId
        );
        transaction.archive();
        transactionRepository.saveAndFlush(transaction);
    }

    private Wallet findCurrentUserWallet(Long currentUserId) {
        return walletRepository.findByUserId(currentUserId)
                .orElseThrow(WalletNotFoundException::new);
    }

    private WalletTransaction findActiveTransaction(
            Long walletId,
            Long transactionId
    ) {
        return transactionRepository.findByIdAndWalletIdAndStatus(
                        transactionId,
                        walletId,
                        TransactionStatus.ACTIVE
                )
                .orElseThrow(TransactionNotFoundException::new);
    }

    private Category findUsableCategory(
            Long currentUserId,
            Long categoryId,
            TransactionType transactionType,
            boolean requireActive
    ) {
        Category category = categoryRepository.findVisibleCategoryById(
                        categoryId,
                        currentUserId
                )
                .orElseThrow(CategoryNotFoundException::new);

        if (requireActive && category.getStatus() != CategoryStatus.ACTIVE) {
            throw new CategoryNotFoundException();
        }

        if (!transactionType.matches(category.getType())) {
            throw new IllegalArgumentException(
                    "Category type must match transaction type"
            );
        }

        return category;
    }

    private TransactionResponse resolveIdempotentCreate(
            WalletTransaction existing,
            CreateTransactionRequest request,
            BigDecimal normalizedAmount,
            String normalizedDescription
    ) {
        boolean sameRequest = existing.isActive()
                && existing.getType() == request.type()
                && existing.getAmount().compareTo(normalizedAmount) == 0
                && Objects.equals(
                        existing.getCategory().getId(),
                        request.categoryId()
                )
                && Objects.equals(
                        existing.getOccurredOn(),
                        request.occurredOn()
                )
                && Objects.equals(
                        existing.getDescription(),
                        normalizedDescription
                );

        if (!sameRequest) {
            throw new TransactionConflictException(
                    "Client request ID has already been used"
            );
        }

        return toResponse(existing);
    }

    private void validatePage(int page, int size) {
        if (page < 0) {
            throw new IllegalArgumentException("Page must be zero or greater");
        }
        if (size < 1 || size > MAX_PAGE_SIZE) {
            throw new IllegalArgumentException(
                    "Page size must be between 1 and " + MAX_PAGE_SIZE
            );
        }
    }

    private void validateDateRange(
            LocalDate startDate,
            LocalDate endDate
    ) {
        if (startDate != null
                && endDate != null
                && startDate.isAfter(endDate)) {
            throw new IllegalArgumentException(
                    "Start date cannot be after end date"
            );
        }
    }

    private void validateOccurredOn(LocalDate occurredOn) {
        if (occurredOn == null) {
            throw new IllegalArgumentException("Transaction date is required");
        }
        if (occurredOn.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException(
                    "Transaction date cannot be in the future"
            );
        }
    }

    private BigDecimal normalizeAmount(BigDecimal value) {
        if (value == null) {
            throw new IllegalArgumentException("Amount is required");
        }
        if (value.signum() <= 0) {
            throw new IllegalArgumentException("Amount must be greater than zero");
        }
        if (value.precision() - value.scale() > 17 || value.scale() > 2) {
            throw new IllegalArgumentException(
                    "Amount must fit within 17 integer digits and 2 decimal places"
            );
        }
        return value.setScale(2, RoundingMode.UNNECESSARY);
    }

    private String normalizeDescription(String value) {
        if (value == null) {
            return null;
        }

        String normalized = value
                .strip()
                .replaceAll("[\\p{Zs}\\s]+", " ");

        if (normalized.isBlank()) {
            return null;
        }
        if (normalized.length() > 255) {
            throw new IllegalArgumentException(
                    "Description must not exceed 255 characters"
            );
        }
        if (normalized.codePoints().anyMatch(codePoint ->
                Character.isISOControl(codePoint)
                        || Character.getType(codePoint)
                        == Character.FORMAT
        )) {
            throw new IllegalArgumentException(
                    "Description contains unsupported characters"
            );
        }

        return normalized;
    }

    private String toSearchPattern(String query) {
        if (query == null) {
            return null;
        }

        String normalized = query
                .strip()
                .replaceAll("[\\p{Zs}\\s]+", " ")
                .toLowerCase(Locale.ROOT);

        if (normalized.isBlank()) {
            return null;
        }
        if (normalized.length() > 100) {
            throw new IllegalArgumentException(
                    "Search query must not exceed 100 characters"
            );
        }

        String escaped = normalized
                .replace("!", "!!")
                .replace("%", "!%")
                .replace("_", "!_");

        return "%" + escaped + "%";
    }

    private TransactionResponse toResponse(WalletTransaction transaction) {
        Category category = transaction.getCategory();

        return new TransactionResponse(
                transaction.getId(),
                transaction.getVersion(),
                transaction.getType(),
                transaction.getAmount().setScale(2, RoundingMode.HALF_UP),
                transaction.getDescription(),
                transaction.getOccurredOn(),
                transaction.getWallet().getCurrencyCode(),
                RECORDED_STATUS,
                new TransactionCategoryResponse(
                        category.getId(),
                        category.getName(),
                        category.getIconKey()
                )
        );
    }
}
