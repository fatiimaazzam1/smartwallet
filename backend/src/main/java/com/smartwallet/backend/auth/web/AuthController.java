package com.smartwallet.backend.auth.web;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartwallet.backend.auth.dto.request.EmailRequest;
import com.smartwallet.backend.auth.dto.request.LoginRequest;
import com.smartwallet.backend.auth.dto.request.RefreshTokenRequest;
import com.smartwallet.backend.auth.dto.request.RegisterRequest;
import com.smartwallet.backend.auth.dto.request.VerifyEmailRequest;
import com.smartwallet.backend.auth.dto.request.VerifyPasswordResetCodeRequest;
import com.smartwallet.backend.auth.dto.response.LoginResponse;
import com.smartwallet.backend.auth.dto.response.MessageResponse;
import com.smartwallet.backend.auth.dto.response.PasswordResetTokenResponse;
import com.smartwallet.backend.auth.dto.response.RefreshTokenResponse;
import com.smartwallet.backend.auth.dto.response.RegisterResponse;
import com.smartwallet.backend.auth.service.AuthService;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {

        RegisterResponse response =
                authService.register(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @PostMapping("/verify-email")
    public ResponseEntity<MessageResponse> verifyEmail(
            @Valid @RequestBody VerifyEmailRequest request
    ) {

        MessageResponse response =
                authService.verifyEmail(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/resend-verification-code")
    public ResponseEntity<MessageResponse> resendVerificationCode(
            @Valid @RequestBody EmailRequest request
    ) {

        MessageResponse response =
                authService.resendVerificationCode(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<MessageResponse> forgotPassword(
            @Valid @RequestBody EmailRequest request
    ) {

        MessageResponse response =
                authService.forgotPassword(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/resend-password-reset-code")
    public ResponseEntity<MessageResponse> resendPasswordResetCode(
            @Valid @RequestBody EmailRequest request
    ) {

        MessageResponse response =
                authService.resendPasswordResetCode(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/verify-password-reset-code")
    public ResponseEntity<PasswordResetTokenResponse>
            verifyPasswordResetCode(
                    @Valid @RequestBody
                    VerifyPasswordResetCodeRequest request
            ) {

        PasswordResetTokenResponse response =
                authService.verifyPasswordResetCode(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
            @Valid @RequestBody LoginRequest request
    ) {

        LoginResponse response =
                authService.login(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    public ResponseEntity<RefreshTokenResponse> refreshAccessToken(
            @Valid @RequestBody RefreshTokenRequest request
    ) {

        RefreshTokenResponse response =
                authService.refreshAccessToken(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @Valid @RequestBody RefreshTokenRequest request
    ) {

        authService.logout(request);

        return ResponseEntity.noContent().build();
    }
}