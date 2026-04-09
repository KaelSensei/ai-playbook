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

| `/qa [mode]` | Smoke / E2E / Perf / Load — couplé observabilité | | `/pr <feature>` | Créer PR,
review, merge auto, documenter | | `/task <description>` | Point d'entrée universel — orchestrateur
décide tout | | Command | Quand l'utiliser | |---|---| | `/story <besoin>` | Transformer un besoin
en user stories + ACs | | `/spec <story>` | Produire une spec technique + test list | |
`/build <spec>` | Implémenter en TDD strict, step by step | | `/review` | Review parallèle de
n'importe quel diff | | `/check` | QA + sécurité + data sur le diff final |

---

## TDD — Règle absolue

```
RED   → écrire UN test qui échoue
GREEN → minimum de code pour le faire passer
BLUE  → refactorer sans casser les tests
```

Aucun code de production sans test qui échoue d'abord. dev-senior-b review le test AVANT de review
le code.

---

## Skill Resolution (three-tier, highest wins)

| Priorité    | Chemin                     |
| ----------- | -------------------------- |
| 1 — HIGHEST | `<projet>/.claude/skills/` |
| 2 — MEDIUM  | `.claude/skills/`          |
| 3 — LOWEST  | `~/.claude/skills/`        |
