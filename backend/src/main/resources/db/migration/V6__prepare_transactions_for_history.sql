-- Phase 4: secure transaction history, editing, soft deletion, and idempotent creation.
-- Existing transaction timestamps are preserved as calendar dates.

ALTER TABLE transactions
    ADD COLUMN occurred_on DATE;

UPDATE transactions
SET occurred_on = CAST(occurred_at AS DATE)
WHERE occurred_on IS NULL;

ALTER TABLE transactions
    ALTER COLUMN occurred_on SET NOT NULL;

ALTER TABLE transactions
    ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE';

ALTER TABLE transactions
    ADD COLUMN version BIGINT NOT NULL DEFAULT 0;

ALTER TABLE transactions
    ADD COLUMN client_request_id UUID;

ALTER TABLE transactions
    ADD CONSTRAINT chk_transactions_status
    CHECK (status IN ('ACTIVE', 'ARCHIVED'));

ALTER TABLE transactions
    ADD CONSTRAINT chk_transactions_description_controls
    CHECK (
        description IS NULL
        OR description !~ '[[:cntrl:]]'
    );

DROP INDEX IF EXISTS idx_transactions_occurred_at;

ALTER TABLE transactions
    DROP COLUMN occurred_at;

CREATE UNIQUE INDEX uq_transactions_wallet_client_request
    ON transactions (wallet_id, client_request_id)
    WHERE client_request_id IS NOT NULL;

CREATE INDEX idx_transactions_wallet_status_date_id
    ON transactions (wallet_id, status, occurred_on DESC, id DESC);

CREATE INDEX idx_transactions_wallet_status_type_date
    ON transactions (wallet_id, status, transaction_type, occurred_on DESC);

CREATE INDEX idx_transactions_wallet_status_category_date
    ON transactions (wallet_id, status, category_id, occurred_on DESC);
