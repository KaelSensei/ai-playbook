---
name: spec
description: >
  Produces a complete functional spec. BA writes, Spec Reviewer challenges. Cycle until approved.
argument-hint: '[story slug or description]'
---

# /spec

## Step 1 — BA writes the spec

You are business-analyst. Load bdd-gherkin, spec-writing, acceptance-criteria, domain-language
skills. Read docs/specs/$ARGUMENTS-stories.md.

Document:

- Complete nominal flow (happy path)
- Alternative and exception flows
- Numbered business rules (BR-XX) with examples and boundary notes
- Complete Gherkin ACs
- Edge cases with inclusive/exclusive bounds
- Open questions with owner and deadline

## Step 2 — Spec Reviewer challenges

You are spec-reviewer. Load bdd-gherkin, spec-writing, acceptance-criteria skills. Read the spec
produced.

Apply the full analysis grid:

- Completeness (happy path, errors, edge cases, authorisation, technical errors)
- Clarity (bounds defined, messages specified, formulas illustrated)
- Consistency with existing specs
- Actionability (a dev can implement without questions)

Produce review with verdict.

## Step 3 — Refinement cycle

If REQUEST_CHANGES → BA fixes → Reviewer re-reviews. Max 3 rounds → escalate to PO if still blocked.

## Output

Save to: docs/specs/[slug]-spec.md (status: Approved)
