# Merge Branch Into Main Command – Safe Branch Merging Workflow

When `/merge-branch-into-main [branch-name]` is invoked, safely merge a feature branch into `main`.

**Skills used:** `security-review` (pre-merge security checklist).

Reference: `.cursor/rules/version-management.mdc`, `.cursor/rules/security.mdc`,
`.cursor/rules/documentation.mdc`

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Check current git status and branch
4. Read progress docs to understand current project state

---

## Step 2: Determine Branch to Merge

1. If branch name provided: use it
2. If not: use current branch (`git branch --show-current`)
3. If current branch is `main`/`master`: **stop and ask** which branch to merge
4. Validate: branch must exist and must not be `main`/`master`

---

## Step 3: Pre-Merge Safety Checks

1. **Clean working tree**: `git status` -- if uncommitted changes, **stop**
2. **Branch exists**: `git branch -a | grep <branch-name>` -- if not, **stop**
3. **Not already merged**: `git branch --merged main` -- if already merged, inform and skip
4. **Main is up to date**:

   ```bash
   git checkout main
   git pull origin main
   ```

5. **Conflict dry run**:

   ```bash
   git merge --no-commit --no-ff <branch-name>
   git merge --abort
   ```

   If conflicts: **stop and report** -- user must resolve manually

---

## Step 4: Security Review

Run the **`security-review` skill** against the branch diff:

```bash
git log main..<branch-name> --oneline
```

Check: secrets, untrusted network calls, unsafe deps, dynamic code execution. If security concerns
found: **stop and report**.

Also verify documentation is updated per `documentation.mdc`.

---

## Step 5: Merge

```bash
git checkout main
git pull origin main
git merge --no-ff <branch-name> -m "Merge <branch-name> into main"
```

- Use `--no-ff` to preserve branch history
- If conflicts: **stop immediately**, do NOT auto-resolve

---

## Step 6: Post-Merge Validation

1. Verify merge: `git log --oneline -5`
2. Check changed files: `git diff main~1 main --name-only`
3. If project has build scripts, verify they still work

---

## Step 7: Push

```bash
git push origin main
```

If push fails: do **not** force push. Fetch and resolve first.

---

## Step 8: Cleanup (Optional)

Ask user before deleting the branch:

```bash
git branch -d <branch-name>              # local
git push origin --delete <branch-name>   # remote
```

---

## Cursor Behavior Rules

- Never merge with uncommitted changes
- Never force push to main
- Never auto-resolve conflicts -- let user resolve
- Always use `--no-ff` to preserve branch history
- Always run security review (via `security-review` skill) before merging
- Always ensure main is up to date
- Stop and ask if any safety check fails

---

## Usage

- `/merge-branch-into-main feature/add-export` -- Merge specific branch
- `/merge-branch-into-main` -- Merge current branch into main
