# Project Architecture

<!-- last-verified: YYYY-MM-DD -->

## SUMMARY (fill in — loaded by all agents)

[Application]: [one-line description] [Domain]: [main business domain] [Stack]: TypeScript / Node.js
/ React [Auth]: [JWT | sessions | OAuth] [Key invariant]: [most important business rule of the
system] [Watch out for]: [what you need to know before touching the code]

---

## Architecture

### Layers

```
src/
├── domain/        # Entities, Value Objects, Events, Domain errors
├── application/   # Use Cases, Ports (interfaces)
├── infrastructure/ # Adapters (Prisma, SMTP, S3, etc.)
└── presentation/  # HTTP Controllers, DTOs, Middlewares
```

### Bounded Contexts

<!-- List the business contexts if applicable -->

### API Contracts

<!-- Main routes and their associated use cases -->

### Architecture Rules

1. domain/ does not depend on anything external
2. application/ only depends on domain/
3. Use cases receive their dependencies via injection
4. React components delegate logic to hooks/use cases
5. No business logic in controllers

---

## Modules / Features

| Module   | Responsibility   | Status                          |
| -------- | ---------------- | ------------------------------- |
| [module] | [responsibility] | [stable / in progress / legacy] |
