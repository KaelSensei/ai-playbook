---
name: pr
description: >
  Full PR workflow. dev-senior-a creates the PR, dev-senior-b reviews it on the real GitHub, if
  APPROVE dev-senior-a auto-merges, scribe documents. Replaces the manual merge. Use after /build or
  /refactor is complete.
argument-hint: '[feature slug or description]'
---

# /pr

Update `tasks/current_task.md`: status=PR, task=$ARGUMENTS

---

## Prerequisites

```bash
# Verify everything is clean
git status          # no uncommitted files
[runner]            # all tests pass
gh auth status      # GitHub CLI authenticated
```

If tests are failing → stop. No PR on red.

---

## Step 1 — dev-senior-a creates the PR

```
You are dev-senior-a.
Load .claude/agents/dev-senior-a.md.
Load project-architecture.md.

Feature: $ARGUMENTS

Create a GitHub Pull Request with:

1. Title: [type]([scope]): [short description]
   Types: feat / fix / refactor / chore / docs / security

2. Description (template below)

3. Appropriate labels: feature / bug / refactor / security / breaking-change

Run:
gh pr create --title "[title]" --body "[description]" --label "[labels]"
```

**PR description template:**

````markdown
## Description

[What this PR does in 2-3 sentences — user-oriented]

## Type of change

- [ ] feat: new functionality
- [ ] fix: bug fix
- [ ] refactor: refactoring without behavior change
- [ ] security: security fix
- [ ] breaking: breaking change

## Changes

- [list of main changes]

## Tests

- [ ] Unit tests added/updated
- [ ] Integration tests if applicable
- [ ] Coverage maintained or improved

## Coverage

Before: [X%] → After: [Y%]

## Rollback

```bash
git revert [commit hash]
[migration rollback command if applicable]
```
````

## Checklist

- [ ] Tests passing
- [ ] Linter clean
- [ ] Technical docs updated if architecture changed
- [ ] No secrets in the code

```

Output: URL of the created PR.

---

## Step 2 — dev-senior-b reviews the real GitHub PR

```

You are dev-senior-b. Load .claude/agents/dev-senior-b.md. Load context docs and skills. Load
team--skill-review.

PR to review: [URL or number]

Fetch the full diff: gh pr diff [number]

Also read: gh pr view [number] ← description + metadata gh pr checks [number] ← CI checks status

Review from your angle: test first, code second. Verify the PR description matches the code. Verify
CI checks are green.

Submit the review on GitHub: gh pr review [number] --approve --body "[comment]" or gh pr review
[number] --request-changes --body "[comment]"

```

---

## Step 3 — Resolve if REQUEST_CHANGES

Load `team--skill-refine`.

dev-senior-a addresses the requested changes.
Force-push to the same branch.
dev-senior-b re-reviews.
Maximum 3 iterations before escalation.

---


## Step 3.5 — Smoke Tests (before merge)

Spawn `qa-automation` in smoke mode:

```

You are qa-automation. Load .claude/agents/qa-automation.md. Load TEST_PLAN.md Smoke Tests section.
Load .claude/observability.md.

Run the smoke tests on the staging/preview env.

```

If smoke FAIL → merge blocked. Fix first, re-run /pr.
If smoke PASS → continue to merge.

---
## Step 4 — Merge if APPROVE

```

You are dev-senior-a.

Approved PR: [number] CI checks: [green]

Merge: gh pr merge [number] --squash --delete-branch

Squash commit message: [type]([scope]): [description]

[optional body if breaking change or important context]

```

**Why squash?**
One clean commit per feature in main.
Readable history. Easy revert.

---

## Step 5 — scribe documents post-merge

```

You are scribe. Load .claude/agents/scribe.md. Load project-architecture.md, CHANGELOG.md,
PROGRESS.md.

Merged feature: $ARGUMENTS Merge commit: [hash]

Produce:

1. CHANGELOG.md entry
2. Update technical docs if architecture changed
3. ADR if an architectural decision was made during this feature
4. Rollback plan in docs/rollbacks/
5. Update PROGRESS.md (move from "In Progress" to "In Production")
6. Coverage delta if available

```

---

## Step 6 — Completion

Update `tasks/current_task.md`: status=IDLE

```

✅ PR merged: $ARGUMENTS PR: #[number] Commit: [hash] Reviewer: dev-senior-b Merge: dev-senior-a
(squash) Docs: CHANGELOG.md + PROGRESS.md updated ADR: [created / not needed] Rollback:
docs/rollbacks/[feature]-rollback.md

```

```
