# SmartWallet Backend

Spring Boot REST API for SmartWallet.

## Stack

- Java 21
- Spring Boot
- Spring Web MVC
- Spring Security
- Spring Data JPA
- PostgreSQL
- Flyway
- Maven Wrapper
- JWT authentication
- OpenAPI / Swagger
- SMTP email delivery
- H2 for automated tests

## Configuration

Private configuration is supplied through environment variables. Never commit real values.

Typical development variables include:

```text
DB_URL=jdbc:postgresql://localhost:5432/smartwallet_db
DB_USERNAME=smartwallet_app
DB_PASSWORD=<private>
JWT_SECRET=<private>
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=<private>
MAIL_PASSWORD=<private>
MAIL_FROM=<private>
```

The development profile is:

```text
dev
```

## Run

From `backend/`:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

Default local server:

```text
http://localhost:8080
```

Swagger:

```text
http://localhost:8080/swagger-ui/index.html
http://localhost:8080/v3/api-docs
```

## Automated Tests

```bash
./mvnw clean test
```

Tests use an isolated H2 test profile and do not replace the PostgreSQL development configuration.

## Flyway Migrations

Location:

```text
src/main/resources/db/migration
```

Current history:

```text
V1__create_initial_schema.sql
V2__add_email_authentication.sql
V3__add_user_language_preference.sql
V4__add_wallet_currency_and_seed_categories.sql
V5__archive_other_default_categories.sql
V6__prepare_transactions_for_history.sql
V7__add_planning_foundation.sql
```

Purpose:

- **V1** — initial users, wallets, categories, transactions, budgets, preferences and refresh tokens.
- **V2** — pending email verification, `email_verified_at`, and secure `email_action_codes`.
- **V3** — user language preference and legacy preference-row backfill.
- **V4** — wallet currency, category display order, and default category seeds.
- **V5** — archives generic system `Other` categories while preserving historical references.
- **V6** — transaction calendar date, active/archive status, optimistic version, client request id and history/search indexes.
- **V7** — budget archive/version support and the `planned_expenses` table.

Applied migrations must never be modified. The next schema migration, if one is ever required, must be V8 or later.

## Authentication and Account Security

Implemented flows:

- registration
- six-digit email verification
- verification-code resend with cooldown
- login
- JWT access-token authentication
- refresh-token rotation/refresh flow
- logout and revocation
- forgot password
- password-reset code verification
- one-time password-reset token
- password update and active refresh-token revocation
- authenticated profile retrieval/update
- authenticated preferences retrieval/update

Important security rules:

- BCrypt for password hashing.
- Verification/reset codes are never stored in plaintext.
- Refresh tokens are persisted only as hashes.
- Sensitive values are never returned in normal financial responses.
- Protected endpoints resolve the authenticated user server-side.
- Financial ownership is enforced through the authenticated user's wallet.
- Raw internal exceptions and SQL/database details are not exposed to clients.

## Core Finance Model

### Wallet

Each user owns exactly one personal wallet.

The effective balance is derived from active transactions:

- Income adds to balance.
- Expense subtracts from balance.
- Archived transactions no longer affect balance.

### Categories

Categories can be:

- shared system categories
- authenticated-user custom categories

Historical references are preserved even when a category is archived.

### Transactions

Implemented:

- create
- list/history
- search/filter/pagination
- details
- edit
- soft archive/delete
- optimistic versioning
- idempotent create via `clientRequestId`

Only active transactions contribute to financial calculations.

### Budgets

A budget belongs to the authenticated user's wallet and an expense category.

Rules:

- positive limit with two-decimal precision
- budget month stored as the first day of the month
- creation only for the current or a future month
- one active budget per wallet/category/month
- soft archive via status
- optimistic versioning
- spent calculated from active expense transactions in the same category/month
- related-expense endpoint returns the transactions counted by the budget

### Planned Expenses

A planned expense is an expected future payment.

Rules:

- positive amount
- expense category only
- new due date cannot be in the past
- statuses: `UPCOMING`, `PAID`, `CANCELLED`, `ARCHIVED`
- recurrence: `NONE`, `WEEKLY`, `MONTHLY`, `YEARLY`
- create idempotency through `create_client_request_id`
- payment idempotency through `payment_client_request_id`
- optimistic versioning
- Mark as Paid creates the real expense transaction and marks the plan Paid inside one database transaction
- a recurring paid plan may create the next occurrence according to the recurrence rule

### Dashboard and Weekly Insights

`GET /api/v1/dashboard` returns server-calculated authenticated-user data, including:

- current balance
- Safe to Spend
- upcoming planned-expense summary
- budget warning
- Weekly Insights

Safe to Spend:

```text
current balance
- outstanding upcoming planned expenses through the current month end
```

Weekly Insights include:

- current-week expense spending
- equivalent elapsed-period previous-week comparison
- increase/decrease percentage when a valid previous comparison exists
- highest spending category
- active-budget performance
- planned expenses due within the next 14 days

Safe to Spend and Weekly Insights are calculated values and are not database entities.

## REST API Summary

### Public authentication

```text
POST /api/v1/auth/register
POST /api/v1/auth/verify-email
POST /api/v1/auth/resend-verification-code
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/forgot-password
POST /api/v1/auth/resend-password-reset-code
POST /api/v1/auth/verify-password-reset-code
POST /api/v1/auth/reset-password
```

### Protected account

```text
POST  /api/v1/auth/logout
GET   /api/v1/users/me
PATCH /api/v1/users/me
GET   /api/v1/users/me/preferences
PUT   /api/v1/users/me/preferences
```

### Wallet and categories

```text
GET /api/v1/wallet
GET /api/v1/categories
```

Category-management endpoints are exposed by the category controller according to the current application flow.

### Transactions

```text
POST   /api/v1/transactions
GET    /api/v1/transactions
GET    /api/v1/transactions/{transactionId}
PATCH  /api/v1/transactions/{transactionId}
DELETE /api/v1/transactions/{transactionId}
```

### Budgets

```text
POST   /api/v1/budgets
GET    /api/v1/budgets?month=YYYY-MM-01
GET    /api/v1/budgets/{budgetId}
GET    /api/v1/budgets/{budgetId}/expenses?size=5
PATCH  /api/v1/budgets/{budgetId}
DELETE /api/v1/budgets/{budgetId}?version=<version>
```

### Planned Expenses

```text
POST   /api/v1/planned-expenses
GET    /api/v1/planned-expenses?status=UPCOMING&page=0&size=20
GET    /api/v1/planned-expenses/{plannedExpenseId}
PATCH  /api/v1/planned-expenses/{plannedExpenseId}
POST   /api/v1/planned-expenses/{plannedExpenseId}/cancel
POST   /api/v1/planned-expenses/{plannedExpenseId}/mark-paid
DELETE /api/v1/planned-expenses/{plannedExpenseId}?version=<version>
```

### Dashboard

```text
GET /api/v1/dashboard
```

All finance endpoints are protected.

## Data Integrity

- Money uses `NUMERIC(19,2)` / `BigDecimal`.
- Resource ownership is checked server-side.
- Transactions, budgets and planned expenses use soft archive/state semantics where appropriate.
- Optimistic versions detect stale edits.
- Client-request UUIDs protect critical operations from accidental duplicate submissions.
- Planned payment state has database constraints tying `PAID` to payment date, generated transaction and payment request id.
- Foreign keys preserve category/transaction integrity.

## Error Handling

The API returns controlled validation/authentication/conflict/not-found responses.

Internal implementation details, stack traces, database credentials, SQL statements and tokens must not be exposed to the mobile user.

## Database Documentation

Final Phase 5 ERD:

```text
../docs/database/SmartWallet ERD v3 — Planning.png
```

The ERD contains persisted entities only. Safe to Spend and Weekly Insights are intentionally not database tables.
