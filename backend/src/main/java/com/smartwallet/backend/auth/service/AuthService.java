package com.smartwallet.backend.auth.service;

import java.time.LocalDateTime;
import java.util.Locale;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.auth.domain.EmailActionCode;
import com.smartwallet.backend.auth.domain.EmailActionPurpose;
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

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final String INVALID_EMAIL_CODE_MESSAGE =
            "The email code is invalid or expired";

    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final UserPreferenceRepository userPreferenceRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final EmailActionCodeService emailActionCodeService;
    private final EmailSenderService emailSenderService;

    @Transactional
    public RegisterResponse register(RegisterRequest request) {

        if (!request.password().equals(request.confirmPassword())) {
            throw new IllegalArgumentException(
                    "Password and confirmation password do not match"
            );
        }

        String normalizedEmail = request.email()
                .trim()
                .toLowerCase(Locale.ROOT);

        if (userRepository.existsByEmailIgnoreCase(normalizedEmail)) {
            throw new IllegalStateException(
                    "An account with this email already exists"
            );
        }

        String passwordHash =
                passwordEncoder.encode(request.password());

        User user = new User(
                request.firstName().trim(),
                request.lastName().trim(),
                normalizedEmail,
                passwordHash
        );

        User savedUser = userRepository.save(user);

        walletRepository.save(new Wallet(savedUser));

        userPreferenceRepository.save(
                new UserPreference(savedUser)
        );

        String verificationCode =
                emailActionCodeService.issueCode(
                        savedUser,
                        EmailActionPurpose.EMAIL_VERIFICATION
                );

        emailSenderService.sendVerificationCode(
                savedUser.getEmail(),
                savedUser.getFirstName(),
                verificationCode
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
            noRollbackFor = InvalidEmailActionCodeException.class
    )
    public MessageResponse verifyEmail(
            VerifyEmailRequest request
    ) {

        String normalizedEmail = request.email()
                .trim()
                .toLowerCase(Locale.ROOT);

        User user = userRepository
                .findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() ->
                        new InvalidEmailActionCodeException(
                                INVALID_EMAIL_CODE_MESSAGE
                        )
                );

        if (user.getAccountStatus() == AccountStatus.DISABLED) {
            throw new AccountDisabledException(
                    "This account is disabled"
            );
        }

        if (user.getAccountStatus() == AccountStatus.ACTIVE
                && user.getEmailVerifiedAt() != null) {

            return new MessageResponse(
                    "Email is already verified"
            );
        }

        EmailActionCode actionCode =
                emailActionCodeService.verifyCode(
                        user,
                        EmailActionPurpose.EMAIL_VERIFICATION,
                        request.code()
                );

        LocalDateTime now = LocalDateTime.now();

        user.setAccountStatus(AccountStatus.ACTIVE);
        user.setEmailVerifiedAt(now);

        userRepository.save(user);

        emailActionCodeService.markUsed(actionCode);

        return new MessageResponse(
                "Email verified successfully"
        );
    }

    @Transactional
    public LoginResponse login(LoginRequest request) {

        String normalizedEmail = request.email()
                .trim()
                .toLowerCase(Locale.ROOT);

        User user = userRepository
                .findByEmailIgnoreCase(normalizedEmail)
                .orElseThrow(() -> new InvalidCredentialsException(
                        "Invalid email or password"
                ));

        if (!passwordEncoder.matches(
                request.password(),
                user.getPasswordHash()
        )) {
            throw new InvalidCredentialsException(
                    "Invalid email or password"
            );
        }

        if (user.getAccountStatus() == AccountStatus.DISABLED) {
            throw new AccountDisabledException(
                    "This account is disabled"
            );
        }

        String accessToken = jwtService.generateAccessToken(user);

        String refreshToken =
                refreshTokenService.createRefreshToken(user);

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

        User user = refreshTokenService.validateAndGetUser(
                request.refreshToken()
        );

        if (user.getAccountStatus() == AccountStatus.DISABLED) {
            throw new AccountDisabledException(
                    "This account is disabled"
            );
        }

        String accessToken = jwtService.generateAccessToken(user);

        return new RefreshTokenResponse(
                accessToken,
                jwtService.getAccessTokenExpirationSeconds()
        );
    }

    @Transactional
    public void logout(RefreshTokenRequest request) {

        refreshTokenService.revokeRefreshToken(
                request.refreshToken()
        );
    }
}