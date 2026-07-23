package com.smartwallet.backend.auth.dto.response;

public record LoginResponse(

        String accessToken,
        String refreshToken,
        long expiresIn,
        AuthenticatedUserResponse user

) {
}