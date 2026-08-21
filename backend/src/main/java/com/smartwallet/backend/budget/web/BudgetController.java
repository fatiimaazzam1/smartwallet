package com.smartwallet.backend.budget.web;

import java.net.URI;
import java.time.LocalDate;
import java.util.List;

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

import com.smartwallet.backend.budget.dto.request.CreateBudgetRequest;
import com.smartwallet.backend.budget.dto.request.UpdateBudgetRequest;
import com.smartwallet.backend.budget.dto.response.BudgetMonthResponse;
import com.smartwallet.backend.budget.dto.response.BudgetRelatedExpenseResponse;
import com.smartwallet.backend.budget.dto.response.BudgetResponse;
import com.smartwallet.backend.budget.service.BudgetService;
import com.smartwallet.backend.user.domain.User;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/budgets")
@RequiredArgsConstructor
@Validated
@SecurityRequirement(name = "bearerAuth")
public class BudgetController {

    private final BudgetService budgetService;

    @PostMapping
    @Operation(summary = "Create a monthly expense-category budget")
    public ResponseEntity<BudgetResponse> create(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateBudgetRequest request
    ) {
        BudgetResponse response = budgetService.create(currentUser.getId(), request);
        return ResponseEntity.created(URI.create("/api/v1/budgets/" + response.id())).body(response);
    }

    @GetMapping
    @Operation(summary = "List active budgets for a month")
    public ResponseEntity<BudgetMonthResponse> list(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate month
    ) {
        return ResponseEntity.ok(budgetService.listMonth(currentUser.getId(), month));
    }

    @GetMapping("/{budgetId}")
    public ResponseEntity<BudgetResponse> get(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long budgetId
    ) {
        return ResponseEntity.ok(budgetService.get(currentUser.getId(), budgetId));
    }

    @GetMapping("/{budgetId}/expenses")
    @Operation(summary = "List recent active expenses counted by a budget")
    public ResponseEntity<List<BudgetRelatedExpenseResponse>> relatedExpenses(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long budgetId,
            @RequestParam(defaultValue = "5") @Min(1) @jakarta.validation.constraints.Max(20) int size
    ) {
        return ResponseEntity.ok(budgetService.relatedExpenses(currentUser.getId(), budgetId, size));
    }

    @PatchMapping("/{budgetId}")
    public ResponseEntity<BudgetResponse> update(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long budgetId,
            @Valid @RequestBody UpdateBudgetRequest request
    ) {
        return ResponseEntity.ok(budgetService.update(currentUser.getId(), budgetId, request));
    }

    @DeleteMapping("/{budgetId}")
    public ResponseEntity<Void> archive(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long budgetId,
            @RequestParam @Min(0) long version
    ) {
        budgetService.archive(currentUser.getId(), budgetId, version);
        return ResponseEntity.noContent().build();
    }
}
