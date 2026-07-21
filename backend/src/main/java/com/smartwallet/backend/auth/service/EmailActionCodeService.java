package com.smartwallet.backend.auth.service;

import java.time.Duration;
import java.time.LocalDateTime;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.auth.domain.EmailActionCode;
import com.smartwallet.backend.auth.domain.EmailActionPurpose;
import com.smartwallet.backend.auth.repository.EmailActionCodeRepository;
import com.smartwallet.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailActionCodeService {

    private static final Duration CODE_EXPIRATION =
            Duration.ofMinutes(10);

    private static final Duration RESEND_COOLDOWN =
            Duration.ofSeconds(60);

    private final EmailActionCodeRepository emailActionCodeRepository;
    private final EmailCodeService emailCodeService;

    @Transactional
    public String issueCode(
            User user,
            EmailActionPurpose purpose) {

        LocalDateTime now = LocalDateTime.now();

        emailActionCodeRepository
                .findFirstByUserAndPurposeAndInvalidatedAtIsNullAndUsedAtIsNullOrderByCreatedAtDesc(
                        user,
                        purpose)
                .ifPresent(existingCode -> {
                    validateResendCooldown(existingCode, now);

                    existingCode.setInvalidatedAt(now);
                    emailActionCodeRepository.save(existingCode);
                });

        String rawCode = emailCodeService.generateCode();

        EmailActionCode newCode =
                new EmailActionCode(
                        user,
                        purpose,
                        emailCodeService.encode(rawCode),
                        now.plus(CODE_EXPIRATION),
                        now.plus(RESEND_COOLDOWN));

        emailActionCodeRepository.save(newCode);

        return rawCode;
    }

    private void validateResendCooldown(
            EmailActionCode existingCode,
            LocalDateTime now) {

        if (!now.isBefore(existingCode.getResendAvailableAt())) {
            return;
        }

        long remainingSeconds =
                Duration.between(
                        now,
                        existingCode.getResendAvailableAt())
                        .toSeconds();

        throw new IllegalStateException(
                "A new email code can be requested in "
                        + Math.max(1, remainingSeconds)
                        + " seconds.");
    }
}