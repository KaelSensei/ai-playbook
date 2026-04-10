# web3-agents v3 — Multi-Agent Setup

Multi-agent setup for Web3 development. Specialized agents that work in parallel and review each
other.

> **Tool-agnostic**: works with Claude Code, Cursor, or any AI tool that reads `.claude/` or
> `.cursor/` config directories.

---

## What it is

Instead of a single agent that does everything, you get a team:

- `smart-contract-engineer` — Solidity security, reentrancy, flash loans, DeFi
- `infra-engineer` — K8s, Docker, health checks, monitoring
- `devops-engineer` — CI/CD, forge scripts, migrations, Safe multisig
- `frontend-engineer` — wagmi v2, viem, tx state machine, WebSocket cleanup
- `backend-engineer` — subgraphs, indexers, keeper bots, reorg handling
- `architect` — system design, blast radius, upgrade paths
- `spec-writer` — EIP-style technical specs before any code
- `rust-reviewer` — Solana/Anchor, Arbitrum Stylus, Rust correctness

Each agent has its own checklist, domain, and verdict style. They run in parallel. They review each
other. Nothing ships without unanimous agreement.

---

## Installation

```bash
cd ~/your-web3-project

# For Claude Code (default — installs into .claude/)
bash /path/to/web3-agents-v3/install.sh

# For Cursor (installs into .cursor/)
bash /path/to/web3-agents-v3/install.sh .cursor
```

The installer creates this structure in your project:

```
your-project/
├── CLAUDE.md                        ← lists your active agents
├── tasks/
│   └── current_task.md              ← current state (managed automatically)
└── <target>/                        ← .claude/ or .cursor/ etc.
    ├── project-architecture.md      ← fill in (your system)
    ├── data-architecture.md         ← fill in (your data)
    ├── constants.md                 ← fill in (your addresses)
    ├── agents/                      ← 8 agent personas
    ├── skills/                      ← shared knowledge
    │   ├── solidity-patterns/
    │   ├── foundry-testing/
    │   ├── defi-protocols/
    │   ├── web3-frontend/
    │   ├── team--skill-review/
    │   ├── team--skill-refine/
    │   └── team--skill-lookup/
    └── commands/                    ← 4 workflows
        ├── research.md
        ├── spec.md
        ├── implement.md
        └── review.md
```

---

## Mandatory step: fill in the 3 foundation docs

These 3 files are the shared memory of all your agents. **Without them, the agents work blind.**
Fill them in once (~1h), then keep them up to date as the project evolves.

### `.claude/project-architecture.md` (~30 min)

Describe your system. Minimal example:

```markdown
# Project Architecture

<!-- last-verified: 2026-03-23 -->

## System Overview

An ERC-4626 vault on Base that accepts USDC and deploys it into Aave to generate yield.

## Trust Model

- Owner: 3/5 multisig — can upgrade and pause
- Users: untrusted — all inputs validated on-chain

## Key Invariants

- Sum of balances == totalAssets
- Share price never decreases
```

This file must contain:

- What the protocol does
- Who can do what (trust model)
- What must always be true (invariants)
- External dependencies (oracles, protocols)
- Deployment addresses

### `.claude/data-architecture.md` (~20 min)

Your Solidity events, storage layout, GraphQL/Ponder schema if you have one, and the data flow from
chain to frontend.

### `.claude/constants.md` (~10 min)

Your contract addresses per chain, chain IDs, environment variables, and toolchain versions.

> **Freshness rule**: every doc has a `last-verified: YYYY-MM-DD` line. Agents check this date. If
> it's > 30 days old, they explore the codebase instead of trusting the doc.

---

## Usage

Start Claude Code in your project:

```bash
cd your-web3-project
claude
```

Then run one of the 4 commands.

---

### `/research <topic>`

Before writing any code on something unfamiliar.

```
/research how to implement a fee switch on an ERC-4626 vault
```

**What happens:** 2 agents run in parallel with web access. Each digs into their angle (security,
architecture). Findings are merged.

---

### `/spec <feature>`

Before writing a single line of code.

```
/spec add a withdrawal fee system
```

**What happens automatically:**

```
1. spec-writer explores the codebase
2. spec-writer produces a draft
3. You validate the draft
4. All agents review in parallel:
     smart-contract-engineer → security
     devops-engineer         → deployment
     architect               → design
     frontend-engineer       → frontend impact
     backend-engineer        → indexer impact
     ...
5. Each returns APPROVE / APPROVE_WITH_CHANGES / REQUEST_REDESIGN
6. If not unanimous → iterate, re-review, until agreement
7. Spec saved to .claude/specs/
```

You don't run anything manually. Claude orchestrates everything.

---

### `/implement <spec>`

After a spec has been approved.

```
/implement fee-switch
```

**What happens automatically:**

```
1. Plan built from the spec (ordered steps)
2. For each step:
   a. The owning agent writes the code (TDD)
   b. All agents review in parallel
   c. If findings → the owning agent fixes → re-review
   d. If unanimous APPROVE → commit → next step
3. forge test + forge snapshot + slither
4. Final review on the full diff
```

---

### `/review`

On any diff before merging or deploying.

```
/review
```

**What happens:** all agents review in parallel. Verdict merged with 🔴 Blockers / 🟡 Improvements /
🔵 Nits.

You can also specify:

```
/review 42          ← PR number 42
/review src/Vault.sol
/review staged      ← what is in git staging
```

---

## How the agents talk to each other

You don't manage this. Claude Code handles it.

```
You type /spec or /implement
    ↓
Claude reads CLAUDE.md → knows the list of active agents
    ↓
Claude spawns the agents in parallel (Claude Code's native Task tool)
    ↓
Each agent reads its .md file → knows who it is and what to check
    ↓
Each agent reads the 3 foundation docs → knows your project
    ↓
They return their verdicts to the orchestrator
    ↓
The orchestrator merges, iterates if needed, and presents the result
```

---

## Customizing the active agents

In `CLAUDE.md`, the `## Agent Team` section lists the active agents. Remove the rows for agents that
aren't relevant to this project.

Example for a contracts-only project without a frontend:

```markdown
## Agent Team

| AGENT                   | PERSONA                    | CONTEXT DOCS                                                | SKILLS                                                                 |
| ----------------------- | -------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------------------- |
| smart-contract-engineer | smart-contract-engineer.md | project-architecture.md, data-architecture.md               | solidity-patterns, foundry-testing, defi-protocols, team--skill-review |
| devops-engineer         | devops-engineer.md         | project-architecture.md, constants.md                       | foundry-testing, team--skill-review                                    |
| architect               | architect.md               | project-architecture.md, data-architecture.md, constants.md | solidity-patterns, defi-protocols, team--skill-review                  |
| spec-writer             | spec-writer.md             | project-architecture.md, data-architecture.md               | solidity-patterns, team--skill-lookup                                  |
```

---

## Claude Code permissions (optional)

To avoid confirmations on every `forge` or `git` command, create `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(forge:*)",
      "Bash(cast:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git diff:*)",
      "Bash(git status:*)",
      "Bash(slither:*)",
      "Bash(npm:*)",
      "Bash(npx:*)"
    ]
  }
}
```

---

## Skill resolution (priority)

A project can override any global skill by placing a same-named `SKILL.md` in its local
`.claude/skills/` directory.

| Priority    | Path                        | Scope             |
| ----------- | --------------------------- | ----------------- |
| 1 — HIGHEST | `<project>/.claude/skills/` | This project only |
| 2 — MEDIUM  | `.claude/skills/`           | Workspace         |
| 3 — LOWEST  | `~/.claude/skills/`         | Global            |

---

## Getting Started Checklist

```
[ ] bash install.sh [target-dir] in your project
[ ] Fill in <target>/project-architecture.md
[ ] Fill in <target>/data-architecture.md
[ ] Fill in <target>/constants.md
[ ] Edit CLAUDE.md → Stack section + remove unused agents
[ ] Create <target>/settings.json with Bash permissions (optional)
[ ] Start your AI tool
[ ] Run: /research <first topic>
```
