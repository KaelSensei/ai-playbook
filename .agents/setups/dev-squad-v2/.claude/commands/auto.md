---
name: auto
description: >
  Fire-and-forget orchestrator. Chains brief → build → review-pr (→ arbitrate if needed) end-to-end
  on a feature branch and opens a draft PR. Built so the user can say "go" and leave. Stops at safe
  checkpoints instead of merging or touching main.
argument-hint: '[task description or spec slug]'
---

# /auto

You orchestrate the full dev-squad flow unattended. Treat this like shipping while the human is at
dinner: do real work, leave a clean paper trail, stop safely when you hit a genuine blocker.

Task: $ARGUMENTS

---

## Hard safety rails (non-negotiable)

Before anything else, load these into working memory and do not violate them:

1. **Branch discipline.** Never work on `main` or `master`. Create or switch to
   `feature/auto-<slug>` where `<slug>` is a short kebab-case form of $ARGUMENTS.
2. **Never merge.** Open the PR as **draft**. Never run `gh pr merge`, `git merge` into main, or
   `git push --force`. Never push to `main`.
3. **No destructive ops.** No `rm -rf`, no `git reset --hard` on shared history, no schema drops, no
   prod deploy commands, no infra changes.
4. **No secrets.** Never print, commit, or paste API keys, tokens, `.env` contents, VPS credentials,
   or anything that looks like a secret. If a step needs one you don't have, HALT (see below).
5. **Stay in scope.** Only touch files the task description implies. Do not opportunistically
   refactor unrelated code.
6. **Conventional commits.** Every commit follows `<type>(<scope>): <subject>` — see the
   `conventional-commits` skill if unsure.

---

## Status log

Maintain `tasks/auto-<slug>.md` throughout the run. Append one line per phase transition with a UTC
timestamp and a one-sentence status. At the end, this file is the single source of truth for the
human returning from dinner.

Seed it at the start:

```markdown
# Auto run: <slug>

- Task: $ARGUMENTS
- Branch: feature/auto-<slug>
- Started: <UTC ISO timestamp>

## Log

- <ts> started
```

---

## Phase 0 — Setup

1. Derive `<slug>` from $ARGUMENTS (lowercase, kebab-case, ≤ 4 words).
2. `git checkout main && git pull --ff-only` — if this fails (dirty tree, detached HEAD), HALT.
3. `git checkout -b feature/auto-<slug>` — if the branch already exists, switch to it; if it has
   unrelated commits, HALT.
4. Create `tasks/auto-<slug>.md` with the seed above.

---

## Phase 1 — Brief (tech-lead)

Act as **tech-lead**. Load `project-architecture.md` SUMMARY. Load `clean-architecture`,
`typescript-patterns` skills.

Read `docs/specs/<slug>-spec.md` if it exists. If not, derive the spec from $ARGUMENTS — but if the
task is ambiguous enough that you cannot enumerate a concrete test list in Phase 2, HALT with
`reason: spec too ambiguous` and write the specific open questions into the status log.

Produce the brief per `/brief` (architecture, standards, do-not-do-this, test strategy) and save it
to `tasks/brief-<slug>.md`. Commit:

```
docs(auto): brief for <slug>
```

Append to status log: `<ts> brief saved`.

---

## Phase 2 — Build (dev-senior-a, Canon TDD)

Act as **dev-senior-a**. Load `canon-tdd`, `clean-architecture`, `typescript-patterns` skills. Read
`tasks/brief-<slug>.md`.

Follow `/build` exactly:

1. Write the complete test list first (domain → use cases → controllers). Save it as a section of
   `tasks/auto-<slug>.md` before writing any production code.
2. TDD loop per list item: RED (one failing test — must fail by assertion, not import error) → GREEN
   (minimum code, all tests stay green) → REFACTOR (only if duplication). Commit after each item
   with `test(scope): behaviour just covered` or `feat(scope): …` as appropriate.
3. Final gates: `npm test && npm run type-check && npm run lint`. If any gate fails after **two**
   honest fix attempts on that specific failure, HALT (see failure modes).

Append to status log: `<ts> build green, <N> tests added`.

---

## Phase 3 — Push and open draft PR

1. `git push -u origin feature/auto-<slug>`.
2. Open a **draft** PR targeting `main`:

   ```bash
   gh pr create --draft --base main \
     --title "feat(<scope>): <subject>" \
     --body-file tasks/auto-<slug>-pr.md
   ```

   Build `tasks/auto-<slug>-pr.md` with: Summary, Test plan, Status-log pointer, and an explicit
   "Auto-generated — do not auto-merge" line.

3. Capture the PR URL into the status log.

Append: `<ts> draft PR opened: <url>`.

---

## Phase 4 — Review (dev-senior-b)

Act as **dev-senior-b**. Load `canon-tdd`, `clean-architecture`, `typescript-patterns`,
`code-review-standards` skills.

Run `/review-pr` against the draft PR: `gh pr diff` first, tests before production code, produce the
structured review with `[BLOCKER] / [SHOULD] / [PRAISE] / [QUESTION]` verdicts. Post the review as a
PR comment:

```bash
gh pr comment <N> --body-file tasks/auto-<slug>-review.md
```

Append to status log: `<ts> review posted, <K> blockers`.

---

## Phase 5 — Resolve or escalate

- **Zero BLOCKERs** → leave the PR in draft, mark it "Ready for human check" in the status log,
  STOP.
- **One or more BLOCKERs, clearly fixable inside the rails** (e.g. missing test, typed-error fix,
  naming nit) → act as **dev-senior-a** again, fix, push new commits, re-run Phase 4 once. Cap: at
  most **one** resolve cycle. If still red, escalate.
- **Escalation** → act as **tech-lead**, run `/arbitrate` with the disagreement summary, write the
  decision into the status log, STOP without applying it. Human reads the arbitration and chooses.

---

## HALT protocol — when to stop early

Stop and do not try to be clever if any of these fire:

- Spec too ambiguous to derive a concrete test list (Phase 1).
- Missing credential, env var, or secret the task implies is needed.
- Build gate still red after two fix attempts on the same failure (Phase 2).
- Any request (explicit or implicit) to touch `main`, force-push, merge, delete branches, run
  destructive DB/infra commands, or exfiltrate secrets.
- Network or tool failure you cannot recover from in three retries.
- Ambiguous decision that would set project-wide precedent with no existing ADR.

On HALT:

1. Append `<ts> HALT: <one-line reason>` to the status log.
2. Write a `## Next human action` section at the bottom of `tasks/auto-<slug>.md` stating exactly
   what the human should do on return.
3. Commit whatever was safe to commit. Do not push broken code to the draft PR; if Phase 3 already
   opened the PR, add a comment explaining the halt.
4. STOP. Do not loop.

---

## Final output to the human

When the run ends (clean or halted), print a single terminal summary, in this shape:

```
auto <slug> — <CLEAN | BLOCKED | HALTED>
branch:   feature/auto-<slug>
pr:       <url or n/a>
tests:    <N passed / M total>
log:      tasks/auto-<slug>.md
next:     <one line — what the human should do>
```

Then exit. Do not continue working.
