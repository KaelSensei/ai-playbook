# POC Squad — Minimal setup for throwaway demos and prototypes

Setup for **proof-of-concept / demo / hackathon** work: get a working thing on the screen fast, with
just enough discipline that the code is still readable a week later.

> **Compatibility:** Claude Code first. Works in Cursor too — with only one persona and two
> commands, there's almost nothing to "lose" across tools. See
> [`../../docs/AGENTS_COMPATIBILITY.md`](../../docs/AGENTS_COMPATIBILITY.md).

This setup is a **workflow bundle**. It installs one persona and two commands for one very specific
purpose: throwaway exploration. It does not replace the base playbook catalog in `.agents/rules/`,
`.agents/commands/`, and `.agents/skills/`.

## When to use this setup

Use it if **all** of the following are true:

- The thing you are about to build might get thrown away.
- You want to see it working on a screen within an hour, not a week.
- You do not need a test suite, layered architecture, or a review ceremony.

Do **not** use it if:

- The code will ship to production.
- Security / correctness matters from day one.
- You already know you'll want to extend the code beyond the demo.

If you're unsure, prefer the base playbook (`.agents/rules/` + `.agents/commands/` +
`.agents/skills/` only). The base playbook is already optimized for "simple solutions over clever
ones" — a setup bundle is opt-in opinionation, and POC work rarely needs it.

## Agents

| Agent        | Role                                                                      |
| ------------ | ------------------------------------------------------------------------- |
| `prototyper` | Builds the minimum thing that proves the idea. No tests, no layers, fast. |

One persona on purpose. Adding reviewers, spec-writers, or TDD enforcers turns a two-hour demo into
a two-day project.

## Install

```bash
cd your-project/

# Claude Code (default)
bash /path/to/poc-squad-v1/install.sh

# Cursor
bash /path/to/poc-squad-v1/install.sh .cursor
```

## Workflow

```
1. /poc [idea]            → Prototyper builds the smallest thing that works
2. /demo-polish           → Optional: tighten naming, add a README, make it presentable
```

That's it. No `/brief`, no `/spec`, no pair review. Those belong in `dev-squad-v2` when the POC
graduates to a real project.

## Bundled setup-local skills

None. The prototyper deliberately ships with almost no opinions beyond "get it working."

### Inherited from the base playbook

- `clean-code` — good names, small functions, no dead code still matter even for throwaway work.

### Deliberately **not** included

- `clean-architecture` — hexagonal layering for a POC is exactly the kind of over-engineering
  Article 8 of the constitution (`Simplicity Is a Feature`) warns against.
- `canon-tdd` — test-first is wrong for exploratory spikes; you don't yet know what you're building.
- `security-web2` — add it when the POC survives the first week, not before.

## When a POC graduates

Once a POC proves the idea is worth real work, **switch setups**. Typical path:

- `poc-squad-v1` → `dev-squad-v2` (TypeScript / React, strict TDD, pair review)
- `poc-squad-v1` → `web2-agents-v1` (full-stack SaaS team)
- `poc-squad-v1` → `web3-agents-v3` (smart contracts)

The demo code is a seed, not a foundation. Expect to rewrite at least half of it when you graduate.
