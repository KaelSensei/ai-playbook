# Dev Squad — Multi-Agent Setup

Multi-agent setup for TypeScript/React development with strict Canon TDD and asynchronous code
review supervised by the Tech Lead.

> **Tool-agnostic**: works with Claude Code, Cursor, or any AI tool that reads `.claude/` or
> `.cursor/` config directories.

## Agents

| Agent          | Role                                                                     |
| -------------- | ------------------------------------------------------------------------ |
| `tech-lead`    | Sets standards, writes technical brief, arbitrates, reviews architecture |
| `dev-senior-a` | Implements with Canon TDD: test list → RED → GREEN → REFACTOR            |
| `dev-senior-b` | Async reviewer: reads tests before code, always                          |

## Install

```bash
cd your-project/

# For Claude Code (default)
bash /path/to/dev-squad-v2/install.sh

# For Cursor
bash /path/to/dev-squad-v2/install.sh .cursor

# Then fill in the foundation docs in your target directory
```

## Workflow

```
1. /brief [feature]        → Tech Lead writes the technical brief
2. /build [spec]           → Dev-a implements TDD, opens PR
3. /review-pr [PR#]        → Dev-b async reviews (tests → code)
4. /arbitrate [conflict]   → Tech Lead decides + ADR
```

## Skills

| Skill                   | Content                                                                     |
| ----------------------- | --------------------------------------------------------------------------- |
| `canon-tdd`             | RED-GREEN-REFACTOR, test list, test doubles, builders, async, error testing |
| `clean-architecture`    | Hexagonal, ports/adapters, use cases, domain events, error handling         |
| `typescript-patterns`   | Result type, branded types, Zod, utility types, discriminated unions        |
| `code-review-standards` | Severity levels, checklist per layer, common TS bugs, performance           |
| `api-design-ts`         | REST conventions, response format, Zod middleware, JWT/RBAC                 |
| `react-patterns`        | Custom hooks, forms, error boundary, Testing Library, context, performance  |
| `testing-patterns-ts`   | Test pyramid, DB integration, supertest, hook testing                       |
