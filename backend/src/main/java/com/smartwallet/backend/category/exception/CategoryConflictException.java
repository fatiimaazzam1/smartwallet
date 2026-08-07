package com.smartwallet.backend.category.exception;

public class CategoryConflictException extends RuntimeException {

    public CategoryConflictException(String message) {
        super(message);
    }
}
