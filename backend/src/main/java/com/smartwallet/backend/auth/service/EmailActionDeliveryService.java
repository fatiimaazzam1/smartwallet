package com.smartwallet.backend.auth.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.auth.domain.EmailActionPurpose;
import com.smartwallet.backend.user.domain.User;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class EmailActionDeliveryService {

    private final EmailActionCodeService emailActionCodeService;
    private final EmailSenderService emailSenderService;

    @Transactional
    public void issueAndSendVerificationCode(
            User user
    ) {

        String verificationCode =
                emailActionCodeService.issueCode(
                        user,
                        EmailActionPurpose.EMAIL_VERIFICATION
                );

        emailSenderService.sendVerificationCode(
                user.getEmail(),
                user.getFirstName(),
                verificationCode
        );
    }

    @Transactional
    public void issueAndSendPasswordResetCode(
            User user
    ) {

        String resetCode =
                emailActionCodeService.issueCode(
                        user,
                        EmailActionPurpose.PASSWORD_RESET
                );

        emailSenderService.sendPasswordResetCode(
                user.getEmail(),
                user.getFirstName(),
                resetCode
        );
    }
}