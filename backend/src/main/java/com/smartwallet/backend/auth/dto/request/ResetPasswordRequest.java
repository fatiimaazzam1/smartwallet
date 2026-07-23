package com.smartwallet.backend.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record ResetPasswordRequest(

        @NotBlank(message = "Reset token is required")
        @Size(max = 200,
              message = "Reset token must not exceed 200 characters")
        String resetToken,

        @NotBlank(message = "New password is required")
        @Size(min = 8, max = 72,
              message = "New password must be between 8 and 72 characters")
        @Pattern(
                regexp = "^(?=\\S+$)(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).+$",
                message = "New password must contain uppercase, lowercase, number, and special character"
        )
        String newPassword,

        @NotBlank(message = "Password confirmation is required")
        @Size(min = 8, max = 72,
              message = "Password confirmation must be between 8 and 72 characters")
        String confirmPassword

) {
}