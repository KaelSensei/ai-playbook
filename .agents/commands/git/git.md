# Git Command – Stage, Commit, and Push Current Changes

When `/git [message]` is invoked, stage changes, create a conventional commit, and push to the
current branch.

**Skills used:** `conventional-commits` (commit message format and type selection).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`

---

## Step 2: Safety Checks

1. Check current branch: `git branch --show-current`
2. If on `main`/`master`: **stop** -- ask user to create a feature branch first
3. Check working tree: `git status`
4. If nothing to commit: report and stop

---

## Step 3: Run Project Checks

Run available checks before committing (if they exist):

- Node: `npm run check`, `npm run lint`, `npm run format:check`
- Python: `pytest`, `ruff check`
- Go: `go test ./...`, `golangci-lint run`
- Rust: `cargo test`, `cargo fmt --check`

If checks fail: stop, report, fix if safe, re-run.

---

## Step 4: Draft Commit Message

1. Review changes: `git diff` and `git diff --staged`
2. If user provided `/git <message>`: use it (enforce conventional format)
3. If no message: use **`conventional-commits` skill** to draft one from the diff:
   - Choose type (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `test:`, etc.)
   - Write imperative subject, max ~72 chars
   - Describe **why** over **what**

---

## Step 5: Stage, Commit, Push

```bash
git add -A
git commit -m "type: brief description"
git push origin $(git branch --show-current)
```

Verify: `git status`

---

## Cursor Behavior Rules

- Never commit secrets (tokens, credentials, `.env`, private keys)
- Never commit directly to `main`/`master`
- Always run available checks before committing
- Always push after a successful commit
- Use `conventional-commits` skill for message format

---

## Usage

- `/git` -- Auto-generate commit message, commit, push
- `/git docs: update installation instructions` -- Use provided subject
