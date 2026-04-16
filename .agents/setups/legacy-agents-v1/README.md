# legacy-agents v1 — Multi-Agent Setup

Multi-agent setup for working on legacy projects. Mapping, characterization tests, safe refactoring,
Strangler Fig.

> **Compatibility:** Claude Code first. Cursor can read a reduced version of this setup, but native
> multi-agent orchestration and hooks do not carry over 1:1. See
> [`../../docs/AGENTS_COMPATIBILITY.md`](../../docs/AGENTS_COMPATIBILITY.md).

This setup is a **workflow bundle**. It installs personas, commands, setup-local skills, and hooks
for one legacy-modernization workflow. It does not replace the base playbook catalog in
`.agents/rules/`, `.agents/commands/`, and `.agents/skills/`.

---

## The Legacy Problem

On a legacy project, the rules of classic development don't apply. You can't do TDD on code without
seams. You can't refactor without a test safety net. You can't rewrite everything at once.

This setup implements Michael Feathers' method (_Working Effectively with Legacy Code_) with a team
of specialized agents.

---

## The Agents

| Agent                     | Role                                                              |
| ------------------------- | ----------------------------------------------------------------- |
| `legacy-analyst`          | Maps modules, identifies seams and risk zones                     |
| `archaeologist`           | Understands the history of the code, recovers inherited decisions |
| `characterization-tester` | Writes tests that pin down existing behavior                      |
| `refactoring-guide`       | Guides micro-incremental refactoring (Fowler catalogue)           |
| `debt-tracker`            | Inventories and prioritizes technical debt                        |
| `dev-senior-a`            | Implements (legacy refactoring or TDD on new code)                |
| `dev-senior-b`            | Critical review — tests the safety net before the code            |
| `architect`               | Strangler Fig, Anti-Corruption Layer, boundaries                  |
| `tech-lead`               | Arbitrates debt vs features, migration consistency                |
| `security-reviewer`       | OWASP + legacy-specific vulnerabilities                           |
| `data-engineer`           | Legacy-aware migrations, dirty data, indexes                      |

---

## Installation

```bash
cd ~/your-legacy-project

# For Claude Code (default — installs into .claude/)
bash /path/to/legacy-agents-v1/install.sh

# For Cursor (installs into .cursor/)
bash /path/to/legacy-agents-v1/install.sh .cursor
```

---

## The 3 docs to fill in

### `.claude/project-architecture.md` (~30 min)

What the system does, the known modules (even partially), the risk zones, **what CANNOT change**.

### `.claude/legacy-map.md` (living — starts empty)

Fills up automatically as you run `/understand`. It's the map of the territory — it grows with each
exploration. Never delete an entry, only annotate.

### `.claude/constants.md` (~10 min)

Known env vars, URLs per environment, toolchain versions. On a legacy codebase, some may be
hardcoded in the code — document where they live.

---

## The Golden Rule

```
NEVER touch legacy code without a test safety net.

Mandatory order:
  /understand → /characterize → /refactor or /strangler

No shortcuts. Not even for "a small change".
```

---

## Usage

```bash
cd your-legacy-project
claude
```

---

### `/understand <module>`

Map a module before any change.

```
/understand src/billing/BillingService.php
```

**What happens:** `legacy-analyst` + `archaeologist` in parallel. One maps dependencies and seams,
the other digs through git history. Result: a module card in `legacy-map.md`, a risk level,
identified seams.

---

### `/characterize <module>`

Write tests that pin down existing behavior.

```
/characterize src/billing/BillingService.php
```

**What happens:**

```
1. Characterization plan established
2. For each behavior:
   a. Test written with intentionally false assertion
   b. Test run → actual value recorded
   c. Test updated with the real value
   d. dev-senior-b reviews the test
3. All tests pass → safety net in place
```

Characterization tests document **what the code does**, not what we think it should do.

---

### `/refactor <target>`

Safe, micro-incremental refactoring.

```
/refactor src/billing/BillingService.php
```

**Prerequisites**: `/understand` + `/characterize` done.

**What happens:**

```
1. Refactoring plan broken into micro-steps (Fowler catalogue)
2. For each step:
   a. dev-senior-a makes ONE minimal change
   b. All tests (characterization included) must pass
   c. dev-senior-b reviews
   d. Atomic commit
3. Final review by all agents
```

If a characterization test goes red → `git revert` immediately.

---

### `/strangler <feature>`

Implement a new feature around the legacy code, without modifying it.

```
/strangler new invoice calculation system
```

**What happens:**

```
1. architect defines the boundary and the Anti-Corruption Layer
2. spec-writer produces the spec + test list for the NEW code
3. dev-senior-a implements in strict TDD (the legacy is never modified)
4. Feature flag for progressive rollout
5. Final review by all agents
```

The legacy stays in place until the new code reaches 100%.

---

### `/debt`

Audit and prioritize technical debt.

```
/debt                          ← global audit
/debt src/billing/             ← audit of a single module
```

**What happens:** `debt-tracker` + `legacy-analyst` analyze and produce an inventory prioritized by
Impact/Effort with a repayment plan.

---

### `/review`

Parallel review by all agents on any diff.

```
/review
/review 42           ← PR number 42
/review staged
```

**Legacy special**: verifies that characterization tests pass and that behavior is preserved if it's
a refactoring.

---

## Two Development Modes

### On existing legacy code

```
1. /understand → map it
2. /characterize → pin down behavior
3. /refactor → restructure without changing behavior
   (each step must leave the tests green)
```

### On new code (Strangler Fig)

```
Strict TDD — Canon TDD (Kent Beck):
RED   → ONE failing test
GREEN → minimum code to pass
BLUE  → refactor without breaking
```

`dev-senior-b` reviews the test BEFORE the code in both cases.

---

## Customizing the team

In `CLAUDE.md`, section `## Agent Team`: remove the lines for agents that aren't relevant.

Minimal example (no frontend, no complex database):

```markdown
| AGENT                   | PERSONA                    | CONTEXT DOCS                                         | SKILLS                                                                      |
| ----------------------- | -------------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------- |
| legacy-analyst          | legacy-analyst.md          | project-architecture.md, legacy-map.md, constants.md | legacy-patterns, technical-debt, team--skill-review                         |
| archaeologist           | archaeologist.md           | project-architecture.md, legacy-map.md               | legacy-patterns, team--skill-lookup                                         |
| characterization-tester | characterization-tester.md | project-architecture.md, legacy-map.md               | testing-patterns, legacy-patterns, team--skill-review                       |
| refactoring-guide       | refactoring-guide.md       | project-architecture.md, legacy-map.md               | refactoring-patterns, legacy-patterns, testing-patterns, team--skill-review |
| dev-senior-a            | dev-senior-a.md            | project-architecture.md, legacy-map.md, constants.md | clean-code, testing-patterns, refactoring-patterns, team--skill-review      |
| dev-senior-b            | dev-senior-b.md            | project-architecture.md, legacy-map.md, constants.md | clean-code, testing-patterns, refactoring-patterns, team--skill-review      |
| tech-lead               | tech-lead.md               | project-architecture.md, legacy-map.md, constants.md | clean-code, technical-debt, team--skill-review                              |
| security-reviewer       | security-reviewer.md       | project-architecture.md, constants.md                | security-web2, team--skill-review                                           |
```

---

## Getting Started Checklist

```
[ ] bash install.sh [target-dir] in your project
[ ] Edit CLAUDE.md → Stack (language, framework, age)
[ ] Fill in <target>/project-architecture.md
[ ] Fill in <target>/constants.md
[ ] Start your AI tool
[ ] Run: /debt   (global overview)
[ ] Then: /understand <riskiest module>
```
