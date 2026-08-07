package com.smartwallet.backend.category.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

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

@ExtendWith(MockitoExtension.class)
class CategoryServiceTest {

    @Mock
    private CategoryRepository categoryRepository;

    @Mock
    private UserRepository userRepository;

    private CategoryService categoryService;

    @BeforeEach
    void setUp() {
        categoryService = new CategoryService(
                categoryRepository,
                userRepository
        );
    }

    @Test
    void getCurrentUserCategoriesReturnsVisibleCategories() {
        Category salary = mock(Category.class);
        Category food = mock(Category.class);

        when(userRepository.existsById(1L)).thenReturn(true);
        when(categoryRepository.findVisibleCategories(
                1L,
                CategoryStatus.ACTIVE,
                null
        )).thenReturn(List.of(salary, food));

        when(salary.getId()).thenReturn(10L);
        when(salary.getName()).thenReturn("Salary");
        when(salary.getType()).thenReturn(CategoryType.INCOME);
        when(salary.getIconKey()).thenReturn("salary");
        when(salary.isSystem()).thenReturn(true);

        when(food.getId()).thenReturn(20L);
        when(food.getName()).thenReturn("Food");
        when(food.getType()).thenReturn(CategoryType.EXPENSE);
        when(food.getIconKey()).thenReturn("food");
        when(food.isSystem()).thenReturn(true);

        List<CategoryResponse> response =
                categoryService.getCurrentUserCategories(1L, null);

        assertThat(response)
                .extracting(CategoryResponse::name)
                .containsExactly("Salary", "Food");

        verify(categoryRepository).findVisibleCategories(
                1L,
                CategoryStatus.ACTIVE,
                null
        );
    }

    @Test
    void getCurrentUserCategoriesRejectsMissingAuthenticatedAccount() {
        when(userRepository.existsById(99L)).thenReturn(false);

        assertThatThrownBy(() ->
                categoryService.getCurrentUserCategories(
                        99L,
                        CategoryType.EXPENSE
                )
        ).isInstanceOf(CurrentUserNotFoundException.class);

        verify(categoryRepository, never())
                .findVisibleCategories(
                        any(),
                        any(),
                        any()
                );
    }

    @Test
    void createCategoryNormalizesAndPersistsCustomCategory() {
        User user = mock(User.class);

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));
        when(categoryRepository
                .existsByUserIsNullAndTypeAndNameIgnoreCase(
                        CategoryType.EXPENSE,
                        "Home Maintenance"
                ))
                .thenReturn(false);
        when(categoryRepository
                .findByUserIdAndTypeAndNameIgnoreCase(
                        1L,
                        CategoryType.EXPENSE,
                        "Home Maintenance"
                ))
                .thenReturn(Optional.empty());
        when(categoryRepository.saveAndFlush(any(Category.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        CategoryResponse response = categoryService.createCategory(
                1L,
                new CreateCategoryRequest(
                        "  Home   Maintenance  ",
                        CategoryType.EXPENSE
                )
        );

        ArgumentCaptor<Category> categoryCaptor =
                ArgumentCaptor.forClass(Category.class);
        verify(categoryRepository)
                .saveAndFlush(categoryCaptor.capture());

        Category savedCategory = categoryCaptor.getValue();

        assertThat(savedCategory.getName())
                .isEqualTo("Home Maintenance");
        assertThat(savedCategory.getType())
                .isEqualTo(CategoryType.EXPENSE);
        assertThat(savedCategory.getIconKey())
                .isEqualTo("custom");
        assertThat(savedCategory.isSystem()).isFalse();
        assertThat(savedCategory.isActive()).isTrue();

        assertThat(response.name())
                .isEqualTo("Home Maintenance");
        assertThat(response.system()).isFalse();
    }

    @Test
    void createCategoryRejectsDefaultCategoryDuplicate() {
        User user = mock(User.class);

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));
        when(categoryRepository
                .existsByUserIsNullAndTypeAndNameIgnoreCase(
                        CategoryType.EXPENSE,
                        "food"
                ))
                .thenReturn(true);

        assertThatThrownBy(() ->
                categoryService.createCategory(
                        1L,
                        new CreateCategoryRequest(
                                " food ",
                                CategoryType.EXPENSE
                        )
                )
        )
                .isInstanceOf(CategoryConflictException.class)
                .hasMessageContaining("default category");

        verify(categoryRepository, never())
                .saveAndFlush(any(Category.class));
    }

    @Test
    void createCategoryRejectsActiveCustomDuplicate() {
        User user = mock(User.class);
        Category existing = new Category(
                user,
                "Pet Care",
                CategoryType.EXPENSE,
                "custom"
        );

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));
        when(categoryRepository
                .existsByUserIsNullAndTypeAndNameIgnoreCase(
                        CategoryType.EXPENSE,
                        "Pet Care"
                ))
                .thenReturn(false);
        when(categoryRepository
                .findByUserIdAndTypeAndNameIgnoreCase(
                        1L,
                        CategoryType.EXPENSE,
                        "Pet Care"
                ))
                .thenReturn(Optional.of(existing));

        assertThatThrownBy(() ->
                categoryService.createCategory(
                        1L,
                        new CreateCategoryRequest(
                                "Pet Care",
                                CategoryType.EXPENSE
                        )
                )
        )
                .isInstanceOf(CategoryConflictException.class)
                .hasMessageContaining("already exists");

        verify(categoryRepository, never())
                .saveAndFlush(any(Category.class));
    }

    @Test
    void createCategoryReactivatesArchivedCustomCategory() {
        User user = mock(User.class);
        Category archived = new Category(
                user,
                "Side Work",
                CategoryType.INCOME,
                "custom"
        );
        archived.archive();

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));
        when(categoryRepository
                .existsByUserIsNullAndTypeAndNameIgnoreCase(
                        CategoryType.INCOME,
                        "Side Work"
                ))
                .thenReturn(false);
        when(categoryRepository
                .findByUserIdAndTypeAndNameIgnoreCase(
                        1L,
                        CategoryType.INCOME,
                        "Side Work"
                ))
                .thenReturn(Optional.of(archived));
        when(categoryRepository.saveAndFlush(archived))
                .thenReturn(archived);

        CategoryResponse response = categoryService.createCategory(
                1L,
                new CreateCategoryRequest(
                        " Side   Work ",
                        CategoryType.INCOME
                )
        );

        assertThat(archived.isActive()).isTrue();
        assertThat(archived.getName()).isEqualTo("Side Work");
        assertThat(response.name()).isEqualTo("Side Work");
        verify(categoryRepository).saveAndFlush(archived);
    }

    @Test
    void archiveCategoryArchivesOwnedCustomCategory() {
        User owner = mock(User.class);
        when(owner.getId()).thenReturn(1L);

        Category category = new Category(
                owner,
                "Pet Care",
                CategoryType.EXPENSE,
                "custom"
        );

        when(categoryRepository.findById(50L))
                .thenReturn(Optional.of(category));

        categoryService.archiveCategory(1L, 50L);

        assertThat(category.isActive()).isFalse();
    }

    @Test
    void archiveCategoryHidesForeignCategoryExistence() {
        User owner = mock(User.class);
        when(owner.getId()).thenReturn(2L);

        Category category = new Category(
                owner,
                "Private Category",
                CategoryType.EXPENSE,
                "custom"
        );

        when(categoryRepository.findById(60L))
                .thenReturn(Optional.of(category));

        assertThatThrownBy(() ->
                categoryService.archiveCategory(1L, 60L)
        ).isInstanceOf(CategoryNotFoundException.class);

        assertThat(category.isActive()).isTrue();
    }

    @Test
    void archiveCategoryRejectsDefaultCategory() {
        Category systemCategory = mock(Category.class);

        when(systemCategory.isSystem()).thenReturn(true);
        when(categoryRepository.findById(70L))
                .thenReturn(Optional.of(systemCategory));

        assertThatThrownBy(() ->
                categoryService.archiveCategory(1L, 70L)
        )
                .isInstanceOf(CategoryConflictException.class)
                .hasMessageContaining("Default categories");

        verify(systemCategory, never()).archive();
    }

    @Test
    void archiveCategoryRejectsUnknownCategory() {
        when(categoryRepository.findById(404L))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() ->
                categoryService.archiveCategory(1L, 404L)
        ).isInstanceOf(CategoryNotFoundException.class);
    }
}
