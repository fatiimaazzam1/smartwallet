package com.smartwallet.backend.common.exception;

public class EmailCodeCooldownException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    private final long remainingSeconds;

    public EmailCodeCooldownException(
            long remainingSeconds
    ) {

        super(
                "A new email code can be requested in "
                        + Math.max(1, remainingSeconds)
                        + " seconds."
        );

        this.remainingSeconds =
                Math.max(1, remainingSeconds);
    }

    public long getRemainingSeconds() {
        return remainingSeconds;
    }
}