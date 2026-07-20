package com.smartwallet.backend.auth.dto.response;

public record AuthenticatedUserResponse(

        Long id,
        String firstName,
        String lastName,
        String email

) {
}