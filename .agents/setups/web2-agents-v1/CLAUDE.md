# Web2 Engineering Workspace

## Stack

<!-- Fill in before first session -->

- Language: (e.g. TypeScript / Python / Go)
- Framework: (e.g. Next.js / NestJS / FastAPI / Rails)
- Database: (e.g. PostgreSQL / MySQL / MongoDB)
- ORM: (e.g. Prisma / TypeORM / SQLAlchemy)
- Testing: (e.g. Jest / Vitest / Pytest / RSpec)
- CI/CD: (e.g. GitHub Actions / GitLab CI)
- Hosting: (e.g. Vercel / AWS / GCP / Railway)

---

## Agent Team

<!-- Parsed by orchestrator on every flow.
     Has this section? → parallel specialist pipeline.
     Missing?         → generic pipeline only.
     Remove rows for agents not needed on this project. -->

| AGENT             | PERSONA              | CONTEXT DOCS                                                | SKILLS                                                        |
| ----------------- | -------------------- | ----------------------------------------------------------- | ------------------------------------------------------------- |
| product-owner     | product-owner.md     | project-architecture.md                                     | team--skill-review                                            |
| ux-designer       | ux-designer.md       | project-architecture.md                                     | team--skill-review                                            |
| tech-lead         | tech-lead.md         | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, team--skill-review              |
| architect         | architect.md         | project-architecture.md, data-architecture.md, constants.md | clean-code, api-design, database-patterns, team--skill-review |
| spec-writer       | spec-writer.md       | project-architecture.md, data-architecture.md               | clean-code, testing-patterns, team--skill-lookup              |
| dev-senior-a      | dev-senior-a.md      | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, api-design, team--skill-review  |
| dev-senior-b      | dev-senior-b.md      | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, api-design, team--skill-review  |
| qa-engineer       | qa-engineer.md       | project-architecture.md, data-architecture.md               | testing-patterns, team--skill-review                          |
| security-reviewer | security-reviewer.md | project-architecture.md, constants.md                       | security-web2, team--skill-review                             |
| data-engineer     | data-engineer.md     | project-architecture.md, data-architecture.md               | database-patterns, team--skill-review                         |
| qa-automation     | qa-automation.md     | project-architecture.md, constants.md                       | observability, team--skill-review                             |
| scribe            | scribe.md            | project-architecture.md, data-architecture.md, constants.md | team--skill-lookup                                            |
| devops-engineer   | devops-engineer.md   | project-architecture.md, constants.md                       | team--skill-review                                            |

---

## Flows

| Command               | When to use it                                              |
| --------------------- | ----------------------------------------------------------- |
| `/task <description>` | Universal entry point — the orchestrator decides everything |
| `/story <need>`       | Turn a need into user stories + ACs                         |
| `/spec <story>`       | Produce a technical spec + test list                        |
| `/build <spec>`       | Implement in strict TDD, step by step                       |
| `/review`             | Parallel review of any diff                                 |
| `/check`              | QA + security + data on the final diff                      |
| `/qa [mode]`          | Smoke / E2E / Perf / Load — coupled with observability      |
| `/pr <feature>`       | Create PR, review, auto-merge, document                     |

---

## TDD — Absolute rule

```
RED   → write ONE failing test
GREEN → minimum code to make it pass
BLUE  → refactor without breaking the tests
```

No production code without a failing test first. dev-senior-b reviews the test BEFORE reviewing the
code.

---

## Skill Resolution (three-tier, highest wins)

| Priority    | Path                        |
| ----------- | --------------------------- |
| 1 — HIGHEST | `<project>/.claude/skills/` |
| 2 — MEDIUM  | `.claude/skills/`           |
| 3 — LOWEST  | `~/.claude/skills/`         |
