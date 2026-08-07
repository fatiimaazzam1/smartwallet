package com.smartwallet.backend.category.service;

import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.category.domain.CategoryStatus;
import com.smartwallet.backend.category.domain.CategoryType;
import com.smartwallet.backend.category.dto.request.CreateCategoryRequest;
import com.smartwallet.backend.category.dto.response.CategoryResponse;
import com.smartwallet.backend.category.exception.CategoryConflictException;
import com.smartwallet.backend.category.exception.CategoryNotFoundException;
import com.smartwallet.backend.category.repository.CategoryRepository;
import com.smartwallet.backend.common.exception.CurrentUserNotFoundException;
import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private static final String CUSTOM_ICON_KEY = "custom";

    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public List<CategoryResponse> getCurrentUserCategories(
            Long currentUserId,
            CategoryType type
    ) {
        ensureCurrentUserExists(currentUserId);

        return categoryRepository.findVisibleCategories(
                        currentUserId,
                        CategoryStatus.ACTIVE,
                        type
                )
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public CategoryResponse createCategory(
            Long currentUserId,
            CreateCategoryRequest request
    ) {
        User currentUser = findCurrentUser(currentUserId);
        String normalizedName = normalizeName(request.name());
        CategoryType type = request.type();

        ensureNameDoesNotConflictWithSystemCategory(
                normalizedName,
                type
        );

        Category category = categoryRepository
                .findByUserIdAndTypeAndNameIgnoreCase(
                        currentUserId,
                        type,
                        normalizedName
                )
                .map(existingCategory -> reactivateOrReject(
                        existingCategory,
                        normalizedName
                ))
                .orElseGet(() -> new Category(
                        currentUser,
                        normalizedName,
                        type,
                        CUSTOM_ICON_KEY
                ));

        try {
            return toResponse(
                    categoryRepository.saveAndFlush(category)
            );
        } catch (DataIntegrityViolationException exception) {
            throw new CategoryConflictException(
                    "A category with this name and type already exists"
            );
        }
    }

    @Transactional
    public void archiveCategory(
            Long currentUserId,
            Long categoryId
    ) {
        Category category = categoryRepository.findById(categoryId)
                .orElseThrow(CategoryNotFoundException::new);

        if (category.isSystem()) {
            throw new CategoryConflictException(
                    "Default categories cannot be deleted"
            );
        }

        if (!category.belongsTo(currentUserId) || !category.isActive()) {
            throw new CategoryNotFoundException();
        }

        category.archive();
    }

    private void ensureCurrentUserExists(
            Long currentUserId
    ) {
        if (!userRepository.existsById(currentUserId)) {
            throw new CurrentUserNotFoundException();
        }
    }

    private User findCurrentUser(
            Long currentUserId
    ) {
        return userRepository.findById(currentUserId)
                .orElseThrow(CurrentUserNotFoundException::new);
    }

    private void ensureNameDoesNotConflictWithSystemCategory(
            String normalizedName,
            CategoryType type
    ) {
        if (categoryRepository
                .existsByUserIsNullAndTypeAndNameIgnoreCase(
                        type,
                        normalizedName
                )) {
            throw new CategoryConflictException(
                    "A default category with this name and type already exists"
            );
        }
    }

    private Category reactivateOrReject(
            Category category,
            String normalizedName
    ) {
        if (category.isActive()) {
            throw new CategoryConflictException(
                    "A category with this name and type already exists"
            );
        }

        category.reactivate(
                normalizedName,
                CUSTOM_ICON_KEY
        );
        return category;
    }

    private String normalizeName(
            String value
    ) {
        String normalized = value
                .strip()
                .replaceAll("[\\p{Zs}\\s]+", " ");

        if (normalized.isBlank()) {
            throw new IllegalArgumentException(
                    "Category name is required"
            );
        }

        return normalized;
    }

    private CategoryResponse toResponse(
            Category category
    ) {
        return new CategoryResponse(
                category.getId(),
                category.getName(),
                category.getType(),
                category.getIconKey(),
                category.isSystem()
        );
    }
}
