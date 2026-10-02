package com.smartwallet.backend.plannedexpense.service;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.smartwallet.backend.category.repository.CategoryRepository;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpense;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseRecurrence;
import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;
import com.smartwallet.backend.plannedexpense.dto.request.CreatePlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.dto.request.UpdatePlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.repository.PlannedExpenseRepository;
import com.smartwallet.backend.transaction.repository.TransactionRepository;
import com.smartwallet.backend.transaction.service.TransactionService;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.repository.WalletRepository;

@ExtendWith(MockitoExtension.class)
class PlannedExpenseServiceTest {

    @Mock
    private PlannedExpenseRepository plannedExpenseRepository;
    @Mock
    private WalletRepository walletRepository;
    @Mock
    private CategoryRepository categoryRepository;
    @Mock
    private TransactionService transactionService;
    @Mock
    private TransactionRepository transactionRepository;

    private PlannedExpenseService service;

    @BeforeEach
    void setUp() {
        service = new PlannedExpenseService(
                plannedExpenseRepository,
                walletRepository,
                categoryRepository,
                transactionService,
                transactionRepository
        );
    }

    @Test
    void createRejectsNewPlannedExpenseWithPastDueDate() {
        Wallet wallet = mock(Wallet.class);
        UUID requestId = UUID.randomUUID();
        when(wallet.getId()).thenReturn(10L);
        when(walletRepository.findByUserId(1L)).thenReturn(Optional.of(wallet));
        when(plannedExpenseRepository.findByWalletIdAndCreateClientRequestId(10L, requestId))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.create(
                1L,
                new CreatePlannedExpenseRequest(
                        requestId,
                        "Electricity",
                        new BigDecimal("80.00"),
                        5L,
                        LocalDate.now().minusDays(1),
                        PlannedExpenseRecurrence.NONE,
                        null
                )
        ))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Due date cannot be in the past");

        verify(categoryRepository, never()).findVisibleCategoryById(any(), any());
        verify(plannedExpenseRepository, never()).saveAndFlush(any(PlannedExpense.class));
    }

    @Test
    void updateRejectsChangingUpcomingPlanToAnotherPastDate() {
        Wallet wallet = mock(Wallet.class);
        PlannedExpense entity = mock(PlannedExpense.class);
        when(wallet.getId()).thenReturn(10L);
        when(walletRepository.findByUserId(1L)).thenReturn(Optional.of(wallet));
        when(plannedExpenseRepository.findByIdAndWalletIdAndStatusNot(
                20L, 10L, PlannedExpenseStatus.ARCHIVED
        )).thenReturn(Optional.of(entity));
        when(entity.isUpcoming()).thenReturn(true);
        when(entity.getVersion()).thenReturn(0L);
        when(entity.getDueOn()).thenReturn(LocalDate.now().minusDays(1));

        assertThatThrownBy(() -> service.update(
                1L,
                20L,
                new UpdatePlannedExpenseRequest(
                        0L,
                        "Electricity",
                        new BigDecimal("80.00"),
                        5L,
                        LocalDate.now().minusDays(2),
                        PlannedExpenseRecurrence.NONE,
                        null
                )
        ))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Due date cannot be in the past");

        verify(categoryRepository, never()).findVisibleCategoryById(any(), any());
        verify(plannedExpenseRepository, never()).saveAndFlush(any(PlannedExpense.class));
    }
}
