package com.smartwallet.backend.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record VerifyPasswordResetCodeRequest(

        @NotBlank(message = "Email is required")
        @Email(message = "Email format is invalid")
        @Size(
                max = 150,
                message = "Email must not exceed 150 characters"
        )
        String email,

        @NotBlank(message = "Code is required")
        @Pattern(
                regexp = "\\d{6}",
                message = "Code must contain exactly 6 digits"
        )
        String code

) {
}