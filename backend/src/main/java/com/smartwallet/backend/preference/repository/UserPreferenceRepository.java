package com.smartwallet.backend.preference.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartwallet.backend.preference.domain.UserPreference;

public interface UserPreferenceRepository
        extends JpaRepository<UserPreference, Long> {

    Optional<UserPreference> findByUserId(Long userId);
}