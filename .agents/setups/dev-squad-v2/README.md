# Dev Squad — Multi-Agent Setup

Multi-agent setup for TypeScript/React development with strict Canon TDD and asynchronous code
review supervised by the Tech Lead.

> **Compatibility:** Claude Code first. Cursor can read a reduced version of this setup, but native
> multi-agent orchestration does not carry over 1:1. See
> [`../../docs/AGENTS_COMPATIBILITY.md`](../../docs/AGENTS_COMPATIBILITY.md).

This setup is a **workflow bundle**. It installs personas, commands, and setup-local skills for one
team pattern. It does not replace the base playbook catalog in `.agents/rules/`,
`.agents/commands/`, and `.agents/skills/`.

## Agents

| Agent               | Role                                                                     |
| ------------------- | ------------------------------------------------------------------------ |
| `tech-lead`         | Sets standards, writes technical brief, arbitrates, reviews architecture |
| `dev-senior-a`      | Implements with Canon TDD: test list → RED → GREEN → REFACTOR            |
| `dev-senior-b`      | Async reviewer: reads tests before code, always                          |
| `security-reviewer` | OWASP review on any diff touching auth, input, secrets, or public routes |

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

### Unattended mode — `/auto [task]`

For fire-and-forget runs (e.g. kick it off from your own machine and step away), use:

```
/auto [task description]
```

`/auto` chains brief → build → review-pr end-to-end on a dedicated `feature/auto-<slug>` branch,
opens a **draft** PR, and writes a status log to `tasks/auto-<slug>.md`. It stops at safe
checkpoints instead of merging — it never pushes to `main`, never force-pushes, never merges, and
halts early on ambiguous specs or missing secrets. Human review on the draft PR is still required
before merge.

### CI scaffold — `/setup-ci`

Pulled in from the base playbook. One-shot scaffold that detects the project's stack (Node/TS,
Python, Rust, Go) and writes a minimal `.github/workflows/ci.yml` (build/test/lint/typecheck on push
and PR). Refuses to overwrite without `--force`. Use it once near project start — for anything
beyond a basic CI gate (deploy, Docker, K8s), use the base `/devops` command instead.

## Bundled Setup-Local Skills

These skills belong to this setup bundle.

| Skill                   | Content                                                                     |
| ----------------------- | --------------------------------------------------------------------------- |
| `canon-tdd`             | RED-GREEN-REFACTOR, test list, test doubles, builders, async, error testing |
| `typescript-patterns`   | Result type, branded types, Zod, utility types, discriminated unions        |
| `code-review-standards` | Severity levels, checklist per layer, common TS bugs, performance           |
| `api-design-ts`         | REST conventions, response format, Zod middleware, JWT/RBAC                 |
| `react-patterns`        | Custom hooks, forms, error boundary, Testing Library, context, performance  |
| `testing-patterns-ts`   | Test pyramid, DB integration, supertest, hook testing                       |

### Inherited from the base playbook

The setup also installs the shared `clean-architecture` skill from `.agents/skills/` (hexagonal,
ports/adapters, use cases, domain events, error handling). Agent references like
`clean-architecture` in `CLAUDE.md` resolve to that shared copy at install time.
