package com.smartwallet.backend.auth.service;

import java.time.LocalDateTime;
import java.util.Locale;

import org.springframework.mail.MailException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.auth.domain.EmailActionCode;
import com.smartwallet.backend.auth.domain.EmailActionPurpose;
import com.smartwallet.backend.auth.dto.request.EmailRequest;
import com.smartwallet.backend.auth.dto.request.LoginRequest;
import com.smartwallet.backend.auth.dto.request.RefreshTokenRequest;
import com.smartwallet.backend.auth.dto.request.RegisterRequest;
import com.smartwallet.backend.auth.dto.request.VerifyEmailRequest;
import com.smartwallet.backend.auth.dto.response.AuthenticatedUserResponse;
import com.smartwallet.backend.auth.dto.response.LoginResponse;
import com.smartwallet.backend.auth.dto.response.MessageResponse;
import com.smartwallet.backend.auth.dto.response.RefreshTokenResponse;
import com.smartwallet.backend.auth.dto.response.RegisterResponse;
import com.smartwallet.backend.common.exception.AccountDisabledException;
import com.smartwallet.backend.common.exception.EmailCodeCooldownException;
import com.smartwallet.backend.common.exception.EmailVerificationRequiredException;
import com.smartwallet.backend.common.exception.InvalidCredentialsException;
import com.smartwallet.backend.common.exception.InvalidEmailActionCodeException;
import com.smartwallet.backend.preference.domain.UserPreference;
import com.smartwallet.backend.preference.repository.UserPreferenceRepository;
import com.smartwallet.backend.security.jwt.JwtService;
import com.smartwallet.backend.user.domain.AccountStatus;
import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.user.repository.UserRepository;
import com.smartwallet.backend.wallet.domain.Wallet;
import com.smartwallet.backend.wallet.repository.WalletRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private static final String INVALID_EMAIL_VERIFICATION_MESSAGE =
            "The email verification request is invalid or expired";

    private static final String GENERIC_VERIFICATION_RESEND_MESSAGE =
            "If an unverified account exists, "
                    + "a new verification code has been sent.";

    private static final String GENERIC_PASSWORD_RESET_MESSAGE =
            "If an eligible account exists, "
                    + "a password reset code has been sent.";

    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final UserPreferenceRepository userPreferenceRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final EmailActionCodeService emailActionCodeService;
    private final EmailActionDeliveryService emailActionDeliveryService;

    @Transactional
    public RegisterResponse register(
            RegisterRequest request
    ) {

        if (!request.password().equals(
                request.confirmPassword()
        )) {
            throw new IllegalArgumentException(
                    "Password and confirmation password do not match"
            );
        }

        String normalizedEmail =
                normalizeEmail(request.email());

        if (userRepository.existsByEmailIgnoreCase(
                normalizedEmail
        )) {
            throw new IllegalStateException(
                    "An account with this email already exists"
            );
        }

        String passwordHash =
                passwordEncoder.encode(
                        request.password()
                );

        User user = new User(
                request.firstName().trim(),
                request.lastName().trim(),
                normalizedEmail,
                passwordHash
        );

        User savedUser =
                userRepository.save(user);

        walletRepository.save(
                new Wallet(savedUser)
        );

        userPreferenceRepository.save(
                new UserPreference(savedUser)
        );

        emailActionDeliveryService
                .issueAndSendVerificationCode(
                        savedUser
                );

        return new RegisterResponse(
                savedUser.getId(),
                savedUser.getFirstName(),
                savedUser.getLastName(),
                savedUser.getEmail(),
                "Account created. Check your email for the verification code."
        );
    }

    @Transactional(
            noRollbackFor =
                    InvalidEmailActionCodeException.class
    )
    public MessageResponse verifyEmail(
            VerifyEmailRequest request
    ) {

        String normalizedEmail =
                normalizeEmail(request.email());

        User user = userRepository
                .findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() ->
                        invalidEmailVerificationRequest()
                );

        if (user.getAccountStatus()
                != AccountStatus.PENDING_VERIFICATION
                || user.getEmailVerifiedAt() != null) {

            throw invalidEmailVerificationRequest();
        }

        EmailActionCode actionCode;

        try {
            actionCode =
                    emailActionCodeService.verifyCode(
                            user,
                            EmailActionPurpose.EMAIL_VERIFICATION,
                            request.code()
                    );
        } catch (InvalidEmailActionCodeException exception) {
            throw invalidEmailVerificationRequest();
        }

        user.setAccountStatus(
                AccountStatus.ACTIVE
        );

        user.setEmailVerifiedAt(
                LocalDateTime.now()
        );

        userRepository.save(user);

        emailActionCodeService.markUsed(
                actionCode
        );

        return new MessageResponse(
                "Email verified successfully"
        );
    }

    public MessageResponse resendVerificationCode(
            EmailRequest request
    ) {

        String normalizedEmail =
                normalizeEmail(request.email());

        User user = userRepository
                .findByEmailIgnoreCase(normalizedEmail)
                .orElse(null);

        boolean eligibleForVerification =
                user != null
                        && user.getAccountStatus()
                                == AccountStatus.PENDING_VERIFICATION
                        && user.getEmailVerifiedAt() == null;

        if (eligibleForVerification) {
            try {
                emailActionDeliveryService
                        .issueAndSendVerificationCode(
                                user
                        );
            } catch (EmailCodeCooldownException exception) {
                log.debug(
                        "Verification resend ignored during cooldown for userId={}",
                        user.getId()
                );
            } catch (MailException exception) {
                log.warn(
                        "Verification email delivery failed for userId={}",
                        user.getId()
                );
            }
        }

        return new MessageResponse(
                GENERIC_VERIFICATION_RESEND_MESSAGE
        );
    }

    public MessageResponse forgotPassword(
            EmailRequest request
    ) {

        requestPasswordReset(request);

        return new MessageResponse(
                GENERIC_PASSWORD_RESET_MESSAGE
        );
    }

    public MessageResponse resendPasswordResetCode(
            EmailRequest request
    ) {

        requestPasswordReset(request);

        return new MessageResponse(
                GENERIC_PASSWORD_RESET_MESSAGE
        );
    }

    @Transactional
    public LoginResponse login(
            LoginRequest request
    ) {

        String normalizedEmail =
                normalizeEmail(request.email());

        User user = userRepository
                .findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() ->
                        new InvalidCredentialsException(
                                "Invalid email or password"
                        )
                );

        if (!passwordEncoder.matches(
                request.password(),
                user.getPasswordHash()
        )) {
            throw new InvalidCredentialsException(
                    "Invalid email or password"
            );
        }

        validateAccountCanAuthenticate(user);

        String accessToken =
                jwtService.generateAccessToken(user);

        String refreshToken =
                refreshTokenService.createRefreshToken(
                        user
                );

        AuthenticatedUserResponse authenticatedUser =
                new AuthenticatedUserResponse(
                        user.getId(),
                        user.getFirstName(),
                        user.getLastName(),
                        user.getEmail()
                );

        return new LoginResponse(
                accessToken,
                refreshToken,
                jwtService.getAccessTokenExpirationSeconds(),
                authenticatedUser
        );
    }

    @Transactional
    public RefreshTokenResponse refreshAccessToken(
            RefreshTokenRequest request
    ) {

        User user =
                refreshTokenService.validateAndGetUser(
                        request.refreshToken()
                );

        validateAccountCanAuthenticate(user);

        String accessToken =
                jwtService.generateAccessToken(user);

        return new RefreshTokenResponse(
                accessToken,
                jwtService.getAccessTokenExpirationSeconds()
        );
    }

    @Transactional
    public void logout(
            RefreshTokenRequest request
    ) {

        refreshTokenService.revokeRefreshToken(
                request.refreshToken()
        );
    }

    private void requestPasswordReset(
            EmailRequest request
    ) {

        String normalizedEmail =
                normalizeEmail(request.email());

        User user = userRepository
                .findByEmailIgnoreCase(normalizedEmail)
                .orElse(null);

        if (user == null || !isActiveAndVerified(user)) {
            return;
        }

        try {
            emailActionDeliveryService
                    .issueAndSendPasswordResetCode(
                            user
                    );
        } catch (EmailCodeCooldownException exception) {
            log.debug(
                    "Password reset request ignored during cooldown for userId={}",
                    user.getId()
            );
        } catch (MailException exception) {
            log.warn(
                    "Password reset email delivery failed for userId={}",
                    user.getId()
            );
        }
    }

    private void validateAccountCanAuthenticate(
            User user
    ) {

        if (user.getAccountStatus()
                == AccountStatus.DISABLED) {

            throw new AccountDisabledException(
                    "This account is disabled"
            );
        }

        if (!isActiveAndVerified(user)) {

            throw new EmailVerificationRequiredException(
                    "Email verification is required"
            );
        }
    }

    private boolean isActiveAndVerified(
            User user
    ) {

        return user.getAccountStatus()
                == AccountStatus.ACTIVE
                && user.getEmailVerifiedAt() != null;
    }

    private InvalidEmailActionCodeException
            invalidEmailVerificationRequest() {

        return new InvalidEmailActionCodeException(
                INVALID_EMAIL_VERIFICATION_MESSAGE
        );
    }

    private String normalizeEmail(
            String email
    ) {

        return email
                .trim()
                .toLowerCase(Locale.ROOT);
    }
}