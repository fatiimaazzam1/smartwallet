package com.smartwallet.backend.user.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record UpdateCurrentUserRequest(

        @NotBlank(message = "First name is required")
        @Size(max = 50, message = "First name must not exceed 50 characters")
        @Pattern(
                regexp = "^[\\p{L}\\p{M}]+(?:[\\p{L}\\p{M}\\p{Zs}.'’\\p{Pd}]*[\\p{L}\\p{M}])?$",
                message = "First name may contain letters, spaces, apostrophes, periods, and hyphens"
        )
        String firstName,

        @NotBlank(message = "Last name is required")
        @Size(max = 50, message = "Last name must not exceed 50 characters")
        @Pattern(
                regexp = "^[\\p{L}\\p{M}]+(?:[\\p{L}\\p{M}\\p{Zs}.'’\\p{Pd}]*[\\p{L}\\p{M}])?$",
                message = "Last name may contain letters, spaces, apostrophes, periods, and hyphens"
        )
        String lastName

) {
}
