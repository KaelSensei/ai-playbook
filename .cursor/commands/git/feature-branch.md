# Feature Branch Command – Branch Creation & Management

When `/feature-branch <branch-name>` or `/feature-branch` is invoked, create a new branch with
proper naming and remote tracking.

**Skills used:** `git-branch-naming` (naming conventions and normalization).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Check current git status and branch

---

## Step 2: Determine Branch Name

1. If branch name provided: use it
2. If not: infer from context or ask user
3. Validate and normalize using **`git-branch-naming` skill**:
   - Lowercase, hyphens, no special characters
   - Add prefix if missing (feature/, fix/, refactor/, docs/)
   - Ensure it does not already exist

---

## Step 3: Check State

1. Check for uncommitted changes: `git status`
2. If uncommitted changes: commit or stash first
3. Never create branch with uncommitted changes

---

## Step 4: Create Branch

```bash
git checkout main          # or master
git pull origin main
git checkout -b <branch-name>
git push -u origin <branch-name>
```

Confirm: "Created and switched to branch: `<branch-name>`. Pushed to remote with upstream tracking."

---

## Step 5: Ready for Development

Remind user to use `/feature`, `/fix`, or `/refactor` for actual work.

---

## Cursor Behavior Rules

- Always create from main/master (unless user specifies otherwise)
- Never create branch with uncommitted changes
- Always push with upstream tracking
- Use `git-branch-naming` skill for naming conventions

---

## Usage

- `/feature-branch feature/add-export` -- Create specific branch
- `/feature-branch fix/search-performance` -- Create fix branch
- `/feature-branch` -- Prompt for name or infer from context
