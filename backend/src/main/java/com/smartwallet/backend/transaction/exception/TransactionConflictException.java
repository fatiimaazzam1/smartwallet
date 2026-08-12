package com.smartwallet.backend.transaction.exception;

public class TransactionConflictException extends RuntimeException {

    public TransactionConflictException(String message) {
        super(message);
    }
}
