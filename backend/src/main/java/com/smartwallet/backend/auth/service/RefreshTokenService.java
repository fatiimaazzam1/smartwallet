package com.smartwallet.backend.auth.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.auth.domain.RefreshToken;
import com.smartwallet.backend.auth.repository.RefreshTokenRepository;
import com.smartwallet.backend.common.exception.InvalidRefreshTokenException;
import com.smartwallet.backend.security.jwt.JwtProperties;
import com.smartwallet.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtProperties jwtProperties;

    @Transactional
    public String createRefreshToken(User user) {

        String rawToken = generateRandomToken();
        String tokenHash = hashToken(rawToken);

        LocalDateTime expiresAt = LocalDateTime.now()
                .plusDays(jwtProperties.getRefreshTokenExpirationDays());

        RefreshToken refreshToken = new RefreshToken(
                user,
                tokenHash,
                expiresAt
        );

        refreshTokenRepository.save(refreshToken);

        return rawToken;
    }

    @Transactional
    public User validateAndGetUser(String rawToken) {

        String tokenHash = hashToken(rawToken);

        RefreshToken refreshToken = refreshTokenRepository
                .findByTokenHashAndRevokedFalse(tokenHash)
                .orElseThrow(() -> new InvalidRefreshTokenException(
                        "Invalid or expired refresh token"
                ));

        if (!refreshToken.getExpiresAt().isAfter(LocalDateTime.now())) {

            refreshToken.setRevoked(true);
            refreshTokenRepository.save(refreshToken);

            throw new InvalidRefreshTokenException(
                    "Invalid or expired refresh token"
            );
        }

        return refreshToken.getUser();
    }

    @Transactional
    public void revokeRefreshToken(String rawToken) {

        String tokenHash = hashToken(rawToken);

        RefreshToken refreshToken = refreshTokenRepository
                .findByTokenHashAndRevokedFalse(tokenHash)
                .orElseThrow(() -> new InvalidRefreshTokenException(
                        "Invalid or expired refresh token"
                ));

        refreshToken.setRevoked(true);

        refreshTokenRepository.save(refreshToken);
    }

    public String hashToken(String rawToken) {

        try {
            MessageDigest digest =
                    MessageDigest.getInstance("SHA-256");

            byte[] hashBytes = digest.digest(
                    rawToken.getBytes(StandardCharsets.UTF_8)
            );

            return HexFormat.of().formatHex(hashBytes);

        } catch (NoSuchAlgorithmException exception) {

            throw new IllegalStateException(
                    "Could not hash refresh token",
                    exception
            );
        }
    }

    private String generateRandomToken() {

        byte[] randomBytes = new byte[32];

        SECURE_RANDOM.nextBytes(randomBytes);

        return Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(randomBytes);
    }
}