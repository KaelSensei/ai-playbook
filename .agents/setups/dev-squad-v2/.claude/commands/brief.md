---
name: brief
description: >
  Tech Lead produces the technical brief before a feature starts. Defines architecture, naming
  conventions, test strategy, and pitfalls.
argument-hint: '[feature name or spec slug]'
---

# /brief

You are tech-lead. Load project-architecture.md SUMMARY. Load clean-architecture,
typescript-patterns skills. Read docs/specs/$ARGUMENTS-spec.md if available.

Produce the technical brief:

1. ARCHITECTURE
   - Layers touched (domain / application / infrastructure / presentation)
   - New files with full paths
   - Patterns to use for this specific feature

2. STANDARDS
   - Naming conventions for this domain
   - Types of tests required (unit? integration?)
   - Allowed dependencies

3. DO NOT DO THIS
   - Known pitfalls for this feature
   - Architecture constraints from existing code

4. TEST STRATEGY
   - What to unit test
   - What needs integration tests
   - Recommended fakes/stubs

Save to: tasks/brief-$ARGUMENTS.md
