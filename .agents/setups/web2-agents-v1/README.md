# web2-agents v1 — Multi-Agent Setup

Multi-agent setup for web2 development. 11 specialized agents, mandatory TDD, parallel reviews.

> **Compatibility:** Claude Code first. Cursor can read a reduced version of this setup, but native
> multi-agent orchestration and hooks do not carry over 1:1. See
> [`../../docs/AGENTS_COMPATIBILITY.md`](../../docs/AGENTS_COMPATIBILITY.md).

This setup is a **workflow bundle**. It installs personas, commands, setup-local skills, and hooks
for one full-stack team workflow. It does not replace the base playbook catalog in `.agents/rules/`,
`.agents/commands/`, and `.agents/skills/`.

---

## What it is

A simulated engineering team that follows a structured workflow from business need to deployable
code.

| Agent               | Role                                          |
| ------------------- | --------------------------------------------- |
| `product-owner`     | User stories, ACs, scope, saying no           |
| `ux-designer`       | User journeys, wireframes, UI states          |
| `tech-lead`         | Team standards, consistency, arbitration      |
| `architect`         | Module breakdown, API contracts, blast radius |
| `spec-writer`       | Technical spec + exhaustive test list         |
| `dev-senior-a`      | TDD implementation (RED → GREEN → BLUE)       |
| `dev-senior-b`      | Critical review — test first, then code       |
| `qa-engineer`       | Behavioral coverage, edge cases               |
| `security-reviewer` | OWASP, auth, injections, secrets              |
| `data-engineer`     | DB schema, migrations, N+1, indexes           |
| `devops-engineer`   | CI/CD, Docker, deployment, rollback           |

---

## Installation

```bash
cd ~/your-web2-project

# For Claude Code (default — installs into .claude/)
bash /path/to/web2-agents-v1/install.sh

# For Cursor (installs into .cursor/)
bash /path/to/web2-agents-v1/install.sh .cursor
```

---

## Mandatory step: fill in the 3 foundation docs

These 3 files are the shared memory of all the agents. **Without them the agents work blind.** Once
filled in (~1h), you keep them updated as the project evolves.

### `.claude/project-architecture.md` (~30 min)

System overview, modules, authentication, key invariants, external dependencies.

### `.claude/data-architecture.md` (~20 min)

DB schema, relations, indexes, migration strategy, soft delete, sensitive data, caching.

### `.claude/constants.md` (~10 min)

Environment variables, URLs per env, toolchain versions, rate limits, feature flags.

> **Freshness rule**: every doc has a `last-verified: YYYY-MM-DD` line. Agents check this date. If >
> 30 days → they explore the codebase rather than trusting the doc.

---

## Usage

```bash
cd your-web2-project
claude
```

---

### `/story <need>`

Turn a need into user stories with ACs and wireframes.

```
/story allow users to reset their password
```

**What happens:** `product-owner` and `ux-designer` work in parallel. One produces the ACs, the
other the wireframes. They cross-review each other. Result: validated stories ready for `/spec`.

---

### `/spec <story>`

Produce a technical spec with an exhaustive test list. **The test list is the main deliverable — it
drives the entire `/build`.**

```
/spec reset-password
```

**What happens:**

```
1. spec-writer explores the codebase
2. spec-writer drafts the spec + ordered test list
3. You validate the draft
4. All agents review in parallel
5. Loop until unanimous APPROVE
6. Spec saved to .claude/specs/
```

---

### `/build <spec>`

Implement in strict TDD. One test at a time.

```
/build reset-password
```

**What happens (for each item in the test list):**

```
1. dev-senior-a writes ONE test → RED (must fail)
2. dev-senior-b reviews the TEST first
3. dev-senior-a writes the minimum code → GREEN (must pass)
4. All agents review in parallel
5. dev-senior-a refactors → BLUE (tests still green)
6. Commit → next item
```

> Canon TDD (Kent Beck): no production code without a failing test first. dev-senior-b reviews the
> test before the code — always.

---

### `/review`

Parallel review by all agents on any diff.

```
/review              ← latest commit
/review 42           ← PR number 42
/review src/auth/    ← specific files
/review staged       ← staging area
```

---

### `/check`

Targeted quality review before deployment. `qa-engineer` + `security-reviewer` + `data-engineer` in
parallel.

```
/check
```

All 3 verdicts must be `APPROVE` before any prod deployment.

---

## How the agents orchestrate themselves

You don't manage anything manually. Claude Code takes care of it.

```
You type /story, /spec, /build, /review or /check
    ↓
Claude reads CLAUDE.md → knows the list of active agents
    ↓
Claude spawns the agents in parallel (native Task tool)
    ↓
Each agent loads its .md file → knows who it is and what to check
    ↓
Each agent loads the foundation docs → knows your project
    ↓
Each agent returns its structured verdict
    ↓
Claude merges, iterates if needed, and presents the result
```

---

## TDD — Absolute rule

```
RED   → write ONE test that fails for the right reason
GREEN → minimum code to make it pass
BLUE  → refactor without breaking the tests
```

**dev-senior-b reviews the test BEFORE the code.** If the test is bad, the code that follows is too.

The full cycle takes 2-5 minutes per test list item. That's normal. It's the price of code you
actually own.

---

## Customizing the active agents

In `CLAUDE.md`, section `## Agent Team`: remove the rows for agents that aren't relevant to this
project.

Minimal example (backend only, no frontend):

```markdown
| AGENT             | PERSONA              | CONTEXT DOCS                                                | SKILLS                                                        |
| ----------------- | -------------------- | ----------------------------------------------------------- | ------------------------------------------------------------- |
| tech-lead         | tech-lead.md         | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, team--skill-review              |
| architect         | architect.md         | project-architecture.md, data-architecture.md, constants.md | clean-code, api-design, database-patterns, team--skill-review |
| spec-writer       | spec-writer.md       | project-architecture.md, data-architecture.md               | clean-code, testing-patterns, team--skill-lookup              |
| dev-senior-a      | dev-senior-a.md      | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, api-design, team--skill-review  |
| dev-senior-b      | dev-senior-b.md      | project-architecture.md, data-architecture.md, constants.md | clean-code, testing-patterns, api-design, team--skill-review  |
| qa-engineer       | qa-engineer.md       | project-architecture.md, data-architecture.md               | testing-patterns, team--skill-review                          |
| security-reviewer | security-reviewer.md | project-architecture.md, constants.md                       | security-web2, team--skill-review                             |
| data-engineer     | data-engineer.md     | project-architecture.md, data-architecture.md               | database-patterns, team--skill-review                         |
| devops-engineer   | devops-engineer.md   | project-architecture.md, constants.md                       | team--skill-review                                            |
```

---

## Getting Started Checklist

```
[ ] bash install.sh [target-dir] in your project
[ ] Fill in <target>/project-architecture.md
[ ] Fill in <target>/data-architecture.md
[ ] Fill in <target>/constants.md
[ ] Edit CLAUDE.md → Stack + remove unused agents
[ ] Start your AI tool
[ ] Run: /story <first need>
```
