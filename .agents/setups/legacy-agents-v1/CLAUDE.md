# Legacy Engineering Workspace

## Stack

<!-- Renseigner avant la première session -->

- Language: (e.g. PHP 7.x / Java 8 / Python 2.7 / Node 10)
- Framework: (e.g. Symfony 3 / Spring Boot 1.x / Django 1.x)
- Database: (e.g. MySQL 5.7 / Oracle / SQL Server)
- Test runner: (e.g. PHPUnit / JUnit / pytest — souvent absent ou partiel)
- Age estimé du codebase: (e.g. 8 ans)
- Coverage actuelle: (e.g. ~12%)

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

| `/qa [mode]` | Smoke / E2E / Perf / Load — couplé observabilité | | `/pr <feature>` | Créer PR,
review, merge auto, documenter | | `/task <description>` | Point d'entrée universel — orchestrateur
décide tout | | Commande | Quand l'utiliser | |---|---| | `/understand <module>` | Cartographier
avant de toucher | | `/characterize <code>` | Tests de caractérisation sur code existant | |
`/refactor <cible>` | Refactoring sécurisé avec filet de tests | | `/strangler <feature>` | Nouveau
code autour du legacy | | `/review` | Review legacy-aware (risque d'abord) | | `/debt` | Audit et
priorisation de la dette |

---

## Règle Fondamentale

JAMAIS toucher du code legacy sans filet de tests. Sur code existant : UNDERSTAND → CHARACTERIZE →
REFACTOR Sur nouveau code : TDD classique (RED → GREEN → BLUE) Strangler Fig : nouveau module propre
AUTOUR du legacy, migration progressive.

---

## Skill Resolution

| Priorité    | Chemin                   |
| ----------- | ------------------------ |
| 1 — HIGHEST | <projet>/.claude/skills/ |
| 2 — MEDIUM  | .claude/skills/          |
| 3 — LOWEST  | ~/.claude/skills/        |
