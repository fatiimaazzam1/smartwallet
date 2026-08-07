package com.smartwallet.backend.category.domain;

import java.util.Objects;

import com.smartwallet.backend.common.domain.BaseEntity;
import com.smartwallet.backend.user.domain.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Entity
@Table(name = "categories")
public class Category extends BaseEntity {

    public static final int CUSTOM_DISPLAY_ORDER = 1000;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false, length = 50)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "category_type", nullable = false, length = 20)
    private CategoryType type;

    @Column(name = "icon_key", nullable = false, length = 50)
    private String iconKey;

    @Column(name = "is_system", nullable = false)
    private boolean system;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private CategoryStatus status = CategoryStatus.ACTIVE;

    @Column(name = "display_order", nullable = false)
    private int displayOrder = CUSTOM_DISPLAY_ORDER;

    public Category(
            User user,
            String name,
            CategoryType type,
            String iconKey
    ) {
        this.user = Objects.requireNonNull(user, "user must not be null");
        this.name = Objects.requireNonNull(name, "name must not be null");
        this.type = Objects.requireNonNull(type, "type must not be null");
        this.iconKey = Objects.requireNonNull(iconKey, "iconKey must not be null");
        this.system = false;
        this.status = CategoryStatus.ACTIVE;
        this.displayOrder = CUSTOM_DISPLAY_ORDER;
    }

    public boolean isActive() {
        return status == CategoryStatus.ACTIVE;
    }

    public boolean isCustom() {
        return !system;
    }

    public boolean belongsTo(Long userId) {
        return user != null
                && userId != null
                && Objects.equals(user.getId(), userId);
    }

    public void archive() {
        if (system) {
            throw new IllegalStateException("System categories cannot be archived");
        }
        status = CategoryStatus.ARCHIVED;
    }

    public void reactivate(String normalizedName, String normalizedIconKey) {
        if (system) {
            throw new IllegalStateException("System categories cannot be reactivated");
        }

        name = Objects.requireNonNull(
                normalizedName,
                "normalizedName must not be null"
        );
        iconKey = Objects.requireNonNull(
                normalizedIconKey,
                "normalizedIconKey must not be null"
        );
        status = CategoryStatus.ACTIVE;
    }
}
