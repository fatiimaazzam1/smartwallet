package com.smartwallet.backend.auth.dto.response;

public record RefreshTokenResponse(

        String accessToken,
        long expiresIn

) {
}