package com.smartwallet.backend.auth.service;

import java.time.Duration;
import java.time.LocalDateTime;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.auth.domain.EmailActionCode;
import com.smartwallet.backend.auth.domain.EmailActionPurpose;
import com.smartwallet.backend.auth.repository.EmailActionCodeRepository;
import com.smartwallet.backend.common.exception.EmailCodeCooldownException;
import com.smartwallet.backend.common.exception.InvalidEmailActionCodeException;
import com.smartwallet.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailActionCodeService {

    private static final Duration CODE_EXPIRATION =
            Duration.ofMinutes(10);

    private static final Duration RESEND_COOLDOWN =
            Duration.ofSeconds(60);

    private static final Duration ACTION_TOKEN_EXPIRATION =
            Duration.ofMinutes(10);

    private static final int MAX_FAILED_ATTEMPTS = 5;

    private static final String INVALID_CODE_MESSAGE =
            "The email code is invalid or expired";

    private static final String INVALID_RESET_TOKEN_MESSAGE =
            "The password reset token is invalid or expired";

    private final EmailActionCodeRepository emailActionCodeRepository;
    private final EmailCodeService emailCodeService;
    private final PasswordResetTokenService passwordResetTokenService;

    @Transactional
    public String issueCode(
            User user,
            EmailActionPurpose purpose
    ) {

        LocalDateTime now = LocalDateTime.now();

        emailActionCodeRepository
                .findFirstByUserAndPurposeAndInvalidatedAtIsNullAndUsedAtIsNullOrderByCreatedAtDesc(
                        user,
                        purpose
                )
                .ifPresent(existingCode -> {

                    validateResendCooldown(
                            existingCode,
                            now
                    );

                    existingCode.setInvalidatedAt(now);

                    emailActionCodeRepository.save(
                            existingCode
                    );
                });

        String rawCode =
                emailCodeService.generateCode();

        EmailActionCode newCode =
                new EmailActionCode(
                        user,
                        purpose,
                        emailCodeService.encode(rawCode),
                        now.plus(CODE_EXPIRATION),
                        now.plus(RESEND_COOLDOWN)
                );

        emailActionCodeRepository.save(newCode);

        return rawCode;
    }

    @Transactional(
            noRollbackFor =
                    InvalidEmailActionCodeException.class
    )
    public EmailActionCode verifyCode(
            User user,
            EmailActionPurpose purpose,
            String rawCode
    ) {

        LocalDateTime now = LocalDateTime.now();

        EmailActionCode actionCode =
                emailActionCodeRepository
                        .findFirstByUserAndPurposeAndInvalidatedAtIsNullAndUsedAtIsNullOrderByCreatedAtDesc(
                                user,
                                purpose
                        )
                        .orElseThrow(() ->
                                new InvalidEmailActionCodeException(
                                        INVALID_CODE_MESSAGE
                                )
                        );

        validateCodeState(
                actionCode,
                now
        );

        boolean codeMatches =
                emailCodeService.matches(
                        rawCode,
                        actionCode.getCodeHash()
                );

        if (!codeMatches) {

            registerFailedAttempt(
                    actionCode,
                    now
            );

            throw new InvalidEmailActionCodeException(
                    INVALID_CODE_MESSAGE
            );
        }

        actionCode.setVerifiedAt(now);

        return emailActionCodeRepository.save(
                actionCode
        );
    }

    @Transactional(
            noRollbackFor =
                    InvalidEmailActionCodeException.class
    )
    public String verifyPasswordResetCode(
            User user,
            String rawCode
    ) {

        EmailActionCode actionCode =
                verifyCode(
                        user,
                        EmailActionPurpose.PASSWORD_RESET,
                        rawCode
                );

        LocalDateTime now = LocalDateTime.now();

        String rawResetToken =
                passwordResetTokenService.generateToken();

        String resetTokenHash =
                passwordResetTokenService.hashToken(
                        rawResetToken
                );

        actionCode.setActionTokenHash(
                resetTokenHash
        );

        actionCode.setActionTokenExpiresAt(
                now.plus(ACTION_TOKEN_EXPIRATION)
        );

        emailActionCodeRepository.save(
                actionCode
        );

        return rawResetToken;
    }

    @Transactional(
            noRollbackFor =
                    InvalidEmailActionCodeException.class
    )
    public EmailActionCode validatePasswordResetToken(
            String rawResetToken
    ) {

        if (rawResetToken == null
                || rawResetToken.isBlank()) {

            throw new InvalidEmailActionCodeException(
                    INVALID_RESET_TOKEN_MESSAGE
            );
        }

        String resetTokenHash =
                passwordResetTokenService.hashToken(
                        rawResetToken
                );

        LocalDateTime now = LocalDateTime.now();

        EmailActionCode actionCode =
                emailActionCodeRepository
                        .findByActionTokenHashAndPurposeAndVerifiedAtIsNotNullAndInvalidatedAtIsNullAndUsedAtIsNull(
                                resetTokenHash,
                                EmailActionPurpose.PASSWORD_RESET
                        )
                        .orElseThrow(() ->
                                new InvalidEmailActionCodeException(
                                        INVALID_RESET_TOKEN_MESSAGE
                                )
                        );

        LocalDateTime tokenExpiresAt =
                actionCode.getActionTokenExpiresAt();

        boolean tokenExpired =
                tokenExpiresAt == null
                        || !now.isBefore(tokenExpiresAt);

        if (tokenExpired) {

            actionCode.setInvalidatedAt(now);

            emailActionCodeRepository.save(
                    actionCode
            );

            throw new InvalidEmailActionCodeException(
                    INVALID_RESET_TOKEN_MESSAGE
            );
        }

        return actionCode;
    }

    public long getActionTokenExpirationSeconds() {

        return ACTION_TOKEN_EXPIRATION.toSeconds();
    }

    @Transactional
    public void markUsed(
            EmailActionCode actionCode
    ) {

        actionCode.setUsedAt(
                LocalDateTime.now()
        );

        emailActionCodeRepository.save(
                actionCode
        );
    }

    private void validateCodeState(
            EmailActionCode actionCode,
            LocalDateTime now
    ) {

        boolean expired =
                !now.isBefore(
                        actionCode.getExpiresAt()
                );

        boolean alreadyVerified =
                actionCode.getVerifiedAt() != null;

        boolean attemptsExceeded =
                actionCode.getFailedAttempts()
                        >= MAX_FAILED_ATTEMPTS;

        if (alreadyVerified) {
            throw new InvalidEmailActionCodeException(
                    INVALID_CODE_MESSAGE
            );
        }

        if (!expired && !attemptsExceeded) {
            return;
        }

        if (actionCode.getInvalidatedAt() == null) {

            actionCode.setInvalidatedAt(now);

            emailActionCodeRepository.save(
                    actionCode
            );
        }

        throw new InvalidEmailActionCodeException(
                INVALID_CODE_MESSAGE
        );
    }

    private void registerFailedAttempt(
            EmailActionCode actionCode,
            LocalDateTime now
    ) {

        int updatedAttempts =
                actionCode.getFailedAttempts() + 1;

        actionCode.setFailedAttempts(
                updatedAttempts
        );

        if (updatedAttempts >= MAX_FAILED_ATTEMPTS) {
            actionCode.setInvalidatedAt(now);
        }

        emailActionCodeRepository.save(
                actionCode
        );
    }

    private void validateResendCooldown(
            EmailActionCode existingCode,
            LocalDateTime now
    ) {

        if (!now.isBefore(
                existingCode.getResendAvailableAt()
        )) {
            return;
        }

        long remainingSeconds =
                Duration.between(
                        now,
                        existingCode.getResendAvailableAt()
                ).toSeconds();

        throw new EmailCodeCooldownException(
                remainingSeconds
        );
    }
}