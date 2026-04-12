# Validate Command — Cross-Artifact Consistency Analysis

When `/validate [scope]` is invoked, perform a read-only consistency check across all project
artifacts: SPEC.md, PLAN.md, task lists, and the actual implementation code. Finds drift, gaps,
duplications, and constitution violations.

**Skills used:** `code-audit` (architecture alignment), `security-review` (security consistency),
`adversarial-review` (optional, for deep analysis).

Inspired by spec-kit's `/analyze` command.

---

## Step 1: Load Artifacts

1. Read all available project artifacts:
   - `SPEC.md` (feature specification, if exists)
   - `PLAN.md` (implementation plan, if exists)
   - `PRFAQ.md` (product validation, if exists)
   - Task lists / TODO files (if exist)
   - `README.md`, architecture docs
   - Actual implementation code (scan `src/`, `lib/`, `app/`, or project-specific directories)
2. Load rules from `.agents/rules/*.mdc` (especially `constitution.mdc`)
3. Determine scope:
   - No argument: validate entire project
   - Argument provided: validate specific feature or scope (e.g., `auth`, `search`)

If no SPEC.md or PLAN.md exists, run a lighter validation (code vs docs only).

---

## Step 2: Five-Pass Analysis

Run five analysis passes sequentially. Each pass looks for a specific class of issue.

### Pass 1: Coverage — Are requirements implemented?

For each user story / requirement in SPEC.md (or README.md):

- Is there a corresponding task in PLAN.md?
- Is there actual code implementing it?
- Is there a test covering it?

Flag: `[COVERAGE GAP] <requirement> has no implementation / no test`

### Pass 2: Drift — Has implementation diverged from spec?

Compare what was specified vs what was actually built:

- Features that exist in code but aren't in the spec (scope creep)
- Spec requirements that were implemented differently than specified
- API contracts in the plan vs actual API implementation
- Schema in the plan vs actual database schema

Flag: `[DRIFT] <artifact A> says X, but <artifact B> says Y`

### Pass 3: Duplication — Are things defined in multiple places?

Look for contradictory or redundant definitions:

- Same requirement described differently in spec vs plan
- Same configuration defined in multiple files with different values
- Same business rule implemented in multiple places

Flag: `[DUPLICATION] <thing> is defined in both <location A> and <location B>`

### Pass 4: Ambiguity — Are things underspecified?

Look for vague or incomplete definitions:

- Unresolved `[NEEDS CLARIFICATION]` markers in any artifact
- Requirements without acceptance criteria
- Plan tasks without file paths
- Code with TODO/FIXME/HACK comments

Flag: `[AMBIGUITY] <thing> is underspecified: <what's missing>`

### Pass 5: Constitution Compliance

Verify all artifacts respect `constitution.mdc`:

- Are security implications addressed? (Article 1)
- Is the implementation explicit and auditable? (Article 2)
- Does scope match what was specified? (Article 5)
- Are tests present for critical paths? (Article 6)
- Is documentation up to date? (Article 7)

Flag: `[CONSTITUTION] Article N violation: <description>`

---

## Step 3: Produce Validation Report

Structure the output with severity tiers:

```markdown
## Validation Report: <scope>

### Summary

- Artifacts analyzed: <list>
- Findings: <count by severity>
- Verdict: ALIGNED | HAS ISSUES | SIGNIFICANT DRIFT

### Critical (must fix)

1. [COVERAGE GAP] ...
2. [CONSTITUTION] ...

### High (should fix)

3. [DRIFT] ...
4. [DRIFT] ...

### Medium (worth addressing)

5. [AMBIGUITY] ...
6. [DUPLICATION] ...

### Low (informational)

7. [AMBIGUITY] ...

### Positive (things done well)

8. [GOOD] Spec requirements fully covered with tests
9. [GOOD] Plan tasks match implementation structure
```

### Severity rules

- **Critical** — Constitution violations, security gaps, missing core functionality.
- **High** — Significant drift between spec and implementation, missing tests for critical paths.
- **Medium** — Ambiguities, duplications, minor inconsistencies.
- **Low** — Informational, style, documentation gaps.
- **Positive** — Good patterns worth calling out.

### Limits

- Maximum **30 findings** per run. If more exist, prioritize by severity and note "N additional
  findings omitted."
- Always include at least 1 **Positive** finding if anything is done well.

---

## Step 4: Suggest Actions

For each Critical and High finding, suggest a specific action:

```markdown
### Suggested Actions

1. **[COVERAGE GAP] Auth middleware has no tests** → Run `/feature add auth middleware tests` or add
   to next sprint

2. **[DRIFT] SPEC says pagination uses cursor-based, code uses offset-based** → Update SPEC.md to
   match implementation, or refactor code to match spec

3. **[CONSTITUTION] Article 7: Architecture docs not updated after schema change** → Update
   architecture docs to reflect current schema
```

---

## Behavior Rules

- This is a **read-only** command — it produces a report, it does not make changes.
- Be specific: include file paths, line numbers, and artifact references for every finding.
- Don't manufacture findings — if artifacts are well-aligned, say so.
- If no SPEC.md or PLAN.md exists, that's not a finding — just note the lighter validation scope.
- Focus on actionable findings, not stylistic preferences.
- The goal is to catch real problems, not to generate busywork.

---

## Usage

- `/validate` — Validate entire project
- `/validate auth` — Validate auth-related artifacts and code
- `/validate specs/user-auth/SPEC.md` — Validate a specific spec against its implementation
