# Checklist Command — Unit Tests for English

When `/checklist [spec or scope]` is invoked, generate a validation checklist from project
specifications and requirements. These are the "unit tests" you run before and after implementation
to verify the feature is complete and correct.

**Skills used:** `security-review` (security checklist items), `code-audit` (quality checklist
items).

Inspired by spec-kit's `/checklist` command — treating natural language requirements with the same
rigor as code tests.

---

## Why Checklists?

Tests verify code. Checklists verify everything else: requirements met, edge cases considered,
documentation updated, security addressed. A checklist generated from the spec catches gaps that
tests can't — like "did we actually build what was asked for?"

---

## Step 1: Load Source Material

1. Identify the input:
   - If a file path provided: use that file (e.g., `SPEC.md`, `PLAN.md`)
   - If `SPEC.md` exists: use it as primary source
   - If `PLAN.md` exists: use it as secondary source
   - If neither: generate from `README.md` and current branch context
2. Read the constitution (`constitution.mdc`) for governance items
3. Parse user stories, acceptance criteria, edge cases, and security implications

---

## Step 2: Generate Checklist Categories

Build the checklist from multiple angles:

### A. Requirements Checklist (from SPEC.md)

For each P1 user story, generate verification items:

```markdown
## Requirements Checklist

### US1: <user story summary>

- [ ] Given <precondition>, When <action>, Then <expected result>
- [ ] Given <precondition>, When <action>, Then <expected result>
- [ ] Edge case: <scenario> behaves correctly

### US2: <user story summary>

- [ ] ...
```

Each acceptance criterion from the spec becomes a checklist item. Each edge case becomes an item.

### B. Technical Checklist (from PLAN.md)

For each technical decision, generate verification items:

```markdown
## Technical Checklist

### Architecture

- [ ] New code is in the correct layer (per architecture docs)
- [ ] Dependencies point inward (no layer violations)
- [ ] New APIs match the contract defined in the plan

### Database (if applicable)

- [ ] Migrations are reversible
- [ ] Indexes added for queried fields
- [ ] Schema matches PLAN.md specification

### Dependencies (if applicable)

- [ ] New dependencies are justified
- [ ] No known vulnerabilities in new deps
- [ ] No unnecessary post-install scripts
```

### C. Security Checklist (from constitution + security.mdc)

```markdown
## Security Checklist

- [ ] All user input is validated and sanitized
- [ ] No new eval(), Function(), or dynamic code execution
- [ ] No secrets in code or configuration
- [ ] New endpoints have authentication/authorization
- [ ] New network calls use HTTPS and are to documented domains
- [ ] File system access is scoped to project directory
```

### D. Quality Checklist (from constitution)

```markdown
## Quality Checklist

- [ ] Tests exist for critical paths (Article 6)
- [ ] Code is explicit and auditable (Article 2)
- [ ] Scope matches what was requested — no more, no less (Article 5)
- [ ] Documentation is updated (Article 7)
- [ ] Simplest viable approach was used (Article 8)
- [ ] No debug statements or commented-out code left
```

### E. UX Checklist (if UI involved)

```markdown
## UX Checklist

- [ ] Feature works on all target screen sizes
- [ ] Loading states are handled
- [ ] Error states show meaningful messages
- [ ] Empty states are handled gracefully
- [ ] Keyboard navigation works (accessibility)
- [ ] Color contrast meets WCAG AA (accessibility)
```

---

## Step 3: Trim and Prioritize

- **Remove generic items** that don't apply to this specific feature.
- **Add specific items** unique to this feature's requirements.
- **Mark critical items** with `[CRITICAL]` — these must pass for the feature to ship.
- **Target 15-30 items total.** More than 30 causes checklist fatigue.

---

## Step 4: Output the Checklist

Format for easy use:

```markdown
## Validation Checklist: <feature name>

Generated from: SPEC.md, PLAN.md, constitution.mdc Date: <today>

### Critical (must pass)

- [ ] [CRITICAL] <item>
- [ ] [CRITICAL] <item>

### Requirements

- [ ] <item>
- [ ] <item>

### Technical

- [ ] <item>

### Security

- [ ] <item>

### Quality

- [ ] <item>

---

Passed: 0 / <total> | Status: NOT STARTED
```

---

## Step 5: Save (Optional)

If the user wants to save the checklist:

```bash
git add CHECKLIST.md
git commit -m "docs: add validation checklist for <feature>"
git push origin $(git branch --show-current)
```

---

## When to Run This Checklist

| Timing                    | Purpose                                         |
| ------------------------- | ----------------------------------------------- |
| **Before implementation** | Verify the spec is complete enough to implement |
| **After implementation**  | Verify the feature matches the spec             |
| **Before PR**             | Quick sanity check before requesting review     |
| **Before merge**          | Final gate before code hits main                |

---

## Behavior Rules

- **Specific over generic.** "Login form validates email format" > "Input is validated."
- **Testable items only.** Each item must be verifiable — if you can't check it, don't list it.
- **No busywork.** Skip items that are obviously true or irrelevant to this feature.
- **Critical items are real blockers.** Don't mark everything as critical.
- **Adapt to what exists.** If there's no SPEC.md, build from what's available.

---

## Usage

- `/checklist` — Generate from existing SPEC.md and PLAN.md
- `/checklist SPEC.md` — Generate from a specific spec
- `/checklist user-auth` — Generate for a specific feature scope
