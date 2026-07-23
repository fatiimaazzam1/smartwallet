package com.smartwallet.backend.common.exception;

public class InvalidEmailActionCodeException
        extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public InvalidEmailActionCodeException(String message) {
        super(message);
    }
}