package com.smartwallet.backend.auth.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailSenderService {

    private final JavaMailSender mailSender;
    private final String fromAddress;

    public EmailSenderService(
            JavaMailSender mailSender,
            @Value("${app.mail.from}") String fromAddress) {

        this.mailSender = mailSender;
        this.fromAddress = fromAddress;
    }

    public void sendVerificationCode(
            String recipientEmail,
            String firstName,
            String code) {

        String subject = "Verify your SmartWallet email";

        String body = """
                Hello %s,

                Your SmartWallet email verification code is:

                %s

                This code expires in 10 minutes.

                If you did not create a SmartWallet account,
                you can ignore this email.

                SmartWallet Team
                """.formatted(firstName, code);

        send(
                recipientEmail,
                subject,
                body);
    }

    public void sendPasswordResetCode(
            String recipientEmail,
            String firstName,
            String code) {

        String subject = "Reset your SmartWallet password";

        String body = """
                Hello %s,

                Your SmartWallet password reset code is:

                %s

                This code expires in 10 minutes.

                If you did not request a password reset,
                you can ignore this email.

                SmartWallet Team
                """.formatted(firstName, code);

        send(
                recipientEmail,
                subject,
                body);
    }

    private void send(
            String recipientEmail,
            String subject,
            String body) {

        SimpleMailMessage message =
                new SimpleMailMessage();

        message.setFrom(fromAddress);
        message.setTo(recipientEmail);
        message.setSubject(subject);
        message.setText(body);

        mailSender.send(message);
    }
}