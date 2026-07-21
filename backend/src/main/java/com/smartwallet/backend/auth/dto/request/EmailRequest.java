package com.smartwallet.backend.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record EmailRequest(

        @NotBlank(message = "Email is required")
        @Email(message = "Email format is invalid")
        @Size(
                max = 150,
                message = "Email must not exceed 150 characters"
        )
        String email

) {
}