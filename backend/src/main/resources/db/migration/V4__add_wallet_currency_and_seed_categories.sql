-- Phase 2: wallet currency and category foundations.
--
-- This migration is intentionally append-only. Do not modify V1-V3 after they
-- have been applied to an environment.

ALTER TABLE wallets
    ADD COLUMN currency_code VARCHAR(3) NOT NULL DEFAULT 'USD';

ALTER TABLE wallets
    ADD CONSTRAINT chk_wallets_currency_code
    CHECK (currency_code ~ '^[A-Z]{3}$');


ALTER TABLE categories
    ADD COLUMN display_order INTEGER NOT NULL DEFAULT 1000;

ALTER TABLE categories
    ADD CONSTRAINT chk_categories_display_order
    CHECK (display_order >= 0);


-- Default income categories shared by every user.
INSERT INTO categories (
    user_id,
    name,
    category_type,
    icon_key,
    is_system,
    status,
    display_order,
    created_at,
    updated_at
)
VALUES
    (NULL, 'Salary',    'INCOME', 'salary',    TRUE, 'ACTIVE', 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Freelance', 'INCOME', 'freelance', TRUE, 'ACTIVE', 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Gift',      'INCOME', 'gift',      TRUE, 'ACTIVE', 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Other',     'INCOME', 'other',     TRUE, 'ACTIVE', 40, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;


-- Default expense categories shared by every user.
INSERT INTO categories (
    user_id,
    name,
    category_type,
    icon_key,
    is_system,
    status,
    display_order,
    created_at,
    updated_at
)
VALUES
    (NULL, 'Food',           'EXPENSE', 'food',           TRUE, 'ACTIVE', 10, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Transportation', 'EXPENSE', 'transportation', TRUE, 'ACTIVE', 20, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Shopping',       'EXPENSE', 'shopping',       TRUE, 'ACTIVE', 30, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Bills',          'EXPENSE', 'bills',          TRUE, 'ACTIVE', 40, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Health',         'EXPENSE', 'health',         TRUE, 'ACTIVE', 50, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Education',      'EXPENSE', 'education',      TRUE, 'ACTIVE', 60, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Entertainment',  'EXPENSE', 'entertainment',  TRUE, 'ACTIVE', 70, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (NULL, 'Other',          'EXPENSE', 'other',          TRUE, 'ACTIVE', 80, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;


-- Keep default category metadata stable even if a development database already
-- contained one of the seeded names before this migration.
UPDATE categories
SET icon_key = CASE
        WHEN category_type = 'INCOME' AND LOWER(name) = 'salary' THEN 'salary'
        WHEN category_type = 'INCOME' AND LOWER(name) = 'freelance' THEN 'freelance'
        WHEN category_type = 'INCOME' AND LOWER(name) = 'gift' THEN 'gift'
        WHEN category_type = 'INCOME' AND LOWER(name) = 'other' THEN 'other'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'food' THEN 'food'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'transportation' THEN 'transportation'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'shopping' THEN 'shopping'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'bills' THEN 'bills'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'health' THEN 'health'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'education' THEN 'education'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'entertainment' THEN 'entertainment'
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'other' THEN 'other'
        ELSE icon_key
    END,
    display_order = CASE
        WHEN category_type = 'INCOME' AND LOWER(name) = 'salary' THEN 10
        WHEN category_type = 'INCOME' AND LOWER(name) = 'freelance' THEN 20
        WHEN category_type = 'INCOME' AND LOWER(name) = 'gift' THEN 30
        WHEN category_type = 'INCOME' AND LOWER(name) = 'other' THEN 40
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'food' THEN 10
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'transportation' THEN 20
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'shopping' THEN 30
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'bills' THEN 40
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'health' THEN 50
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'education' THEN 60
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'entertainment' THEN 70
        WHEN category_type = 'EXPENSE' AND LOWER(name) = 'other' THEN 80
        ELSE display_order
    END,
    status = 'ACTIVE',
    updated_at = CURRENT_TIMESTAMP
WHERE is_system = TRUE
  AND (
      (category_type = 'INCOME'
       AND LOWER(name) IN ('salary', 'freelance', 'gift', 'other'))
      OR
      (category_type = 'EXPENSE'
       AND LOWER(name) IN (
           'food',
           'transportation',
           'shopping',
           'bills',
           'health',
           'education',
           'entertainment',
           'other'
       ))
  );


-- Optimizes the two main authenticated list queries:
-- system categories by type and custom categories by owner/type.
CREATE INDEX idx_categories_system_active_type_order
    ON categories (category_type, display_order, id)
    WHERE user_id IS NULL
      AND status = 'ACTIVE';

CREATE INDEX idx_categories_user_active_type_order
    ON categories (user_id, category_type, display_order, id)
    WHERE user_id IS NOT NULL
      AND status = 'ACTIVE';
