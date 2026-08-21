package com.smartwallet.backend.plannedexpense.web;

import java.net.URI;

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

import com.smartwallet.backend.plannedexpense.domain.PlannedExpenseStatus;
import com.smartwallet.backend.plannedexpense.dto.request.CreatePlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.dto.request.MarkPlannedExpensePaidRequest;
import com.smartwallet.backend.plannedexpense.dto.request.UpdatePlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.dto.request.VersionedPlannedExpenseRequest;
import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpensePageResponse;
import com.smartwallet.backend.plannedexpense.dto.response.PlannedExpenseResponse;
import com.smartwallet.backend.plannedexpense.service.PlannedExpenseService;
import com.smartwallet.backend.user.domain.User;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/planned-expenses")
@RequiredArgsConstructor
@Validated
@SecurityRequirement(name = "bearerAuth")
public class PlannedExpenseController {

    private final PlannedExpenseService service;

    @PostMapping
    public ResponseEntity<PlannedExpenseResponse> create(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreatePlannedExpenseRequest request
    ) {
        PlannedExpenseResponse response = service.create(currentUser.getId(), request);
        return ResponseEntity.created(URI.create("/api/v1/planned-expenses/" + response.id())).body(response);
    }

    @GetMapping
    public ResponseEntity<PlannedExpensePageResponse> list(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(defaultValue = "UPCOMING") PlannedExpenseStatus status,
            @RequestParam(defaultValue = "0") @Min(0) int page,
            @RequestParam(defaultValue = "20") @Min(1) @Max(50) int size
    ) {
        return ResponseEntity.ok(service.list(currentUser.getId(), status, page, size));
    }

    @GetMapping("/{plannedExpenseId}")
    public ResponseEntity<PlannedExpenseResponse> get(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long plannedExpenseId
    ) {
        return ResponseEntity.ok(service.get(currentUser.getId(), plannedExpenseId));
    }

    @PatchMapping("/{plannedExpenseId}")
    public ResponseEntity<PlannedExpenseResponse> update(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long plannedExpenseId,
            @Valid @RequestBody UpdatePlannedExpenseRequest request
    ) {
        return ResponseEntity.ok(service.update(currentUser.getId(), plannedExpenseId, request));
    }

    @PostMapping("/{plannedExpenseId}/cancel")
    public ResponseEntity<PlannedExpenseResponse> cancel(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long plannedExpenseId,
            @Valid @RequestBody VersionedPlannedExpenseRequest request
    ) {
        return ResponseEntity.ok(service.cancel(currentUser.getId(), plannedExpenseId, request));
    }

    @PostMapping("/{plannedExpenseId}/mark-paid")
    public ResponseEntity<PlannedExpenseResponse> markPaid(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long plannedExpenseId,
            @Valid @RequestBody MarkPlannedExpensePaidRequest request
    ) {
        return ResponseEntity.ok(service.markPaid(currentUser.getId(), plannedExpenseId, request));
    }

    @DeleteMapping("/{plannedExpenseId}")
    public ResponseEntity<Void> archive(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long plannedExpenseId,
            @RequestParam @Min(0) long version
    ) {
        service.archive(currentUser.getId(), plannedExpenseId, version);
        return ResponseEntity.noContent().build();
    }
}
