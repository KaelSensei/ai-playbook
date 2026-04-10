# Project Architecture

<!-- last-verified: YYYY-MM-DD -->
<!--
  STALENESS RULE: if today - last-verified > 30 days → STALE.
  Do not reason from a stale doc — explore the codebase directly.
-->

## System Overview

<!--
  What this application does, who uses it, what value it provides.
  1-2 paragraphs max.
-->

## Architecture Diagram

<!--
  Describe the components and how they connect.
  Example:

  Browser / Mobile
      │ HTTP/WS
  Frontend (Next.js)
      │ REST / GraphQL
  API (NestJS / FastAPI)
      │ ORM
  Database (PostgreSQL)
      │
  Background Jobs (Bull / Celery)
      │
  Cache (Redis)
-->

## Module Map

<!--
  List of main modules/packages and their responsibilities.
  Example:
  src/
  ├── auth/          — authentication, sessions, tokens
  ├── users/         — user account management
  ├── billing/       — subscriptions, payments (Stripe)
  └── notifications/ — emails, push, webhooks
-->

## API Contracts

<!--
  The public interfaces between layers (not the implementation).
  Example:
  - Frontend → API: REST JSON, versioned via /api/v1/
  - API → DB: Prisma ORM, always through the repository layer
  - API → Jobs: BullMQ queues, no direct calls
-->

## Authentication / Authorization

<!--
  How auth works. Who can do what.
  Example:
  - Stateless JWT, 15min access token, 7d refresh token
  - Roles: ADMIN, USER, READONLY
  - All /api/** routes protected except /auth/**
-->

## External Dependencies

<!--
  Service | Role | Failure mode
  Stripe  | Payments | degraded: block new subscriptions, keep active ones
  SendGrid | Emails | degraded: queue emails, retry 3x
  Cloudinary | Media | degraded: upload blocked, existing assets accessible
-->

## Key Invariants

<!--
  What must ALWAYS be true.
  Example:
  - A user cannot have two active subscriptions at the same time
  - Deleted data is soft-deleted, never hard-deleted
  - Every admin action is logged in audit_log
-->

## Known Limitations / Out of Scope

<!--
  What the system intentionally does not handle.
  Limits scope creep during implementation.
-->
