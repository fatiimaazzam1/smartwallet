package com.smartwallet.backend.common.exception;

public class EmailVerificationRequiredException
        extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public EmailVerificationRequiredException(String message) {
        super(message);
    }
}