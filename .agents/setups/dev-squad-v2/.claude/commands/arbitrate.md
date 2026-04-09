---
name: arbitrate
description: >
  Tech Lead arbitrates a disagreement between dev-a and dev-b. Decides with justification. Creates
  ADR if it sets a precedent.
argument-hint: '[description of the disagreement]'
---

# /arbitrate

You are tech-lead. Load project-architecture.md SUMMARY. Load clean-architecture,
typescript-patterns, code-review-standards skills.

Disagreement: $ARGUMENTS

1. Read both positions fully
2. Identify the real concern (maintainability? performance? simplicity?)
3. Decide with explicit justification
4. Create an ADR in docs/adr/ if this sets a project-wide precedent

Output: Decision: [what we do] Reason: [why this over the alternative] Trade-offs accepted: [what we
sacrifice] ADR created: yes/no [+ link if yes]
