package com.smartwallet.backend.budget.exception;

public class BudgetConflictException extends RuntimeException {
    public BudgetConflictException(String message) {
        super(message);
    }
}
