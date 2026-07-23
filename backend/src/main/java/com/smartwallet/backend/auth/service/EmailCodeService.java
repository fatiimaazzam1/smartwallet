package com.smartwallet.backend.auth.service;

import java.security.SecureRandom;
import java.util.Locale;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailCodeService {

    private static final int CODE_BOUND = 1_000_000;

    private static final SecureRandom SECURE_RANDOM =
            new SecureRandom();

    private final PasswordEncoder passwordEncoder;

    public String generateCode() {
        int generatedNumber =
                SECURE_RANDOM.nextInt(CODE_BOUND);

        return String.format(
                Locale.ROOT,
                "%06d",
                generatedNumber);
    }

    public String encode(String rawCode) {
        return passwordEncoder.encode(rawCode);
    }

    public boolean matches(
            String rawCode,
            String encodedCode) {

        return passwordEncoder.matches(
                rawCode,
                encodedCode);
    }
}