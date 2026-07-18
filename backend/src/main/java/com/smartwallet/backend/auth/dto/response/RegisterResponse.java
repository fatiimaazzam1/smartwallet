package com.smartwallet.backend.auth.dto.response;

public record RegisterResponse(

        Long id,
        String firstName,
        String lastName,
        String email,
        String message

) {
}