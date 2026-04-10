---
name: check
description: >
  Targeted quality review: qa-engineer + security-reviewer + data-engineer in parallel.
  Complementary to /review — focused on test coverage, vulnerabilities, and data integrity. Use
  before any staging or production deployment.
argument-hint: '[files, PR number, or empty for the latest commit]'
---

# /check

Update `tasks/current_task.md`: status=CHECK

---

## Context

`/check` is more targeted than `/review`. It runs only the 3 specialized quality agents:

- `qa-engineer` — behavioral coverage, missing edge cases
- `security-reviewer` — OWASP, vulnerabilities, secrets
- `data-engineer` — migrations, indexes, N+1, integrity

Use `/review` for a full team review. Use `/check` for a targeted double-check before deployment.

---

## Step 1 — Determine the input

Same logic as `/review`:

- PR number → `gh pr diff [N]`
- Empty → `git diff HEAD~1`
- `staged` → `git diff --cached`

Run the tests:

```bash
[runner]             # must pass
[runner] --coverage  # show the coverage report
```

Pass the coverage report to `qa-engineer`.

---

## Step 2 — Spawn the 3 agents in parallel

**qa-engineer prompt:**

```
You are qa-engineer.
Load .claude/agents/qa-engineer.md.
Load project-architecture.md, data-architecture.md.
Load testing-patterns, team--skill-review.

Review the test coverage of the following diff.
Coverage report: [coverage output]
Reference spec (if available): [spec]

Focus: coverage gaps, untested edge cases,
uncovered ACs, existing tests that might be missing.
```

**security-reviewer prompt:**

```
You are security-reviewer.
Load .claude/agents/security-reviewer.md.
Load project-architecture.md, constants.md.
Load security-web2, team--skill-review.

Security review of the following diff.
Walk the full OWASP checklist.
Check: injection, auth, sensitive data, access control,
misconfiguration, XSS, rate limiting, input validation, secrets.
```

**data-engineer prompt:**

```
You are data-engineer.
Load .claude/agents/data-engineer.md.
Load project-architecture.md, data-architecture.md.
Load database-patterns, team--skill-review.

Review the data aspects of the following diff.
Check: zero-downtime migrations, missing indexes,
N+1 queries, data integrity, soft delete honored,
pagination on lists.
```

---

## Step 3 — Present the results

```markdown
# Check Report

## qa-engineer

**Verdict**: [verdict] [findings]

## security-reviewer

**Verdict**: [verdict] [findings]

## data-engineer

**Verdict**: [verdict] [findings]

---

## Global Verdict: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN

### 🔴 Critical Blockers

[deduped across agents]

### 🟡 To Fix

[deduped]
```

---

## Step 4 — Deployment gate

Before any prod deployment, all 3 verdicts MUST be `APPROVE`.

If `REQUEST_REDESIGN` → block the deployment, fix, re-run `/check`. If `APPROVE_WITH_CHANGES` → user
decision: fix or accept the documented risk.

Update `tasks/current_task.md`: status=IDLE
