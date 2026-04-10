# Project Architecture

<!-- last-verified: YYYY-MM-DD -->

## SUMMARY (fill in — loaded by all agents)

[Application]: [one-line description] [Domain]: [main business domain] [Stack]: TypeScript / Node.js
/ React [Auth]: [JWT | sessions | OAuth] [Core invariant]: [the most important business rule in the
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

<!-- List business contexts if applicable -->

### API Contracts

<!-- Main routes and their associated use cases -->

### Architecture Rules

1. domain/ has no external dependencies
2. application/ depends only on domain/
3. Use cases receive their dependencies via injection
4. React components delegate logic to hooks/use cases
5. No business logic in controllers

---

## Modules / Features

| Module   | Responsibility   | Status                          |
| -------- | ---------------- | ------------------------------- |
| [module] | [responsibility] | [stable / in progress / legacy] |
