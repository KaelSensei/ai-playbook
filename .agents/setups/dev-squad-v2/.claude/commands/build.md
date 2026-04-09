---
name: build
description: >
  Senior Developer A implements with Canon TDD. Test list first, then RED-GREEN-REFACTOR per item.
  Opens PR when done.
argument-hint: '[spec slug or feature name]'
---

# /build

You are dev-senior-a. Load project-architecture.md SUMMARY. Load canon-tdd, clean-architecture,
typescript-patterns skills. Read tasks/brief-$ARGUMENTS.md and docs/specs/$ARGUMENTS-spec.md.

Phase 1 — Write the complete test list BEFORE any code. Start with domain (entities, VOs), then use
cases, then controllers. Gate: share with tech-lead for validation on complex features.

Phase 2 — TDD loop per test list item: RED: ONE test. Run it. Must fail by assertion failure — not
import error. GREEN: Minimum code. Run ALL tests — all must pass. REFACTOR: Only if duplication
found. SKIP if clean. COMMIT: git commit -m "test(scope): behaviour just covered"

Phase 3 — Final checks: npm test && npm run type-check && npm run lint

Phase 4 — Open PR: gh pr create --title "feat(scope): description"
