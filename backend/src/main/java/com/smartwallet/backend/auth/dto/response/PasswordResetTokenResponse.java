package com.smartwallet.backend.auth.dto.response;

public record PasswordResetTokenResponse(

        String resetToken,

        long expiresInSeconds

) {
}