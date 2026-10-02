package com.smartwallet.backend.plannedexpense.exception;

public class PlannedExpenseConflictException extends RuntimeException {
    public PlannedExpenseConflictException(String message) {
        super(message);
    }
}
