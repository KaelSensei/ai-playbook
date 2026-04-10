# Data Architecture

<!-- last-verified: YYYY-MM-DD -->
<!--
  STALENESS RULE: if today - last-verified > 30 days → STALE.
  Check against the real schema before reasoning from this doc.
-->

## Database Schema

<!--
  Main tables, columns, constraints, relations.
  Example:

  users
  ├── id          UUID PK
  ├── email       VARCHAR(255) UNIQUE NOT NULL
  ├── password    VARCHAR(255) NOT NULL (hashed bcrypt)
  ├── role        ENUM('ADMIN','USER') DEFAULT 'USER'
  ├── created_at  TIMESTAMPTZ DEFAULT now()
  └── deleted_at  TIMESTAMPTZ NULL (soft delete)

  subscriptions
  ├── id          UUID PK
  ├── user_id     UUID FK → users.id
  ├── plan        ENUM('FREE','PRO','ENTERPRISE')
  ├── status      ENUM('ACTIVE','CANCELLED','PAST_DUE')
  ├── starts_at   TIMESTAMPTZ NOT NULL
  └── ends_at     TIMESTAMPTZ NULL
-->

## Relations

<!--
  Diagram or list of the important relations.
  Example:
  users 1──* subscriptions
  users 1──* audit_logs
  users *──* teams (via team_members)
-->

## Indexes

<!--
  Existing indexes and their rationale.
  Example:
  - users(email) UNIQUE — login lookup
  - subscriptions(user_id) — frequent join
  - audit_logs(created_at DESC) — chronological pagination
-->

## Migrations Strategy

<!--
  How migrations are managed.
  Example:
  - Prisma Migrate in dev, prisma migrate deploy in prod
  - Zero-downtime: new columns added as nullable first
  - Never DROP COLUMN without a prior data migration
  - Migrations are squashed every 3 months
-->

## Soft Delete Convention

<!--
  How deletions are handled.
  Example:
  - All user-facing entities have deleted_at TIMESTAMPTZ NULL
  - Queries filter WHERE deleted_at IS NULL by default
  - Hard delete only on explicit GDPR request
-->

## Sensitive Data

<!--
  Which data is sensitive and how it is protected.
  Example:
  - Passwords: bcrypt cost 12, never logged
  - Tokens: hashed in the database (SHA-256), raw value never stored
  - PII (email, name): encrypted at-rest on flagged columns
-->

## Caching Strategy

<!--
  What is cached, duration, invalidation.
  Example:
  - Session: Redis, TTL 15min (access) / 7d (refresh)
  - User profile: Redis, TTL 5min, invalidated on update
  - Plan features: in-memory, reloaded on startup
-->

## Query Patterns

<!--
  Frequent or critical queries to document.
  Example:
  - Dashboard: 30-day aggregation, index on created_at required
  - Search: ILIKE on name, prefer full-text search if > 100k rows
-->
