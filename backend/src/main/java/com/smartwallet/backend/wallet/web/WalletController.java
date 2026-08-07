package com.smartwallet.backend.wallet.web;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.wallet.dto.response.CurrentWalletResponse;
import com.smartwallet.backend.wallet.service.WalletService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/wallets")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class WalletController {

    private final WalletService walletService;

    @GetMapping("/me")
    @Operation(summary = "Get the authenticated user's wallet")
    public ResponseEntity<CurrentWalletResponse> getCurrentUserWallet(
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(
                walletService.getCurrentUserWallet(
                        currentUser.getId()
                )
        );
    }
}
