# Create Branch Command – Interactive Branch Creation

When `/create-branch` is invoked, interactively create a new branch with proper naming conventions.

**Skills used:** `git-branch-naming` (naming conventions and normalization).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Check current git status and branch

---

## Step 2: Check Current State

1. Check current branch: `git branch --show-current`
2. Check for uncommitted changes: `git status`
3. If uncommitted changes exist: **stop and ask** user to commit or stash first

---

## Step 3: Ask for Branch Name

1. Ask: "What would you like to name the new branch?"
2. Provide examples: `feature/add-export`, `fix/search-performance`

---

## Step 4: Validate and Normalize

Use the **`git-branch-naming` skill** to:

1. Normalize the raw input (lowercase, hyphens, strip special chars).
2. Add prefix if missing (ask user: feature/fix/refactor/docs).
3. Validate against naming rules and protected branch names.
4. Check branch does not already exist locally or remotely.
5. Show normalized name and confirm if it changed significantly.

---

## Step 5: Create Branch from Up-to-Date Base

```bash
git checkout main        # or master
git pull origin main
git checkout -b <normalized-name>
```

---

## Step 6: Push with Upstream Tracking

```bash
git push -u origin <normalized-name>
```

---

## Step 7: Confirm

Display:

- Branch name created
- "Branch is ready for development"
- Suggest using `/feature`, `/fix`, or `/refactor` for actual work

---

## Cursor Behavior Rules

- Always ask for branch name -- never auto-generate without input
- Always validate and normalize per `git-branch-naming` skill
- Always ensure base branch is up to date before creating
- Always push with upstream tracking
- Never create branch with uncommitted changes
- Stop and ask if branch already exists

---

## Usage

```
User: /create-branch
AI:   What would you like to name the new branch?
User: add export feature
AI:   What type? (feature/fix/refactor/docs)
User: feature
AI:   Created branch: feature/add-export-feature
      Pushed to remote with upstream tracking.
```
