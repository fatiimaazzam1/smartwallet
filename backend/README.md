# SmartWallet Backend

Spring Boot REST API for the SmartWallet personal finance mobile application.

## Technology Stack

- Java 21
- Spring Boot
- Spring Web MVC
- Spring Security
- Spring Data JPA
- PostgreSQL
- Flyway
- Maven
- JWT authentication
- OpenAPI and Swagger UI
- SMTP email delivery

## Requirements

Before running the backend, install:

- Java JDK 21
- PostgreSQL
- Git
- Maven Wrapper support

## Database Configuration

The local PostgreSQL database used by the project is:

```text
Database: smartwallet_db
Application role: smartwallet_app
Port: 5432
```

Database passwords and private credentials must never be committed to GitHub.

## Environment Variables

SmartWallet reads private configuration values from environment variables.

Configure the following variables before starting the backend:

```text
DB_URL=jdbc:postgresql://localhost:5432/smartwallet_db
DB_USERNAME=smartwallet_app
DB_PASSWORD=your-private-database-password
JWT_SECRET=your-private-jwt-secret
```

Do not replace these example values with real passwords or secrets inside this
file.

## Email Configuration

The authentication flow sends email-verification and password-reset codes
through SMTP.

Configure the following environment variables:

```text
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your-email-address
MAIL_PASSWORD=your-private-app-password
MAIL_FROM=your-email-address
```

For Gmail development accounts, enable two-step verification and use a Google
App Password instead of the regular Google Account password.

Email credentials must never be committed to GitHub.

## Local Development Profile

The backend uses the following Spring profile for local development:

```text
dev
```

In Eclipse, open the Spring Boot Run Configuration and add this program
argument:

```text
--spring.profiles.active=dev
```

Add the database, JWT, and email environment variables to the Environment
section of the same Run Configuration.

## Running the Backend

From the `backend` directory, run:

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

The required environment variables must be available in the same terminal
session.

The backend starts by default at:

```text
http://localhost:8080
```

## Running the Tests

From the `backend` directory, run:

```bash
./mvnw clean test -Dspring.profiles.active=dev
```

A successful execution ends with:

```text
BUILD SUCCESS
```

## Flyway Database Migrations

Flyway migration files are located in:

```text
src/main/resources/db/migration
```

The current migrations are:

```text
V1__create_initial_schema.sql
V2__add_email_authentication.sql
```

`V1__create_initial_schema.sql` creates the initial SmartWallet database
foundation.

`V2__add_email_authentication.sql` adds email verification and password-reset
database support.

Applied Flyway migrations must never be modified.

Every future database change must use a new migration with the next available
version number.

## OpenAPI and Swagger UI

After starting the backend, Swagger UI is available at:

```text
http://localhost:8080/swagger-ui/index.html
```

The generated OpenAPI specification is available at:

```text
http://localhost:8080/v3/api-docs
```

Swagger automatically discovers available REST controllers and displays their
endpoints after the application starts.

Protected endpoints can use the JWT Bearer authorization option provided in
Swagger UI.

## Authentication Features

The SmartWallet backend currently supports:

- User registration
- Email verification using a six-digit code
- Verification-code resend with cooldown protection
- Login using email and password
- JWT access-token authentication
- Database-backed refresh tokens
- Access-token refresh
- Logout and refresh-token revocation
- Forgot-password email delivery
- Password-reset code resend
- Password-reset code verification
- Short-lived one-time password-reset tokens
- Secure password update
- Revocation of existing refresh tokens after password reset
- Retrieval of the currently authenticated user

## Authentication API Endpoints

The authentication controller uses the following base path:

```text
/api/v1/auth
```

### Public Authentication Endpoints

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

These endpoints are public because users may need to register, verify their
email, log in, refresh an access token, or recover their password without
already having a valid JWT access token.

The endpoints still validate their required credentials, codes, and tokens.

### Protected Authentication Endpoints

```text
POST /api/v1/auth/logout
GET /api/v1/users/me
```

Protected endpoints require a valid JWT access token in the HTTP authorization
header:

```text
Authorization: Bearer <access-token>
```

## Registration and Email Verification Flow

The registration and email-verification flow works as follows:

```text
User registration
→ Account created with PENDING_VERIFICATION status
→ Six-digit verification code sent by email
→ User submits the verification code
→ Account becomes ACTIVE
→ User can log in
```

An account with the `PENDING_VERIFICATION` status cannot authenticate until
email verification is completed.

After successful email verification:

```text
account_status = ACTIVE
email_verified_at = not null
```

A verification code can only be used once.

## Password-Reset Flow

The password-reset flow works as follows:

```text
Forgot-password request
→ Six-digit password-reset code sent by email
→ User submits the six-digit code
→ Backend verifies the code
→ Backend creates a short-lived reset token
→ User submits the reset token with the new password
→ Password is updated
→ Reset token becomes used
→ Existing refresh tokens are revoked
→ User logs in again using the new password
```

The password-reset token does not provide normal access to the account.

It can only authorize the final password-reset operation.

## Password-Reset Code Rules

Password-reset and email-verification codes use the following rules:

```text
Code length: 6 digits
Expiration: 10 minutes
Resend cooldown: 60 seconds
Maximum failed attempts: 5
```

When a new code is issued after the cooldown, the previous active code is
invalidated.

A code is also invalidated when:

- It expires and is checked
- It reaches the maximum number of failed attempts
- It is replaced by a newer code

## Authentication Token Types

SmartWallet uses three different token types.

### Access Token

The access token is a signed JWT used to access protected API endpoints.

The access token:

- Is generated by the backend after login
- Has a short lifetime
- Is sent by the client with protected requests
- Is not stored in the database
- Is validated using its signature and expiration

### Refresh Token

The refresh token keeps a login session active after the access token expires.

The refresh token:

- Is generated by the backend after login
- Has a longer lifetime than the access token
- Can generate a new access token
- Can be revoked during logout
- Can be revoked after a successful password reset
- Is stored in the database only as a SHA-256 hash

The raw refresh token is returned to the client, while the database stores only
its hash.

### Password-Reset Token

The password-reset token is generated after a correct six-digit
password-reset code is verified.

The password-reset token:

- Is generated by the backend
- Is short-lived
- Expires after 10 minutes
- Can be used only once
- Can only authorize a password change
- Is stored in the database only as a SHA-256 hash

The raw password-reset token is returned once to the client.

The database stores only the value of:

```text
SHA-256(raw password-reset token)
```

## Authentication Security

### Password Storage

User passwords are stored using BCrypt.

Raw passwords are never stored in the database.

### Six-Digit Code Storage

Email-verification and password-reset codes are stored using BCrypt.

A six-digit code has a limited number of possible values, so BCrypt is used to
make offline guessing slower.

The database never stores the raw six-digit code.

### Refresh-Token Storage

Refresh tokens are generated using a cryptographically secure random
generator.

Only the SHA-256 refresh-token hash is stored in the `refresh_tokens` table.

The raw refresh token is returned to the client and must be stored securely by
the mobile application.

### Password-Reset Token Storage

Password-reset tokens are also generated using a cryptographically secure
random generator.

Only the SHA-256 reset-token hash is stored in:

```text
email_action_codes.action_token_hash
```

The raw reset token is not stored in the database.

### Generic Security Responses

Forgot-password and resend-password-reset-code requests return a generic
response whether or not an eligible account exists.

Invalid password-reset code requests also return a generic error.

This behavior reduces email and account enumeration risks.

## Email Action Status Fields

The `email_action_codes` table tracks the lifecycle of email-verification and
password-reset operations.

### `verified_at`

```text
The six-digit code was submitted correctly.
```

### `used_at`

```text
The operation completed successfully.
```

For password reset, this means the password was changed successfully.

### `invalidated_at`

```text
The operation was cancelled, replaced, expired, or blocked.
```

A successful password-reset operation normally has:

```text
verified_at = not null
used_at = not null
invalidated_at = null
```

An expired, cancelled, replaced, or blocked operation can have:

```text
invalidated_at = not null
```

## Password Reset and Session Revocation

After a successful password reset, all active refresh tokens belonging to the
user are revoked.

This means that old devices and existing sessions cannot continue generating
new access tokens.

After resetting the password, the user must log in again using the new
password.

An already-issued access token may remain valid until its short expiration
time, but its related refresh token can no longer renew the session.

## Authentication Transaction Safety

The final password-reset operation is transactional.

The following actions are completed as one database operation:

```text
Update the password hash
Revoke active refresh tokens
Mark the password-reset action as used
```

If one of these actions fails, the transaction is rolled back to prevent a
partially completed password reset.

## Authentication QA Status

The authentication system has been manually tested using Postman and
PostgreSQL.

Verified scenarios include:

- Registration creates a pending account
- Email-verification code delivery
- Successful email verification
- Login rejection before email verification
- Successful login after email verification
- Verification-code resend cooldown
- Forgot-password email delivery
- Generic forgot-password responses for unknown email addresses
- Password-reset code resend
- Old password-reset code invalidation after resend
- Wrong password-reset code attempts
- Password-reset code expiration checks
- Successful password-reset code verification
- Secure password-reset token generation
- Storage of token hashes instead of raw tokens
- Password confirmation mismatch rejection
- Successful password reset
- Password-reset token reuse rejection
- Old-password login rejection
- New-password login success
- Revocation of previous refresh tokens
- Rejection of revoked refresh tokens
- Protected endpoint access using a valid JWT
- Unauthorized protected endpoint access without a JWT

## Authentication Development Status

```text
Backend authentication implementation: Complete
Email verification: Complete
JWT login and access-token authentication: Complete
Refresh-token support: Complete
Logout and token revocation: Complete
Forgot-password flow: Complete
Password-reset flow: Complete
Manual Postman authentication QA: Complete
Flutter authentication integration: Next milestone
```

## Secrets and Deployment

Private credentials are provided through environment variables and must never
be committed to the repository.

Each developer must configure their own local database, JWT, and email
credentials.

For automated workflows, private values must be stored using GitHub Actions
Secrets.

For production, the hosting platform or server must provide the required
environment variables when the backend starts.

Production environments must use:

- Separate database credentials
- A strong production JWT secret
- Dedicated production email-delivery credentials
- Secure HTTPS communication

The Flutter mobile application must never contain:

```text
Database credentials
SMTP credentials
JWT signing secret
Backend private configuration
```

Flutter communicates only with the SmartWallet REST API.

## Main Project Structure

```text
backend/
├── src/main/java
│   └── Application source code
├── src/main/resources
│   ├── Application configuration
│   └── db/migration
│       └── Flyway database migrations
├── src/test
│   └── Backend tests
├── pom.xml
└── README.md
```