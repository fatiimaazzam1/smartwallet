package com.smartwallet.backend.category.web;

import java.net.URI;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartwallet.backend.category.domain.CategoryType;
import com.smartwallet.backend.category.dto.request.CreateCategoryRequest;
import com.smartwallet.backend.category.dto.response.CategoryResponse;
import com.smartwallet.backend.category.service.CategoryService;
import com.smartwallet.backend.user.domain.User;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    @Operation(
            summary = "List categories visible to the authenticated user"
    )
    public ResponseEntity<List<CategoryResponse>> getCategories(
            @AuthenticationPrincipal User currentUser,
            @RequestParam(required = false) CategoryType type
    ) {
        return ResponseEntity.ok(
                categoryService.getCurrentUserCategories(
                        currentUser.getId(),
                        type
                )
        );
    }

    @PostMapping
    @Operation(summary = "Create a custom category")
    public ResponseEntity<CategoryResponse> createCategory(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody CreateCategoryRequest request
    ) {
        CategoryResponse response =
                categoryService.createCategory(
                        currentUser.getId(),
                        request
                );

        return ResponseEntity
                .created(
                        URI.create(
                                "/api/v1/categories/" + response.id()
                        )
                )
                .body(response);
    }

    @DeleteMapping("/{categoryId}")
    @Operation(summary = "Archive a custom category")
    public ResponseEntity<Void> archiveCategory(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long categoryId
    ) {
        categoryService.archiveCategory(
                currentUser.getId(),
                categoryId
        );

        return ResponseEntity.noContent().build();
    }
}
