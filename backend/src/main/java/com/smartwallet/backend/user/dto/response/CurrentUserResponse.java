package com.smartwallet.backend.user.dto.response;

public record CurrentUserResponse(

        Long id,

        String firstName,

        String lastName,

        String email

) {
}