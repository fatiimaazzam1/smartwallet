package com.smartwallet.backend.transaction.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.category.domain.CategoryStatus;
import com.smartwallet.backend.category.domain.CategoryType;
import com.smartwallet.backend.category.exception.CategoryNotFoundException;
import com.smartwallet.backend.category.repository.CategoryRepository;
import com.smartwallet.backend.transaction.domain.TransactionStatus;
import com.smartwallet.backend.transaction.domain.TransactionType;
import com.smartwallet.backend.transaction.domain.WalletTransaction;
import com.smartwallet.backend.transaction.dto.request.CreateTransactionRequest;
import com.smartwallet.backend.transaction.dto.request.UpdateTransactionRequest;
import com.smartwallet.backend.transaction.dto.response.TransactionPageResponse;
import com.smartwallet.backend.transaction.dto.response.TransactionResponse;
import com.smartwallet.backend.transaction.exception.TransactionConflictException;
import com.smartwallet.backend.transaction.exception.TransactionNotFoundException;
import com.smartwallet.backend.transaction.repository.TransactionRepository;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.exception.WalletNotFoundException;
import com.smartwallet.backend.wallet.repository.WalletRepository;

@ExtendWith(MockitoExtension.class)
class TransactionServiceTest {

    @Mock
    private TransactionRepository transactionRepository;

    @Mock
    private WalletRepository walletRepository;

    @Mock
    private CategoryRepository categoryRepository;

    private TransactionService transactionService;

    @BeforeEach
    void setUp() {
        transactionService = new TransactionService(
                transactionRepository,
                walletRepository,
                categoryRepository
        );
    }

    @Test
    void createTransactionNormalizesAndPersistsExpense() {
        Wallet wallet = wallet(10L, "USD");
        Category category = category(
                5L,
                "Food",
                "food",
                CategoryType.EXPENSE,
                CategoryStatus.ACTIVE
        );
        UUID requestId = UUID.randomUUID();

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByWalletIdAndClientRequestId(
                10L,
                requestId
        )).thenReturn(Optional.empty());
        when(categoryRepository.findVisibleCategoryById(5L, 1L))
                .thenReturn(Optional.of(category));
        when(transactionRepository.saveAndFlush(any(WalletTransaction.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        TransactionResponse response = transactionService.createTransaction(
                1L,
                new CreateTransactionRequest(
                        requestId,
                        TransactionType.EXPENSE,
                        new BigDecimal("25.5"),
                        5L,
                        LocalDate.now(),
                        "  Lunch   with friends  "
                )
        );

        ArgumentCaptor<WalletTransaction> captor =
                ArgumentCaptor.forClass(WalletTransaction.class);
        verify(transactionRepository).saveAndFlush(captor.capture());
        WalletTransaction saved = captor.getValue();

        assertThat(saved.getWallet()).isSameAs(wallet);
        assertThat(saved.getCategory()).isSameAs(category);
        assertThat(saved.getType()).isEqualTo(TransactionType.EXPENSE);
        assertThat(saved.getAmount()).isEqualByComparingTo("25.50");
        assertThat(saved.getDescription()).isEqualTo("Lunch with friends");
        assertThat(saved.getOccurredOn()).isEqualTo(LocalDate.now());
        assertThat(saved.getClientRequestId()).isEqualTo(requestId);
        assertThat(saved.isActive()).isTrue();

        assertThat(response.amount()).isEqualByComparingTo("25.50");
        assertThat(response.description()).isEqualTo("Lunch with friends");
        assertThat(response.currencyCode()).isEqualTo("USD");
        assertThat(response.status()).isEqualTo("RECORDED");
    }

    @Test
    void createTransactionReturnsExistingRecordForIdenticalRequestId() {
        Wallet wallet = wallet(10L, "USD");
        Category category = category(
                5L,
                "Food",
                "food",
                CategoryType.EXPENSE,
                CategoryStatus.ACTIVE
        );
        UUID requestId = UUID.randomUUID();
        WalletTransaction existing = transaction(
                wallet,
                category,
                TransactionType.EXPENSE,
                "25.50",
                "Lunch",
                LocalDate.now(),
                requestId
        );

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByWalletIdAndClientRequestId(
                10L,
                requestId
        )).thenReturn(Optional.of(existing));

        TransactionResponse response = transactionService.createTransaction(
                1L,
                new CreateTransactionRequest(
                        requestId,
                        TransactionType.EXPENSE,
                        new BigDecimal("25.50"),
                        5L,
                        LocalDate.now(),
                        "Lunch"
                )
        );

        assertThat(response.amount()).isEqualByComparingTo("25.50");
        verify(transactionRepository, never())
                .saveAndFlush(any(WalletTransaction.class));
        verify(categoryRepository, never())
                .findVisibleCategoryById(any(), any());
    }

    @Test
    void createTransactionRejectsReusedRequestIdWithDifferentPayload() {
        Wallet wallet = wallet(10L, "USD");
        Category category = category(
                5L,
                "Food",
                "food",
                CategoryType.EXPENSE,
                CategoryStatus.ACTIVE
        );
        UUID requestId = UUID.randomUUID();
        WalletTransaction existing = transaction(
                wallet,
                category,
                TransactionType.EXPENSE,
                "25.50",
                "Lunch",
                LocalDate.now(),
                requestId
        );

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByWalletIdAndClientRequestId(
                10L,
                requestId
        )).thenReturn(Optional.of(existing));

        assertThatThrownBy(() -> transactionService.createTransaction(
                1L,
                new CreateTransactionRequest(
                        requestId,
                        TransactionType.EXPENSE,
                        new BigDecimal("30.00"),
                        5L,
                        LocalDate.now(),
                        "Lunch"
                )
        ))
                .isInstanceOf(TransactionConflictException.class)
                .hasMessageContaining("already been used");
    }

    @Test
    void createTransactionRejectsCategoryTypeMismatch() {
        Wallet wallet = wallet(10L, "USD");
        Category salary = category(
                1L,
                "Salary",
                "salary",
                CategoryType.INCOME,
                CategoryStatus.ACTIVE
        );
        UUID requestId = UUID.randomUUID();

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByWalletIdAndClientRequestId(
                10L,
                requestId
        )).thenReturn(Optional.empty());
        when(categoryRepository.findVisibleCategoryById(1L, 1L))
                .thenReturn(Optional.of(salary));

        assertThatThrownBy(() -> transactionService.createTransaction(
                1L,
                new CreateTransactionRequest(
                        requestId,
                        TransactionType.EXPENSE,
                        new BigDecimal("10.00"),
                        1L,
                        LocalDate.now(),
                        null
                )
        ))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Category type must match transaction type");
    }

    @Test
    void createTransactionHidesArchivedOrForeignCategory() {
        Wallet wallet = wallet(10L, "USD");
        Category archived = category(
                5L,
                "Old Food",
                "custom",
                CategoryType.EXPENSE,
                CategoryStatus.ARCHIVED
        );
        UUID requestId = UUID.randomUUID();

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByWalletIdAndClientRequestId(
                10L,
                requestId
        )).thenReturn(Optional.empty());
        when(categoryRepository.findVisibleCategoryById(5L, 1L))
                .thenReturn(Optional.of(archived));

        assertThatThrownBy(() -> transactionService.createTransaction(
                1L,
                new CreateTransactionRequest(
                        requestId,
                        TransactionType.EXPENSE,
                        new BigDecimal("10.00"),
                        5L,
                        LocalDate.now(),
                        null
                )
        )).isInstanceOf(CategoryNotFoundException.class);
    }

    @Test
    void createTransactionRejectsFutureDate() {
        Wallet wallet = wallet(10L, "USD");
        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));

        assertThatThrownBy(() -> transactionService.createTransaction(
                1L,
                new CreateTransactionRequest(
                        UUID.randomUUID(),
                        TransactionType.INCOME,
                        new BigDecimal("100.00"),
                        1L,
                        LocalDate.now().plusDays(1),
                        null
                )
        ))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("future");
    }

    @Test
    void getTransactionReturnsGenericNotFoundOutsideCurrentWallet() {
        Wallet wallet = wallet(10L, "USD");
        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByIdAndWalletIdAndStatus(
                99L,
                10L,
                TransactionStatus.ACTIVE
        )).thenReturn(Optional.empty());

        assertThatThrownBy(() ->
                transactionService.getTransaction(1L, 99L)
        ).isInstanceOf(TransactionNotFoundException.class);
    }

    @Test
    void getTransactionsUsesStablePagingAndFilters() {
        Wallet wallet = wallet(10L, "USD");
        Category category = category(
                5L,
                "Food",
                "food",
                CategoryType.EXPENSE,
                CategoryStatus.ACTIVE
        );
        WalletTransaction transaction = transaction(
                wallet,
                category,
                TransactionType.EXPENSE,
                "20.00",
                "Groceries",
                LocalDate.of(2026, 8, 5),
                UUID.randomUUID()
        );

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findHistory(
                eq(10L),
                eq(TransactionStatus.ACTIVE),
                eq(TransactionType.EXPENSE),
                eq(5L),
                eq(LocalDate.of(2026, 8, 1)),
                eq(LocalDate.of(2026, 8, 31)),
                eq("%groceries%"),
                any(Pageable.class)
        )).thenReturn(new PageImpl<>(
                List.of(transaction),
                PageRequest.of(0, 20),
                1
        ));

        TransactionPageResponse response = transactionService.getTransactions(
                1L,
                TransactionType.EXPENSE,
                5L,
                LocalDate.of(2026, 8, 1),
                LocalDate.of(2026, 8, 31),
                " Groceries ",
                0,
                20
        );

        assertThat(response.content()).hasSize(1);
        assertThat(response.totalElements()).isEqualTo(1);
        assertThat(response.first()).isTrue();
        assertThat(response.last()).isTrue();
    }

    @Test
    void getTransactionsEscapesLikeWildcards() {
        Wallet wallet = wallet(10L, "USD");
        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findHistory(
                eq(10L),
                eq(TransactionStatus.ACTIVE),
                eq(null),
                eq(null),
                eq(null),
                eq(null),
                eq("%!%!_!!%"),
                any(Pageable.class)
        )).thenReturn(new PageImpl<>(List.of()));

        transactionService.getTransactions(
                1L,
                null,
                null,
                null,
                null,
                "%_!",
                0,
                20
        );

        verify(transactionRepository).findHistory(
                eq(10L),
                eq(TransactionStatus.ACTIVE),
                eq(null),
                eq(null),
                eq(null),
                eq(null),
                eq("%!%!_!!%"),
                any(Pageable.class)
        );
    }

    @Test
    void getTransactionsRejectsInvalidDateRange() {
        assertThatThrownBy(() -> transactionService.getTransactions(
                1L,
                null,
                null,
                LocalDate.of(2026, 8, 31),
                LocalDate.of(2026, 8, 1),
                null,
                0,
                20
        ))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Start date");

        verify(walletRepository, never()).findByUserId(any());
    }

    @Test
    void updateTransactionRejectsStaleVersion() {
        Wallet wallet = wallet(10L, "USD");
        WalletTransaction transaction = mock(WalletTransaction.class);

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByIdAndWalletIdAndStatus(
                20L,
                10L,
                TransactionStatus.ACTIVE
        )).thenReturn(Optional.of(transaction));
        when(transaction.getVersion()).thenReturn(2L);

        assertThatThrownBy(() -> transactionService.updateTransaction(
                1L,
                20L,
                new UpdateTransactionRequest(
                        1L,
                        new BigDecimal("50.00"),
                        5L,
                        LocalDate.now(),
                        null
                )
        ))
                .isInstanceOf(TransactionConflictException.class)
                .hasMessageContaining("Refresh");
    }

    @Test
    void updateTransactionAllowsKeepingArchivedHistoricalCategory() {
        Wallet wallet = wallet(10L, "USD");
        Category archived = category(
                5L,
                "Old Food",
                "custom",
                CategoryType.EXPENSE,
                CategoryStatus.ARCHIVED
        );
        WalletTransaction transaction = mock(WalletTransaction.class);

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByIdAndWalletIdAndStatus(
                20L,
                10L,
                TransactionStatus.ACTIVE
        )).thenReturn(Optional.of(transaction));
        when(transaction.getVersion()).thenReturn(0L);
        when(transaction.getCategory()).thenReturn(archived);
        when(transaction.getType()).thenReturn(TransactionType.EXPENSE);
        when(categoryRepository.findVisibleCategoryById(5L, 1L))
                .thenReturn(Optional.of(archived));
        when(transactionRepository.saveAndFlush(transaction))
                .thenReturn(transaction);
        stubTransactionForResponse(
                transaction,
                wallet,
                archived,
                TransactionType.EXPENSE,
                "30.00",
                "Updated",
                LocalDate.now()
        );

        TransactionResponse response = transactionService.updateTransaction(
                1L,
                20L,
                new UpdateTransactionRequest(
                        0L,
                        new BigDecimal("30.00"),
                        5L,
                        LocalDate.now(),
                        " Updated "
                )
        );

        verify(transaction).update(
                archived,
                new BigDecimal("30.00"),
                "Updated",
                LocalDate.now()
        );
        assertThat(response.category().id()).isEqualTo(5L);
    }

    @Test
    void archiveTransactionSoftDeletesOwnedActiveRecord() {
        Wallet wallet = wallet(10L, "USD");
        WalletTransaction transaction = mock(WalletTransaction.class);

        when(walletRepository.findByUserId(1L))
                .thenReturn(Optional.of(wallet));
        when(transactionRepository.findByIdAndWalletIdAndStatus(
                20L,
                10L,
                TransactionStatus.ACTIVE
        )).thenReturn(Optional.of(transaction));
        when(transactionRepository.saveAndFlush(transaction))
                .thenReturn(transaction);

        transactionService.archiveTransaction(1L, 20L);

        verify(transaction).archive();
        verify(transactionRepository).saveAndFlush(transaction);
    }

    @Test
    void operationsRejectMissingCurrentUserWallet() {
        when(walletRepository.findByUserId(99L))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() ->
                transactionService.getTransaction(99L, 1L)
        ).isInstanceOf(WalletNotFoundException.class);
    }

    private Wallet wallet(Long id, String currencyCode) {
        Wallet wallet = mock(Wallet.class);
        lenient().when(wallet.getId()).thenReturn(id);
        lenient().when(wallet.getCurrencyCode()).thenReturn(currencyCode);
        return wallet;
    }

    private Category category(
            Long id,
            String name,
            String iconKey,
            CategoryType type,
            CategoryStatus status
    ) {
        Category category = mock(Category.class);
        lenient().when(category.getId()).thenReturn(id);
        lenient().when(category.getName()).thenReturn(name);
        lenient().when(category.getIconKey()).thenReturn(iconKey);
        lenient().when(category.getType()).thenReturn(type);
        lenient().when(category.getStatus()).thenReturn(status);
        return category;
    }

    private WalletTransaction transaction(
            Wallet wallet,
            Category category,
            TransactionType type,
            String amount,
            String description,
            LocalDate occurredOn,
            UUID requestId
    ) {
        return new WalletTransaction(
                wallet,
                category,
                type,
                new BigDecimal(amount),
                description,
                occurredOn,
                requestId
        );
    }

    private void stubTransactionForResponse(
            WalletTransaction transaction,
            Wallet wallet,
            Category category,
            TransactionType type,
            String amount,
            String description,
            LocalDate occurredOn
    ) {
        when(transaction.getWallet()).thenReturn(wallet);
        when(transaction.getCategory()).thenReturn(category);
        when(transaction.getType()).thenReturn(type);
        when(transaction.getAmount()).thenReturn(new BigDecimal(amount));
        when(transaction.getDescription()).thenReturn(description);
        when(transaction.getOccurredOn()).thenReturn(occurredOn);
    }
}
