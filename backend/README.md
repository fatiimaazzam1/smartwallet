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