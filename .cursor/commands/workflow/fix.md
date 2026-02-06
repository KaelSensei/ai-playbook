# Fix Command – Issue Resolution Workflow

When `/fix <issue description>` is invoked, immediately execute the following steps.

**Skills used:** `security-review` (safety check before fixing), `conventional-commits` (commit
message), `debugging-methodology` (if the issue is complex or persistent).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read: `README.md`, progress docs, architecture docs
4. Identify current Git branch (should be a fix branch, not `main`)
5. Check for attachments (screenshots, error logs, stack traces) -- use as diagnostic evidence

---

## Step 2: Understand the Issue

1. Parse description; incorporate context from attachments
2. Determine: bug, security issue, regression, or logic flaw
3. Identify affected layer (UI, database, external sources, caching)
4. Locate exact code paths involved
5. Do **not** assume -- verify by reading the code first
6. If complex/persistent: consider using `debugging-methodology` skill

---

## Step 3: Security Check

Run the **`security-review` skill** against the affected code:

- Treat the issue as potentially security-sensitive
- Check for backdoors, unsafe calls, injection risks
- Validate the fix does not introduce new vulnerabilities
- If unclear: **stop and ask**

---

## Step 4: Implement the Fix

1. Apply the **minimal, targeted change** required
2. Do not refactor unrelated code
3. Keep logic explicit, readable, auditable
4. No new dependencies unless strictly required

---

## Step 5: Validate

1. Reason through execution path end-to-end
2. Confirm: issue resolved, no new edge cases, no security violations
3. If applicable: verify the scenario from attachments now works correctly
4. Update or add tests where appropriate

---

## Step 6: Commit & Push (Required -- Must Execute)

You **must** commit and push. The fix is not complete until pushed.

1. Run project checks: `npm run check`, lint, format, tests (if they exist)
2. Use **`conventional-commits` skill** for the message:

```bash
git add -A
git commit -m "fix: <clear description of the issue fixed>"
git push origin $(git branch --show-current)
```

---

## Cursor Behavior Rules

- Do not guess -- verify
- Always check for and analyze attachments before diagnosing
- Prefer correctness and safety over speed
- If unclear: ask before fixing
- Never silently fix security-relevant code
- Every `/fix` must result in a commit and push unless explicitly blocked

---

## Usage

- `/fix search not returning results` -- Fix a specific bug
- `/fix image loading crash on Android` -- With attached screenshot for context
