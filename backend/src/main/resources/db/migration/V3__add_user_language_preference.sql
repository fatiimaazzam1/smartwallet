ALTER TABLE user_preferences
    ADD COLUMN language VARCHAR(20) NOT NULL DEFAULT 'SYSTEM';

ALTER TABLE user_preferences
    ADD CONSTRAINT chk_preferences_language
    CHECK (
        language IN (
            'SYSTEM',
            'ENGLISH',
            'ARABIC'
        )
    );

-- Backfill a preference row for any legacy user that does not have one.
INSERT INTO user_preferences (
    user_id,
    hide_balance_by_default,
    compact_transaction_list,
    show_budget_warnings,
    budget_warning_threshold,
    date_format,
    dashboard_period,
    language,
    created_at,
    updated_at
)
SELECT
    u.id,
    FALSE,
    FALSE,
    TRUE,
    70,
    'DD/MM/YYYY',
    'CURRENT_MONTH',
    'SYSTEM',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM user_preferences p
    WHERE p.user_id = u.id
);
