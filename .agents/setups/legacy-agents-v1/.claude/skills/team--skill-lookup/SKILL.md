---
name: team--skill-lookup
description: >
  Codebase exploration and context lookup protocol. Loaded during /story, /spec, and the EXPLORE
  phase. Defines how to check doc freshness, explore the codebase systematically, and use web search
  effectively.
---

# Team Lookup Protocol

## Doc Freshness Verification

Every agent MUST check `last-verified` before reasoning from a doc.

```
today - last-verified <= 30 days → FRESH → trust the doc
today - last-verified >  30 days → STALE → explore the codebase
```

If a doc is stale:

1. Flag it explicitly: _"project-architecture.md is STALE (last-verified: [date])"_
2. Explore the codebase directly for the affected parts
3. Report divergences between doc and reality to the orchestrator
4. Do NOT update the doc silently — report, do not correct mid-task

## Codebase Exploration Order

For a classic web2 project, explore in this order:

```
1. package.json / pyproject.toml   → stack, dependencies, versions
2. src/ or app/                    → module structure
3. test/ or __tests__/             → understand expected behavior from the tests
4. .env.example                    → required env vars
5. migrations/ or prisma/schema    → DB schema state
6. CI config (.github/workflows/)  → quality pipeline
7. README.md                       → project-specific conventions
```

**Rule**: read tests before code. Tests express intent; implementation expresses the mechanism.

## Web Search

Use web search for external knowledge not covered by the skills:

**Good uses:**

- Framework documentation (Next.js, NestJS, FastAPI, Rails)
- RFCs and standards (RFC 7519 JWT, RFC 6749 OAuth2)
- CVEs and security advisories
- Dependency changelogs
- Known patterns for a specific problem

**Effective search patterns:**

```
"[framework] [feature] documentation"
"[library] [version] breaking changes"
"[vulnerability] [language] mitigation"
"[pattern] best practices [year]"
```

**Do NOT use web search for:**

- Anything covered by loaded skills
- Implementation details visible in the codebase
- Questions that fresh docs already answer

## Output Format After Exploration

```markdown
# Exploration: [topic or feature]

## Doc Status

- project-architecture.md: FRESH (last-verified: YYYY-MM-DD) / STALE
- data-architecture.md: FRESH / STALE
- constants.md: FRESH / STALE

## Codebase Findings

[key files explored, patterns observed, conventions identified]

## External Research

[URLs consulted, key facts extracted — paraphrased]

## Divergences Found

[what doesn't match the docs, with file + line]

## Answer to the Exploration Task

[direct, structured answer to what was sought]

## Open Questions

[what cannot be determined — needs user clarification]
```

## Efficiency Rules

- Read a module's test file before the module itself
- Stop exploring as soon as you have enough to answer the question
- One web search per distinct external concept — no repetition
- If a doc is fresh and answers directly → trust it, stop
