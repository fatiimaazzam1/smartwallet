# SmartWallet ERD v3 — Planning

This ERD represents the persisted database schema after Flyway migrations V1-V7.

Safe to Spend and Weekly Insights are intentionally excluded as entities because they are calculated by the backend from persisted financial data.

```mermaid
erDiagram
    USERS ||--|| WALLETS : owns
    USERS ||--|| USER_PREFERENCES : has
    USERS ||--o{ REFRESH_TOKENS : has
    USERS ||--o{ EMAIL_ACTION_CODES : receives
    USERS ||--o{ CATEGORIES : owns_custom

    WALLETS ||--o{ TRANSACTIONS : contains
    WALLETS ||--o{ BUDGETS : has
    WALLETS ||--o{ PLANNED_EXPENSES : plans

    CATEGORIES ||--o{ TRANSACTIONS : classifies
    CATEGORIES ||--o{ BUDGETS : limits
    CATEGORIES ||--o{ PLANNED_EXPENSES : classifies

    TRANSACTIONS ||--o| PLANNED_EXPENSES : generated_payment_for

    USERS {
        bigint id PK
        varchar first_name
        varchar last_name
        varchar email UK
        varchar password_hash
        varchar account_status
        timestamp email_verified_at
        timestamp created_at
        timestamp updated_at
    }

    WALLETS {
        bigint id PK
        bigint user_id FK,UK
        varchar name
        varchar currency_code
        timestamp created_at
        timestamp updated_at
    }

    CATEGORIES {
        bigint id PK
        bigint user_id FK "nullable for system categories"
        varchar name
        varchar category_type
        varchar icon_key
        boolean is_system
        varchar status
        int display_order
        timestamp created_at
        timestamp updated_at
    }

    TRANSACTIONS {
        bigint id PK
        bigint wallet_id FK
        bigint category_id FK
        varchar transaction_type
        decimal amount
        varchar description
        date occurred_on
        varchar status
        bigint version
        uuid client_request_id
        timestamp created_at
        timestamp updated_at
    }

    BUDGETS {
        bigint id PK
        bigint wallet_id FK
        bigint category_id FK
        decimal limit_amount
        date budget_month
        varchar note
        varchar status
        bigint version
        timestamp created_at
        timestamp updated_at
    }

    USER_PREFERENCES {
        bigint id PK
        bigint user_id FK,UK
        boolean hide_balance_by_default
        boolean compact_transaction_list
        boolean show_budget_warnings
        int budget_warning_threshold
        varchar date_format
        varchar dashboard_period
        varchar language
        timestamp created_at
        timestamp updated_at
    }

    REFRESH_TOKENS {
        bigint id PK
        bigint user_id FK
        varchar token_hash UK
        timestamp expires_at
        boolean revoked
        timestamp created_at
    }

    EMAIL_ACTION_CODES {
        bigint id PK
        bigint user_id FK
        varchar purpose
        varchar code_hash
        timestamp expires_at
        timestamp resend_available_at
        int failed_attempts
        timestamp verified_at
        varchar action_token_hash UK
        timestamp action_token_expires_at
        timestamp invalidated_at
        timestamp used_at
        timestamp created_at
        timestamp updated_at
    }

    PLANNED_EXPENSES {
        bigint id PK
        bigint wallet_id FK
        bigint category_id FK
        varchar title
        decimal amount
        date due_on
        varchar recurrence
        varchar status
        varchar note
        uuid create_client_request_id
        date paid_on
        bigint paid_transaction_id FK
        uuid payment_client_request_id
        bigint version
        timestamp created_at
        timestamp updated_at
    }
```

## Key Constraints

- one wallet per user
- one preference row per user
- category type is `INCOME` or `EXPENSE`
- system categories have no owner; custom categories belong to a user
- transaction amount is positive
- transaction status is `ACTIVE` or `ARCHIVED`
- active transaction create request ids are wallet-scoped for idempotency
- active budget uniqueness is wallet + category + month
- budget month is the first day of its month
- budget status is `ACTIVE` or `ARCHIVED`
- planned amount is positive
- planned recurrence is `NONE`, `WEEKLY`, `MONTHLY` or `YEARLY`
- planned status is `UPCOMING`, `PAID`, `CANCELLED` or `ARCHIVED`
- a `PAID` planned expense must have `paid_on`, `paid_transaction_id` and `payment_client_request_id`
- planned create/payment request ids are wallet-scoped for idempotency

## Calculated Values

Not stored as tables/columns:

- wallet balance
- budget spent / remaining / progress
- Safe to Spend
- Weekly Insights
- upcoming counts/totals
