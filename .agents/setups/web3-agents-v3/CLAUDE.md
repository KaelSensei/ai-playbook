# Web3 Engineering Workspace

## Stack

<!-- Fill in before first session -->

- Chain: (e.g. Ethereum mainnet + Base)
- Contracts: Solidity ^0.8.24 + Foundry
- Frontend: Next.js + wagmi v2 + viem
- Indexer: (e.g. The Graph / Ponder)
- Node provider: (e.g. Alchemy / QuickNode)

---

## Agent Team

<!-- Parsed by orchestrator on every flow.
     Has this section? → parallel specialist pipeline.
     Missing?         → generic pipeline (spec-writer + architect + rust-reviewer only).
     Remove rows for agents not needed on this project. -->

| AGENT                   | PERSONA                    | CONTEXT DOCS                                                | SKILLS                                                                 |
| ----------------------- | -------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------- |
| smart-contract-engineer | smart-contract-engineer.md | project-architecture.md, data-architecture.md               | solidity-patterns, foundry-testing, defi-protocols, team--skill-review |
| infra-engineer          | infra-engineer.md          | project-architecture.md, constants.md                       | team--skill-review                                                     |
| devops-engineer         | devops-engineer.md         | project-architecture.md, constants.md                       | foundry-testing, team--skill-review                                    |
| frontend-engineer       | frontend-engineer.md       | project-architecture.md, data-architecture.md               | web3-frontend, team--skill-review                                      |
| backend-engineer        | backend-engineer.md        | project-architecture.md, data-architecture.md               | defi-protocols, team--skill-review                                     |
| architect               | architect.md               | project-architecture.md, data-architecture.md, constants.md | solidity-patterns, defi-protocols, team--skill-review                  |
| spec-writer             | spec-writer.md             | project-architecture.md, data-architecture.md               | solidity-patterns, team--skill-lookup                                  |
| qa-automation           | qa-automation.md           | project-architecture.md, constants.md                       | observability, team--skill-review                                      |
| scribe                  | scribe.md                  | project-architecture.md, data-architecture.md, constants.md | team--skill-lookup                                                     |
| rust-reviewer           | rust-reviewer.md           | project-architecture.md                                     | solidity-patterns, team--skill-review                                  |

---

## Flows

| Command               | What it does                                                |
| --------------------- | ----------------------------------------------------------- |
| `/task <description>` | Universal entry point — the orchestrator decides everything |
| `/research <topic>`   | 2 agents in parallel + web access → merged findings         |
| `/spec <feature>`     | Explore → Draft → Parallel review loop → Approved spec      |
| `/implement <spec>`   | Plan → per-step pair-code + review → Verify → Final review  |
| `/review`             | All agents in parallel, read-only, merged verdict           |
| `/qa [mode]`          | Smoke / E2E / Perf / Load — coupled with observability      |
| `/pr <feature>`       | Create PR, review, auto-merge, document                     |

---

## Skill Resolution (three-tier, highest wins)

| Priority    | Path                        | Scope                  |
| ----------- | --------------------------- | ---------------------- |
| 1 — HIGHEST | `<project>/.claude/skills/` | Project-local override |
| 2 — MEDIUM  | `.claude/skills/`           | Workspace              |
| 3 — LOWEST  | `~/.claude/skills/`         | User-global            |

A project can override any workspace skill by placing a same-named `SKILL.md` in its local
`.claude/skills/` directory.

---

## Core Principles

1. Agents always run **in parallel** within a flow — never sequentially
2. Every agent receives **full context**: persona + context docs + resolved skills
3. Verdicts are structured: `APPROVE` | `APPROVE_WITH_CHANGES` | `REQUEST_REDESIGN`
4. **No silent approvals** — unanimous `APPROVE` required before moving on
5. Smart contracts are **adversarial by default** — security review on every change
6. **Tests before code** — TDD always; invariant tests for anything touching value
7. Context docs have a **staleness signal** — agents check `last-verified` date before trusting them
