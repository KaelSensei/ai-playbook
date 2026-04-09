# Add-Commit-Push Command – Stage, Commit, and Push Current Changes

When `/add-commit-push [message]` is invoked, stage changes, create a conventional commit, and push
to the current branch.

This command is identical to `/git`. See [git.md](git.md) for full details.

**Skills used:** `conventional-commits` (commit message format and type selection).

---

## Steps

1. Load context and rules
2. Safety checks (not on main, working tree has changes)
3. Run project checks (lint/format/tests if they exist)
4. Draft commit message using **`conventional-commits` skill**
5. Stage, commit, push

---

## Usage

- `/add-commit-push` -- Auto-generate commit message, commit, push
- `/add-commit-push docs: update readme` -- Use provided subject
