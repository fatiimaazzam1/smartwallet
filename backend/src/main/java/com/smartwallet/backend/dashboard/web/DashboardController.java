package com.smartwallet.backend.dashboard.web;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartwallet.backend.dashboard.dto.response.DashboardResponse;
import com.smartwallet.backend.dashboard.service.DashboardService;
import com.smartwallet.backend.user.domain.User;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class DashboardController {
    private final DashboardService dashboardService;

    @GetMapping
    public ResponseEntity<DashboardResponse> get(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(dashboardService.get(currentUser.getId()));
    }
}
