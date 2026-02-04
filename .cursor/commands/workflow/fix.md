# Fix Command – Issue Resolution Workflow

When `/fix <issue description>` is invoked, immediately execute the following steps.

---

## Step 1: Load Project Context

1. Assume the project root as the working directory
2. Load and respect all Cursor rules from `.cursor/rules/*.mdc`
3. Read core project documentation if present:
   - `README.md`
   - Project progress documentation (e.g., `PROGRESS.md`, `CHANGELOG.md`)
   - Architecture or task documents relevant to the issue
4. Identify the current Git branch and assume it is a **fix branch**, not `main`
5. **Check for attachments** (screenshots, error logs, stack traces, videos):
   - Analyze any visual evidence of the issue
   - Extract error messages, console output, or visual bugs from images
   - Review stack traces or debug information if provided
   - Use attachments to understand the exact failure scenario
   - If attachments show different issues than described, **ask for clarification**

---

## Step 2: Understand the Issue

1. Parse the issue description provided after `/fix`
2. **Incorporate context from any attached evidence**:
   - Screenshots showing UI bugs or unexpected behavior
   - Error messages or console logs
   - Stack traces pointing to problematic code
   - Before/after comparisons
   - Network request failures or API errors
3. Determine:
   - Is this a **bug**, **security issue**, **regression**, or **logic flaw**
   - Which layer is affected (UI, database, external data sources, caching, TypeScript/JavaScript,
     etc.)
4. Locate the exact code paths involved
5. **Cross-reference visual evidence with code** to pinpoint root cause
6. Do **not** assume the fix — verify by reading the code first

---

## Step 3: Security & Safety Check (Mandatory)

Before writing any code:

1. Treat the issue as potentially security-sensitive
2. Check for:
   - Backdoors or hidden logic
   - Unsafe external calls (respect project-defined allowed domains)
   - SQL injection risks (if applicable)
   - File system access issues
   - Dependency or supply-chain risks
3. **If attachments show suspicious behavior** (unexpected network calls, unauthorized data access):
   - Investigate thoroughly before proceeding
   - Flag potential security implications
4. Use security reasoning to:
   - Validate the fix does not introduce new vulnerabilities
   - Ensure no malicious patterns are added
5. If security implications are unclear, **stop and ask before proceeding**

---

## Step 4: Implement the Fix

1. Apply the **minimal, targeted change** required to fix the issue
2. **Ensure the fix addresses the exact problem shown in attachments** (if provided)
3. Do not refactor unrelated code
4. Keep logic explicit, readable, and auditable
5. Add comments only where they clarify intent or safety
6. Do not introduce new dependencies unless strictly required

---

## Step 5: Validate the Fix

1. Reason through the execution path end-to-end
2. Ensure:
   - The original issue is resolved
   - **The scenario shown in attachments would now work correctly**
   - No new edge cases are introduced
   - No security rules are violated
3. If tests exist, update or add the minimal necessary coverage
4. If tests do not exist, explain why and what would be tested later

---

## Step 6: Commit & Push (Required – Must Execute)

After the fix is complete, you **must** run git add, commit, and push. **Do not consider the fix
complete until you have pushed.**

1. **Run project checks first** (if they exist): e.g. `npm run check`, `npm run format`, lint,
   tests.
2. **Stage, commit, and push:**

```bash
git add -A
git commit -m "fix: <clear description of the issue fixed>"
git push origin $(git branch --show-current)
```

- Never push directly to `main` or `master`
- Always push to the current fix branch
- **You must execute these commands**; do not stop after Step 5 without committing and pushing

---

## Cursor Behavior Rules

- Do not guess — verify
- **Always check for and analyze attachments** before diagnosing the issue
- Prefer correctness and safety over speed
- If something is unclear, ask before fixing
- Never silently fix security-relevant code
- Every `/fix` must result in a commit and a push unless explicitly blocked; the fix is not complete
  until changes are pushed

---

## Usage

Use `/fix <issue description>` to:

- Debug a bug in UI, database, or external data sources
- Patch a vulnerability
- Fix a regression
- Correct incorrect logic safely and explicitly
- Fix file loading or caching issues
- Fix database query or migration issues (if applicable)
- Resolve errors shown in screenshots or logs (attach evidence for context)
