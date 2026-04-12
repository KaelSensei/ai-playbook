# Feature Command – New Functionality Workflow

When `/feature <feature description>` is invoked, immediately execute the following steps.

**Skills used:** `git-branch-naming` (branch creation), `security-review` (pre-implementation
validation), `conventional-commits` (commit message).

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc`
3. Read: `README.md`, `PROGRESS.md`, architecture docs, task docs
4. Identify current Git branch
5. Check for attachments (images, mockups, diagrams) -- analyze and use as design reference

---

## Step 2: Ensure Feature Branch (Mandatory)

1. Check current branch: `git branch --show-current`
2. If on `main`/`master`:
   - Derive branch name from description using **`git-branch-naming` skill** (e.g. "add search reset
     button" -> `feature/add-search-reset-button`)
   - Create branch via `/feature-branch` workflow
   - Tell the user: "Created feature branch `<name>`. Proceeding."
3. If already on a feature branch: proceed

**Rule:** Never implement on `main` or `master`.

---

## Step 3: Assess Complexity (Scale-Adaptive Routing)

Before diving in, determine the scope of this feature:

### Quick Flow (small feature — estimated 1-3 files, no architecture changes)

Criteria: single-layer change, clear requirements, no new dependencies, no schema changes. → **Skip
to Step 5** (Security Validation) and proceed through implementation.

### Full Flow (medium+ feature — 4+ files, cross-layer, or unclear scope)

Criteria: touches multiple layers, requires new dependencies, involves schema changes, or has
ambiguous requirements.

- **If SPEC.md and/or PLAN.md exist** for this feature: use them as input. Skip to Step 5
  (Architecture Validation) since specification and planning are already done.
- **If no spec/plan exists:** consider running `/spec` → `/plan` first for complex features.
  Alternatively, **continue with Step 4** and follow all steps sequentially.

If in doubt, default to **Full Flow**. You can always move faster; you can't undo a bad assumption.

---

## Step 4: Understand the Feature

1. Parse description; incorporate context from attachments
2. Define: what is being added, what is out of scope
3. Identify impacted layers (UI, database, external sources, caching, utilities)
4. **Mark ambiguities explicitly** — do not guess or assume:
   - For each unclear requirement, write: `[NEEDS CLARIFICATION] <what is ambiguous and why>`
   - Maximum 3 markers. Only flag high-impact ambiguities that would change implementation.
   - If any `[NEEDS CLARIFICATION]` markers exist: **stop and present them to the user before
     coding**
   - Do NOT proceed with assumptions — wait for explicit answers
5. If the feature is clear: proceed

---

## Step 5: Architecture Validation

1. Ensure no architecture violations (separation of concerns, single source of truth)
2. For database changes: consider migrations, add indexes
3. If UI mockups provided: validate design consistency
4. If feature conflicts with architecture: **propose alternative first**

---

## Step 6: Security Validation

Run the **`security-review` skill** checklist against the planned feature:

- New network calls (respect allowed domains)
- File system access
- SQL injection risks
- Dependency additions
- No backdoors, hidden logic, or supply-chain risks

If security implications are unclear: **stop and ask**.

---

## Step 6b: Constitution Check (Full Flow Only)

Before implementing, verify the planned work against `constitution.mdc`:

1. Does the approach respect security-first principles? (Article 1)
2. Is the implementation explicit and auditable? (Article 2)
3. Does the scope match what was requested — no more, no less? (Article 5)
4. Is this the simplest viable approach? (Article 8)
5. Does it respect project tech stack and architecture? (Article 9)

For each violation: `[CONSTITUTION VIOLATION] Article N: <description>`. **Violations are blockers**
— propose an alternative before proceeding.

This check is **silent when passing** — only report violations.

---

## Step 7: Implement

1. Implement incrementally
2. Follow visual specs from attachments if provided
3. Keep code explicit, readable, auditable
4. No new dependencies unless strictly necessary

---

## Step 8: Validate

1. Reason through behavior end-to-end
2. Confirm: existing functionality unaffected, edge cases handled
3. Verify visual output matches mockups (if applicable)
4. Add or update tests where appropriate

---

## Step 9: Update Documentation (Required)

Automatically update (per `documentation.mdc`):

1. **PROGRESS.md / CHANGELOG.md** -- add feature with `[x]` checkbox, update timestamp
2. **CHANGELOG.md** -- add under `## [Unreleased]`: `- Added: <description>`
3. **USER_GUIDE.md** -- add or update section for user-facing feature
4. **Architecture docs** -- if schema, external sources, or major UI changed
5. **README.md** -- if usage or build instructions changed

**Do NOT ask** -- update docs automatically.

---

## Step 10: Commit & Push (Required -- Must Execute)

You **must** commit and push. The feature is not complete until pushed.

1. Run project checks: `npm run check`, lint, format, tests (if they exist)
2. Use **`conventional-commits` skill** for the message:

```bash
git add -A
git commit -m "feat: <clear description>"
git push origin $(git branch --show-current)
```

---

## Cursor Behavior Rules

- Always ensure a feature branch first (create via `/feature-branch` if on main)
- Always check for and analyze attachments before implementation
- Never mix fixes or refactors into a feature commit
- If a bug is found: pause and suggest `/fix`
- If cleanup is needed: pause and suggest `/refactor`
- Every `/feature` must result in a commit and push unless explicitly blocked

---

## Usage

- `/feature add search reset button` -- Creates branch if needed, implements, commits, pushes
- `/feature add dark mode toggle` -- With attached mockup image for design reference
