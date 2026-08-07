package com.smartwallet.backend.category.dto.response;

import com.smartwallet.backend.category.domain.CategoryType;

public record CategoryResponse(
        Long id,
        String name,
        CategoryType type,
        String iconKey,
        boolean system
) {
}
