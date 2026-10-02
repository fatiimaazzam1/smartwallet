# SmartWallet

SmartWallet is a full-stack personal-finance mobile application built with Flutter and Java Spring Boot.

It helps a user securely track income and expenses, monitor the wallet balance, organize transactions by category, create monthly budgets, plan future expenses, calculate Safe to Spend, and review weekly spending insights.

> SmartWallet is a personal tracking application. It does not connect to banks and does not process real money transfers.

## Product Vision

SmartWallet is a secure personal spending coach for users who want a simple view of what they have, what they spent, what is planned next, and whether their current spending is still within budget.

The application combines actual transactions with future planned expenses so the user can make better day-to-day spending decisions without pretending to be a banking or payment platform.

## Problem Statement

Personal finances are often tracked across notes, spreadsheets, banking screenshots, or memory. This makes it difficult to answer practical questions such as:

- How much money do I currently have?
- Where did I spend the most this week?
- Am I close to exceeding a monthly category budget?
- Which payments are coming soon?
- How much is realistically safe to spend before the end of the month?

SmartWallet centralizes these decisions in one authenticated mobile application backed by consistent server-side financial rules.

## Target Users

The MVP is intended for:

- students
- recent graduates
- young professionals
- users who want lightweight personal income/expense tracking
- users who want budgets and planned-expense awareness without bank integration

## Spending-Coach User Stories

- As a user, I want to record income and expenses so that my wallet balance stays understandable.
- As a user, I want to edit or delete an incorrect transaction and have dependent calculations update correctly.
- As a user, I want to set a monthly category budget so that I can monitor spending against a limit.
- As a user, I want a warning when a budget reaches my chosen threshold.
- As a user, I want to record future planned expenses so that expected payments are visible before they happen.
- As a user, I want to mark a planned expense as paid so that the real expense transaction is created once and the plan moves to Paid.
- As a user, I want Safe to Spend so that upcoming obligations are considered before I decide how much I can spend.
- As a user, I want Weekly Insights so that I can compare recent spending, identify my highest spending category, review budget performance, and see payments due soon.
- As a user, I want English and Arabic support so that I can use the application in my preferred supported language.
- As a user, I want my financial records isolated from other accounts.

## Out of Scope for the MVP

The current SmartWallet MVP intentionally does not include:

- real bank-account integration
- real money transfers
- credit/debit card processing
- Stripe or other payment-gateway processing
- shared wallets or member invitations
- admin financial controls
- investment or trading features
- receipt OCR/scanning
- biometric authentication
- push-notification infrastructure
- multiple wallet currencies with live FX conversion
- PDF financial-report export

These can be future enhancements only after the current secure personal-finance workflow remains stable.

## Current Status

The current application includes the complete MVP and spending-coach flow:

- Registration, email verification, login, secure session restoration, logout
- Forgot-password and password-reset flow
- Authenticated profile and user preferences
- English and Arabic localization with RTL support
- One personal wallet per user
- System and user-owned categories
- Transaction create, history, search/filter, details, edit, archive/delete
- Monthly category budgets with real spending, remaining amount, progress and warnings
- Planned Expenses with Upcoming, Paid and Cancelled states
- None, Weekly, Monthly and Yearly recurrence
- Atomic Mark as Paid flow that creates the real expense transaction
- Home dashboard with current balance and Safe to Spend
- Upcoming planned-expense count and total
- Weekly Insights with real spending comparison, highest category, budget performance and upcoming plans
- Real-device Android QA and automated Flutter/backend tests

## Core Business Rules

### Wallet balance

The backend is the source of truth for financial state.

- Income increases the wallet balance.
- Expense decreases the wallet balance.
- Editing or archiving a transaction recalculates the effective balance through active transaction data.
- Financial values use decimal storage (`NUMERIC(19,2)` / `BigDecimal`).

### Budgets

A budget is a monthly spending limit for one expense category.

- Only current or future months can be used for new budgets.
- Only one active budget can exist for the same wallet, category and month.
- `spent` is calculated from active expense transactions for the budget category and month.
- `remaining = limit - spent`.
- Budget warnings respect the authenticated user's warning preference and threshold.
- A budget enters warning state when its spending percentage reaches the configured warning threshold.
- A budget is over limit only when actual spending exceeds its limit; being in warning state does not mean it is already over budget.
- Archived budgets are excluded from active budget lists.

### Planned Expenses

A Planned Expense represents an expected future payment, not money that has already left the wallet.

- New planned expenses cannot be created with a past due date.
- Existing unpaid plans can become overdue naturally.
- Creating or editing an upcoming plan does not change the wallet balance.
- Mark as Paid creates the real expense transaction and marks the plan Paid atomically.
- Cancelled plans remain available in history.
- Supported recurrence: None, Weekly, Monthly and Yearly.

### Safe to Spend

Safe to Spend is calculated by the backend from real financial data.

```text
Safe to Spend =
Current Wallet Balance
- Outstanding Upcoming Planned Expenses through the current month end
```

It is calculated, not stored as a database column.

### Weekly Insights

Weekly Insights are calculated from existing authenticated-user data and are not stored as a separate entity.

The current insights include:

- current-week expense spending
- comparison with the equivalent elapsed period of the previous week
- increase/decrease percentage when a meaningful previous value exists
- highest spending category for the current week
- active-budget performance
- Upcoming Planned Expenses due within the next 14 days

When previous-week spending is zero, SmartWallet uses a neutral no-comparison state instead of inventing a percentage.

## Technology Stack

### Mobile

- Flutter
- Dart
- Provider
- GoRouter
- Dio
- Flutter Secure Storage
- Shared Preferences
- Flutter Localizations / ARB
- Intl

### Backend

- Java 21
- Spring Boot
- Spring Security
- Spring Data JPA
- PostgreSQL
- Flyway
- JWT authentication
- Maven
- OpenAPI / Swagger
- SMTP email delivery
- H2 for isolated automated tests

## Repository Structure

```text
smartwallet/
├── backend/
│   ├── src/main/java/com/smartwallet/backend/
│   ├── src/main/resources/db/migration/
│   └── README.md
├── mobile/
│   ├── lib/
│   ├── test/
│   └── README.md
├── docs/
│   └── database/
└── README.md
```

## Database

Flyway migrations are append-only.

Current migration history:

```text
V1__create_initial_schema.sql
V2__add_email_authentication.sql
V3__add_user_language_preference.sql
V4__add_wallet_currency_and_seed_categories.sql
V5__archive_other_default_categories.sql
V6__prepare_transactions_for_history.sql
V7__add_planning_foundation.sql
```

Applied migrations V1-V7 must never be edited. Any future schema change must use V8 or later.

The final Phase 5 ERD is stored under:

```text
docs/database/SmartWallet ERD v3 — Planning.png
```

## Main API Areas

Protected finance data is always resolved from the authenticated user. The mobile client does not choose the authoritative user or wallet.

```text
/api/v1/auth
/api/v1/users/me
/api/v1/users/me/preferences
/api/v1/wallet
/api/v1/categories
/api/v1/transactions
/api/v1/budgets
/api/v1/planned-expenses
/api/v1/dashboard
```

See `backend/README.md` for backend details.

## Local Development

### Backend

Configure private values as environment variables. Do not commit secrets.

Then from `backend/`:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### Flutter

From `mobile/`:

```bash
flutter pub get
flutter gen-l10n
flutter run --dart-define=API_BASE_URL=http://<BACKEND_HOST>:8080
```

For a physical Android device, the phone must be able to reach the development computer on the local network. Do not use `127.0.0.1` as the PC backend address on a physical phone.

## Quality Checks

Backend:

```bash
cd backend
./mvnw clean test
```

Flutter:

```bash
cd mobile
flutter gen-l10n
flutter analyze
flutter test
```

The project has also been manually validated on a real Android device across authentication, transactions, budgets, planned expenses, dashboard calculations, weekly insights, localization, persistence, confirmations, error states and navigation.

## Security

SmartWallet follows these rules:

- passwords are hashed using BCrypt
- raw passwords are never persisted
- refresh tokens are stored server-side only as hashes
- verification and password-reset codes are not stored in plaintext
- the Flutter refresh token is kept in secure storage
- access tokens, refresh tokens, reset tokens, email codes and credentials must never be logged or committed
- protected finance endpoints use the authenticated principal
- wallet ownership is enforced server-side
- foreign financial resource IDs are not trusted
- optimistic version checks protect editable finance records
- client request IDs provide idempotency for critical create/payment operations
- Mark as Paid is transactional to prevent partially completed payments
- database and internal exception details are not exposed to the mobile UI

## Languages

- English
- Arabic
- System language with English fallback for unsupported locales

## License / Purpose

SmartWallet was developed as a personal-finance software project demonstrating full-stack mobile development, secure REST API design, database migrations, financial business logic, localization, testing and software-engineering practices.
