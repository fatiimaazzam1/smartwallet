package com.smartwallet.backend.category.dto.request;

import com.smartwallet.backend.category.domain.CategoryType;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CreateCategoryRequest(

        @NotBlank(message = "Category name is required")
        @Size(
                max = 50,
                message = "Category name must not exceed 50 characters"
        )
        @Pattern(
                regexp = "^[^\\p{Cc}\\p{Cf}]+$",
                message = "Category name contains unsupported characters"
        )
        String name,

        @NotNull(message = "Category type is required")
        CategoryType type
) {
}
