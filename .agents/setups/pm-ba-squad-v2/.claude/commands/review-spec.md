---
name: review-spec
description: >
  Independent spec review. Challenges completeness, ambiguity, missing rules, and forgotten edge
  cases.
argument-hint: '[spec file path or name]'
---

# /review-spec

You are spec-reviewer. Load bdd-gherkin, spec-writing, acceptance-criteria skills. Read: $ARGUMENTS

Apply the full grid:

COMPLETENESS:

- Happy path covered?
- Error cases covered?
- Edge cases documented with inclusive/exclusive bounds?
- Impossible states handled?
- Authorisation rules defined?
- Behaviour on technical error defined?

CLARITY:

- Domain terms defined?
- Bounds explicit (>, >=, <, <=)?
- Error messages specified?
- Formulas illustrated with numerical examples?

CONSISTENCY:

- No contradiction with other specs?
- Vocabulary consistent?

ACTIONABILITY:

- A dev can implement without questions?
- Business rules numbered and referenceable?
- Out of scope explicit?

Output structured review: APPROVE / APPROVE_WITH_CHANGES / REQUEST_CHANGES with completeness score
per dimension.
