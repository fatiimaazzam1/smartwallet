-- Retire the generic "Other" defaults without deleting historical links.
-- Existing transactions keep their category reference, while active category
-- queries no longer return these two system categories.

UPDATE categories
SET status = 'ARCHIVED',
    updated_at = CURRENT_TIMESTAMP
WHERE user_id IS NULL
  AND is_system = TRUE
  AND status = 'ACTIVE'
  AND LOWER(name) = 'other'
  AND category_type IN ('INCOME', 'EXPENSE');
