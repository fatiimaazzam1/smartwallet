package com.smartwallet.backend.transaction.web;

import java.net.URI;
import java.time.LocalDate;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartwallet.backend.transaction.domain.TransactionType;
import com.smartwallet.backend.transaction.dto.request.CreateTransactionRequest;
import com.smartwallet.backend.transaction.dto.request.UpdateTransactionRequest;
import com.smartwallet.backend.transaction.dto.response.TransactionPageResponse;
import com.smartwallet.backend.transaction.dto.response.TransactionResponse;
import com.smartwallet.backend.transaction.service.TransactionService;
import com.smartwallet.backend.user.domain.User;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
@Validated
@SecurityRequirement(name = "bearerAuth")
public class TransactionController {

    private final TransactionService transactionService;

    @PostMapping
    @Operation(summary = "Create an income or expense transaction")
    public ResponseEntity<TransactionResponse> createTransaction(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateTransactionRequest request
    ) {
        TransactionResponse response = transactionService.createTransaction(
                currentUser.getId(),
                request
        );

        return ResponseEntity
                .created(URI.create("/api/v1/transactions/" + response.id()))
                .body(response);
    }

    @GetMapping
    @Operation(summary = "List the authenticated user's transactions")
    public ResponseEntity<TransactionPageResponse> getTransactions(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) TransactionType type,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate startDate,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate endDate,
            @RequestParam(required = false)
            @Size(max = 100, message = "query must not exceed 100 characters")
            String query,
            @RequestParam(defaultValue = "0")
            @Min(value = 0, message = "page must be zero or greater")
            int page,
            @RequestParam(defaultValue = "20")
            @Min(value = 1, message = "size must be at least 1")
            @Max(value = 50, message = "size must not exceed 50")
            int size
    ) {
        return ResponseEntity.ok(
                transactionService.getTransactions(
                        currentUser.getId(),
                        type,
                        categoryId,
                        startDate,
                        endDate,
                        query,
                        page,
                        size
                )
        );
    }

    @GetMapping("/{transactionId}")
    @Operation(summary = "Get one transaction")
    public ResponseEntity<TransactionResponse> getTransaction(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long transactionId
    ) {
        return ResponseEntity.ok(
                transactionService.getTransaction(
                        currentUser.getId(),
                        transactionId
                )
        );
    }

    @PatchMapping("/{transactionId}")
    @Operation(summary = "Edit a transaction")
    public ResponseEntity<TransactionResponse> updateTransaction(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long transactionId,
            @Valid @RequestBody UpdateTransactionRequest request
    ) {
        return ResponseEntity.ok(
                transactionService.updateTransaction(
                        currentUser.getId(),
                        transactionId,
                        request
                )
        );
    }

    @DeleteMapping("/{transactionId}")
    @Operation(summary = "Archive a transaction")
    public ResponseEntity<Void> archiveTransaction(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long transactionId
    ) {
        transactionService.archiveTransaction(
                currentUser.getId(),
                transactionId
        );
        return ResponseEntity.noContent().build();
    }
}
