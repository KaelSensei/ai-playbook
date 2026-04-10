# Legacy Engineering Workspace

## Stack

<!-- Fill in before the first session -->

- Language: (e.g. PHP 7.x / Java 8 / Python 2.7 / Node 10)
- Framework: (e.g. Symfony 3 / Spring Boot 1.x / Django 1.x)
- Database: (e.g. MySQL 5.7 / Oracle / SQL Server)
- Test runner: (e.g. PHPUnit / JUnit / pytest — often absent or partial)
- Estimated codebase age: (e.g. 8 years)
- Current coverage: (e.g. ~12%)

---

## Agent Team

| AGENT                   | PERSONA                    | CONTEXT DOCS                                                | SKILLS                                                                                  |
| ----------------------- | -------------------------- | ----------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| orchestrator            | orchestrator.md            | project-architecture.md, legacy-map.md, constants.md        | team--skill-lookup                                                                      |
| legacy-analyst          | legacy-analyst.md          | project-architecture.md, data-architecture.md, constants.md | legacy-patterns, technical-debt, team--skill-review                                     |
| archaeologist           | archaeologist.md           | project-architecture.md, data-architecture.md               | legacy-patterns, team--skill-review                                                     |
| characterization-tester | characterization-tester.md | project-architecture.md, data-architecture.md               | legacy-patterns, testing-patterns, team--skill-review                                   |
| refactoring-guide       | refactoring-guide.md       | project-architecture.md, data-architecture.md               | legacy-patterns, refactoring-patterns, clean-code, testing-patterns, team--skill-review |
| debt-tracker            | debt-tracker.md            | project-architecture.md, data-architecture.md, constants.md | technical-debt, team--skill-review                                                      |
| dev-senior-a            | dev-senior-a.md            | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, refactoring-patterns, team--skill-review                  |
| dev-senior-b            | dev-senior-b.md            | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, refactoring-patterns, team--skill-review                  |
| architect               | architect.md               | project-architecture.md, data-architecture.md, constants.md | legacy-patterns, strangler-fig, clean-code, team--skill-review                          |
| security-reviewer       | security-reviewer.md       | project-architecture.md, constants.md                       | security-web2, team--skill-review                                                       |
| qa-automation           | qa-automation.md           | project-architecture.md, constants.md                       | observability, team--skill-review                                                       |
| scribe                  | scribe.md                  | project-architecture.md, legacy-map.md, constants.md        | team--skill-lookup                                                                      |
| data-engineer           | data-engineer.md           | project-architecture.md, data-architecture.md               | database-patterns, team--skill-review                                                   |
| tech-lead               | tech-lead.md               | project-architecture.md, data-architecture.md, constants.md | legacy-patterns, technical-debt, clean-code, team--skill-review                         |

---

## Flows

| Command                | When to use it                                              |
| ---------------------- | ----------------------------------------------------------- |
| `/task <description>`  | Universal entry point — the orchestrator decides everything |
| `/understand <module>` | Map before touching                                         |
| `/characterize <code>` | Characterization tests on existing code                     |
| `/refactor <target>`   | Safe refactoring with a test safety net                     |
| `/strangler <feature>` | New code around the legacy                                  |
| `/review`              | Legacy-aware review (risk first)                            |
| `/debt`                | Debt audit and prioritization                               |
| `/qa [mode]`           | Smoke / E2E / Perf / Load — paired with observability       |
| `/pr <feature>`        | Create PR, review, auto-merge, document                     |

---

## Fundamental Rule

NEVER touch legacy code without a test safety net. On existing code: UNDERSTAND → CHARACTERIZE →
REFACTOR. On new code: classic TDD (RED → GREEN → BLUE). Strangler Fig: a clean new module AROUND
the legacy, progressive migration.

---

## Skill Resolution

| Priority    | Path                      |
| ----------- | ------------------------- |
| 1 — HIGHEST | <project>/.claude/skills/ |
| 2 — MEDIUM  | .claude/skills/           |
| 3 — LOWEST  | ~/.claude/skills/         |
