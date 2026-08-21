package com.smartwallet.backend.plannedexpense.exception;

public class PlannedExpenseNotFoundException extends RuntimeException {
    public PlannedExpenseNotFoundException() {
        super("Planned expense not found");
    }
}
