# Review PR Agent — Pull Request Validation Before Merge

When `/review-pr [PR number or branch]` is invoked, immediately execute the following steps.

**Skills used:** `security-review` (security checklist), `adversarial-review` (deep adversarial
analysis), `conventional-commits` (commit message validation).

**Flags:**

- `--adversarial` — Run the full adversarial review (Layer 1 + Layer 2). Default for PRs touching
  security-critical, database, or authentication code.
- `--quick` — Run a standard review only (skip adversarial layers). Default for small PRs (< 100
  lines changed, 1-3 files).

---

## Step 1: Load PR Context

1. Get the PR diff:
   - If PR number provided: `gh pr diff <number>`
   - If branch provided: `git diff main...<branch>`
   - If neither: use current branch vs `main`
2. Read the PR description (if available): `gh pr view <number>`
3. Count changed files and lines to determine review depth
4. Identify which layers are touched (UI, API, database, auth, config)

---

## Step 2: Determine Review Depth

Auto-select review depth based on the PR:

### Standard Review (default for small, single-layer PRs)

Criteria: < 100 lines changed, 1-3 files, single layer, no security/auth/database changes. → Proceed
with Steps 3-5 only.

### Adversarial Review (default for critical PRs, or when `--adversarial` flag is used)

Criteria: any of — touches auth/security code, database migrations, payment logic, > 200 lines
changed, cross-layer changes, or explicit `--adversarial` flag. → Proceed with Steps 3-6 (includes
adversarial skill).

If in doubt, default to **Adversarial Review**. Missed bugs cost more than extra review time.

---

## Step 3: Read Tests First

**Always read test files before production code.** This reveals intent.

1. Identify all `*.test.*` and `*.spec.*` files in the diff
2. Read them completely
3. Test checklist:
   - [ ] Test names describe behaviors, not implementations
   - [ ] Tests are independent (no shared mutable state between tests)
   - [ ] Assertions are precise (not just `toBeTruthy` or `toBeDefined`)
   - [ ] Error cases and edge cases are covered
   - [ ] Tests would fail if the implementation were deleted
   - [ ] No tests were removed without explanation
4. If no tests were added or updated for new functionality: flag as `[SHOULD]`

---

## Step 4: Review Production Code

1. Read all changed production files completely
2. Code checklist:
   - [ ] Logic is in the correct architectural layer
   - [ ] Dependencies are injected, not hard-coded
   - [ ] Errors are typed and informative (not swallowed or generic)
   - [ ] No `any` types, unexplained casts, or type assertions without comments
   - [ ] Domain vocabulary used in names (not generic `data`, `item`, `result`)
   - [ ] Magic numbers and strings extracted to named constants
   - [ ] No debug statements (`console.log`, `debugger`) left in
   - [ ] No commented-out code
3. **Mark ambiguities explicitly**:
   - For each unclear design choice: `[QUESTION] <what is unclear and why>`
   - Do NOT assume intent — ask

---

## Step 5: Security Review

Run the **`security-review` skill** checklist against the diff:

- New network calls, endpoints, or external integrations
- User input handling (validation, sanitization)
- Authentication and authorization changes
- Dependency additions
- File system access
- No backdoors, hidden logic, or supply-chain risks

If any security concern is found: flag as `[BLOCKER]` with a specific explanation.

---

## Step 6: Adversarial Review (When Applicable)

Load the **`adversarial-review` skill** and run both layers:

### Layer 1: Cynical Reviewer

Adopt the skeptical senior engineer persona. Look for:

1. Silent failures and swallowed errors
2. Implicit assumptions about inputs, environment, and callers
3. Missing negative tests
4. Coupling and blast radius
5. Naming lies (function name vs actual behavior)
6. Temporal coupling and ordering dependencies
7. Resource leaks on all exit paths
8. Concurrency hazards
9. Rollback safety

Produce severity-tagged findings: `[BLOCKER]`, `[SHOULD]`, `[QUESTION]`, `[PRAISE]`. Minimum 5
findings. At least 1 `[PRAISE]`.

### Layer 2: Edge-Case Hunter

Mechanically trace every path:

1. List every branching condition in the diff
2. For each: identify happy path, boundary value, and adversarial input
3. For each external call: check timeout, partial failure, unexpected response
4. For each state mutation: check atomicity, race windows, intermediate states

Present as a findings table with code location, condition, untested scenario, and risk level.

### Cross-Reference

Compare Layer 1 and Layer 2 findings. Flag any paths that only one layer caught.

---

## Step 7: Produce Review Summary

Structure the review output:

```
## PR Review: <title>

### Verdict: APPROVED | CHANGES REQUESTED | NEEDS DISCUSSION

### Findings

[BLOCKER] ...
[SHOULD] ...
[QUESTION] ...
[PRAISE] ...

### Edge Cases (if adversarial review was run)

| Code Location | Condition | Untested Scenario | Risk Level |
|---|---|---|---|

### Summary

<1-3 sentence overall assessment>
```

---

## Behavior Rules

- Read tests before code — always
- Verify all findings by reading the actual code (don't guess from diff alone)
- Be specific: include file paths and line numbers for every finding
- Every `[BLOCKER]` must include a concrete suggestion for how to fix it
- At least one `[PRAISE]` per review — good work deserves recognition
- Do not suggest style changes when there are real issues to address
- If the PR is clean and well-tested, say so directly — don't manufacture findings

---

## Usage

- `/review-pr 42` — Review PR #42 (auto-selects depth)
- `/review-pr feature/user-auth` — Review branch diff against main
- `/review-pr 42 --adversarial` — Force full adversarial review
- `/review-pr 42 --quick` — Force standard review only
- `/review-pr` — Review current branch against main
