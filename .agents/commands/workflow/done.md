# Done Command — Technical Completion Checklist

When `/done` is invoked, run a comprehensive completion check to verify the current feature/fix is
ready to merge. This is the final gate before `/merge-branch-into-main`.

**Skills used:** `security-review` (security check), `code-audit` (quality check).

---

## Step 1: Identify the Work

1. Check current branch: `git branch --show-current`
   - If on `main`/`master`: **stop** — "Nothing to verify. Switch to a feature branch first."
2. Get all commits on this branch: `git log main..HEAD --oneline`
3. Get all files changed: `git diff main --name-only`
4. Read SPEC.md, PLAN.md (if they exist) for intended scope
5. Determine what type of work this is (feature, fix, refactor, etc.)

---

## Step 2: Run Completion Checks

### A. Code Completeness

- [ ] All planned tasks/changes are implemented (check against PLAN.md if it exists)
- [ ] No TODO/FIXME/HACK comments left in changed files (unless explicitly deferred)
- [ ] No debug statements (`console.log`, `debugger`, `print`) in changed files
- [ ] No commented-out code in changed files

### B. Test Coverage

- [ ] Tests exist for new functionality (if applicable)
- [ ] All existing tests still pass: run `npm test` (or project equivalent)
- [ ] Type checking passes: run `npm run type-check` (or project equivalent)
- [ ] Linting passes: run `npm run lint` (or project equivalent)

### C. Security Review (Lightweight)

Quick pass using `security-review` skill:

- [ ] No secrets, API keys, or credentials in the diff
- [ ] No new `eval()`, `Function()`, or dynamic code execution
- [ ] New user inputs are validated
- [ ] New network calls are to documented domains
- [ ] New dependencies are justified and audited

### D. Documentation

- [ ] README.md updated (if usage or build instructions changed)
- [ ] Architecture docs updated (if architecture changed)
- [ ] CHANGELOG.md updated (if not deferred per branch policy)
- [ ] USER_GUIDE.md updated (if user-facing feature added)

### E. Artifact Alignment (if SPEC.md/PLAN.md exist)

- [ ] All P1 user stories are implemented
- [ ] Acceptance criteria are met
- [ ] No unresolved `[NEEDS CLARIFICATION]` markers
- [ ] No `[CONSTITUTION VIOLATION]` markers
- [ ] Scope matches spec — no undocumented additions or missing features

### F. Git Hygiene

- [ ] All changes are committed (no unstaged files)
- [ ] All changes are pushed to remote
- [ ] Commit messages use conventional format
- [ ] Branch is up to date with main (no conflicts)

---

## Step 3: Produce Completion Report

```markdown
## Completion Report: <branch name>

### Verdict: DONE | NOT DONE | DONE WITH NOTES

### Checks Passed

- [x] Code completeness
- [x] Tests pass
- [x] Security review
- [x] Documentation updated
- [x] Artifact alignment
- [x] Git hygiene

### Issues Found (if any)

1. <issue — what's wrong and how to fix it>
2. <issue>

### Notes (if any)

- <anything the reviewer should know>

### Next Steps

- DONE → Run `/create-pr main` or `/merge-branch-into-main`
- NOT DONE → Fix issues above, then run `/done` again
- DONE WITH NOTES → Merge is safe, but address notes in a follow-up
```

### Verdict rules

- **DONE** — All checks pass. Ready to merge.
- **NOT DONE** — One or more checks fail. Fix before merging.
- **DONE WITH NOTES** — All critical checks pass, but there are non-blocking items worth noting
  (e.g., "P3 story deferred", "docs could be more detailed").

---

## Step 4: Suggest Next Action

Based on the verdict:

- **DONE:** "Ready to merge. Run `/create-pr main` to open a PR, or `/merge-branch-into-main` to
  merge directly."
- **NOT DONE:** List the specific failures and how to fix each one.
- **DONE WITH NOTES:** "Safe to merge. Consider addressing these in a follow-up: <notes>."

Optional: suggest `/retro` after merge for features that took significant effort.

---

## Behavior Rules

- **Run actual commands** for test/lint/type-check steps — don't just check if config exists.
- **Be honest** — if something is missing, say so. Don't rubber-stamp.
- **Be practical** — a solo prototype doesn't need the same rigor as a production feature. Adapt the
  checklist to what exists.
- **If SPEC.md/PLAN.md don't exist**, skip artifact alignment — that's fine for Quick Flow work.
- **This is a read-mostly command** — it runs checks and reports, but doesn't fix issues itself.

---

## Usage

- `/done` — Run completion checks on current branch
