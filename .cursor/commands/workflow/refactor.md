# Refactor Command – Non-Functional Code Improvements

When `/refactor <description>` is invoked, immediately execute the following steps.

**Skills used:** `security-review` (validate no behavior change), `conventional-commits` (commit
message).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read: `README.md`, architecture docs, files affected by the refactor
4. Identify current Git branch (should be a refactor branch, not `main`)

---

## Step 2: Define Scope (Critical)

1. Parse description
2. Allowed: code organization, naming, readability, duplication removal, type safety
3. **Not allowed**: behavior changes, logic changes, feature additions, bug fixes
4. If scope is ambiguous: **stop and ask**

---

## Step 3: Security Validation

Use the **`security-review` skill** reasoning to ensure:

- Refactor preserves behavior exactly
- No new execution paths introduced
- No backdoors, dynamic execution, or unsafe patterns
- If exact equivalence cannot be guaranteed: **abort and ask**

---

## Step 4: Perform the Refactor

1. Apply **minimal, mechanical** transformations only
2. Prefer: extracting functions, improving naming, reducing nesting, improving types
3. Avoid: reordering logic, changing conditionals, introducing dependencies
4. Keep changes tightly scoped and reviewable

---

## Step 5: Validate Equivalence

1. Reason through execution paths before and after
2. Confirm: inputs -> outputs identical, side effects unchanged, error handling unchanged
3. If tests exist, ensure they pass unchanged

---

## Step 6: Update Documentation (Required)

Automatically update (per `documentation.mdc`):

1. **PROGRESS.md** -- note refactor, update timestamp
2. **CHANGELOG.md** -- `- Refactored: <description>`
3. **Architecture docs** -- if file structure or organization changed significantly

---

## Step 7: Commit & Push (Required)

```bash
git add -A
git commit -m "refactor: <clear description of structural improvement>"
git push origin $(git branch --show-current)
```

---

## Cursor Behavior Rules

- Refactor is not rewrite
- Never "improve" logic -- never sneak in fixes or features
- If tempted to change behavior: stop and suggest `/fix`
- Every `/refactor` must result in a commit unless explicitly blocked

---

## Usage

- `/refactor extract database utilities` -- Extract reusable DB helpers
- `/refactor improve naming in auth module` -- Rename for clarity
