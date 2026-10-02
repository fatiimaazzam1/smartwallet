package com.smartwallet.backend.budget.exception;

public class BudgetNotFoundException extends RuntimeException {
    public BudgetNotFoundException() {
        super("Budget not found");
    }
}
