package com.smartwallet.backend.category.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartwallet.backend.category.domain.Category;
import com.smartwallet.backend.category.domain.CategoryStatus;
import com.smartwallet.backend.category.domain.CategoryType;

public interface CategoryRepository extends JpaRepository<Category, Long> {

    @Query("""
            select category
            from Category category
            where category.status = :status
              and (category.user is null or category.user.id = :userId)
              and (:type is null or category.type = :type)
            order by
              category.type desc,
              category.system desc,
              category.displayOrder asc,
              lower(category.name) asc,
              category.id asc
            """)
    List<Category> findVisibleCategories(
            @Param("userId") Long userId,
            @Param("status") CategoryStatus status,
            @Param("type") CategoryType type
    );

    @Query("""
            select category
            from Category category
            where category.id = :categoryId
              and (category.user is null or category.user.id = :userId)
            """)
    Optional<Category> findVisibleCategoryById(
            @Param("categoryId") Long categoryId,
            @Param("userId") Long userId
    );

    Optional<Category> findByUserIdAndTypeAndNameIgnoreCase(
            Long userId,
            CategoryType type,
            String name
    );

    boolean existsByUserIsNullAndTypeAndNameIgnoreCase(
            CategoryType type,
            String name
    );
}
