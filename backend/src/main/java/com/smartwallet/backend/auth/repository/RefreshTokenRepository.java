package com.smartwallet.backend.auth.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartwallet.backend.auth.domain.RefreshToken;
import com.smartwallet.backend.user.domain.User;

public interface RefreshTokenRepository
        extends JpaRepository<RefreshToken, Long> {

    Optional<RefreshToken> findByTokenHashAndRevokedFalse(
            String tokenHash
    );

    List<RefreshToken> findAllByUserAndRevokedFalse(
            User user
    );
}