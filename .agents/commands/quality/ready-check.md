# Ready Check Command — Implementation Readiness Gate

When `/ready-check [feature or scope]` is invoked, verify that all prerequisites are aligned before
implementation begins. This is the "are we ready to code?" checkpoint.

**Skills used:** `security-review` (security implications), `code-audit` (architecture alignment).

Inspired by spec-kit's constitution check and BMAD-METHOD's implementation readiness gate.

---

## Step 1: Load Context

1. Assume project root as working directory
2. Load rules from `.cursor/rules/*.mdc` or `.agents/rules/*.mdc`
3. Read: `README.md`, architecture docs, any spec or planning documents
4. Identify the feature/scope being checked
5. If no argument provided: check readiness for the current branch's work

---

## Step 2: Requirements Clarity Check

Verify that requirements are clear and complete:

1. **Is there a description?** — The feature/fix must have a clear written description (issue, spec,
   PR description, or inline description from the user).
2. **Are acceptance criteria defined?** — What does "done" look like? If not stated, derive them and
   present for confirmation.
3. **Are there open `[NEEDS CLARIFICATION]` markers?** — Search for unresolved ambiguities in any
   spec, plan, or task documents. These must be resolved before coding.
4. **Is scope bounded?** — Is it clear what is IN scope and what is NOT?

For each gap found: `[NOT READY] <what is missing and why it matters>`

---

## Step 3: Architecture Alignment Check

Verify the planned work fits the project architecture:

1. **Layer correctness** — Does the planned implementation respect separation of concerns? Will new
   code go in the right layer (UI, business logic, data, infrastructure)?
2. **Pattern consistency** — Does the approach follow existing patterns in the codebase? Or does it
   introduce a new pattern? If new: is that justified?
3. **Dependency direction** — Will new imports respect the dependency rule (outer layers depend on
   inner layers, never the reverse)?
4. **Schema impact** — Are database migrations needed? Are they reversible?
5. **API contract** — Do existing API contracts change? Are consumers aware?

For each violation found: `[NOT READY] <what conflicts and the suggested resolution>`

---

## Step 4: Security Implications Check

Run a lightweight security pre-check using `security-review` skill reasoning:

1. **New attack surface** — Does this feature introduce new user inputs, endpoints, or external
   integrations?
2. **Auth changes** — Does this touch authentication or authorization logic?
3. **Data sensitivity** — Does this handle PII, credentials, or financial data?
4. **Dependency additions** — Are new dependencies needed? Are they vetted?

For each concern: `[CAUTION] <security implication that must be addressed during implementation>`

---

## Step 5: Technical Prerequisites Check

Verify the environment is ready:

1. **Branch exists** — Is the work happening on a proper feature/fix branch (not `main`)?
2. **Base is current** — Is the branch up to date with `main`? (`git log main..HEAD`)
3. **Tests pass** — Do existing tests still pass? (`npm test` or equivalent)
4. **No conflicts** — Are there merge conflicts with `main`?
5. **Dependencies installed** — Is the project in a buildable state?

For each issue: `[NOT READY] <what needs to be fixed first>`

---

## Step 6: Produce Readiness Report

Structure the output:

```
## Ready Check: <feature/scope>

### Verdict: READY | NOT READY | READY WITH CAUTIONS

### Requirements Clarity
- [PASS] / [NOT READY] ...

### Architecture Alignment
- [PASS] / [NOT READY] ...

### Security Implications
- [PASS] / [CAUTION] ...

### Technical Prerequisites
- [PASS] / [NOT READY] ...

### Summary
<1-3 sentence overall assessment>

### Next Steps
<what to do now — either start coding or fix the gaps first>
```

### Verdict rules

- **READY** — All checks pass, no `[NOT READY]` markers. Proceed with implementation.
- **READY WITH CAUTIONS** — No blockers, but `[CAUTION]` items that must be kept in mind during
  implementation. Proceed, but address cautions as you go.
- **NOT READY** — One or more `[NOT READY]` markers exist. Do NOT proceed until resolved.

---

## Behavior Rules

- This is a **read-only** command — it produces a report, it does not make changes
- Be specific about what is missing and what is needed to fix it
- Do not rubber-stamp — if you can't verify a check, say so
- If the project has no architecture docs, note that as a gap (not a blocker)
- This command can be run multiple times as gaps are addressed
- A passing ready-check is not a substitute for code review after implementation

---

## Usage

- `/ready-check user authentication` — Check readiness for an auth feature
- `/ready-check` — Check readiness for the current branch's work
- `/ready-check fix/login-redirect` — Check readiness for a specific fix branch
