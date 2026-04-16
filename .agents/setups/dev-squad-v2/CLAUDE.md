# Dev Squad

## Stack

- Language: TypeScript 5.x — strict mode required
- Runtime: Node.js 20 LTS
- Frontend: React 18 + TypeScript
- Tests: Vitest + React Testing Library
- ORM: Prisma 5.x
- HTTP: Express 4.x
- Validation: Zod
- Lint: ESLint + Prettier

## Agent Team

| Agent          | Role                                 | Skills                                                                    |
| -------------- | ------------------------------------ | ------------------------------------------------------------------------- |
| `tech-lead`    | Standards + architecture arbitration | clean-architecture, typescript-patterns, code-review-standards            |
| `dev-senior-a` | Canon TDD implementation             | canon-tdd, clean-architecture, typescript-patterns                        |
| `dev-senior-b` | Async review (tests before code)     | canon-tdd, clean-architecture, typescript-patterns, code-review-standards |

## Flows

| Command                     | Description                                                    |
| --------------------------- | -------------------------------------------------------------- |
| `/brief [feature]`          | Tech Lead produces technical brief                             |
| `/build [spec]`             | Dev-a implements with TDD, opens PR                            |
| `/review-pr [PR#]`          | Dev-b async reviews the PR                                     |
| `/arbitrate [disagreement]` | Tech Lead arbitrates + ADR                                     |
| `/auto [task]`              | Unattended: chains brief → build → review-pr, opens a draft PR |

## Canon TDD — Non-Negotiable

```
BEFORE CODING : complete test list
RED   : ONE failing test — must fail by assertion, not import error
GREEN : minimum code to pass — all tests must stay green
BLUE  : refactor only if duplication found
COMMIT: one commit per test list item
```

Dev-b reads `*.test.ts` BEFORE production code. Always.

## Architecture

```
domain/          → zero external deps. Entities, VOs, errors, events.
application/     → use cases + ports (interfaces). Orchestrates domain.
infrastructure/  → adapters: Prisma, email, events, cache.
presentation/    → HTTP controllers, DTOs, middlewares. No business logic.
```

Absolute rule: imports only point inward. `presentation` imports `application`. Never the reverse.

## Code Review Severity Levels

```
[BLOCKER]    → must be fixed before merge. Bug, security, arch violation.
[SHOULD]     → should be fixed, non-blocking.
[SUGGESTION] → optional improvement.
[PRAISE]     → explicitly positive. Always at least one per review.
[QUESTION]   → needs clarification.
```
