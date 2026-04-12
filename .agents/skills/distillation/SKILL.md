---
name: distillation
description:
  Lossless compression of large documents to reduce token usage without losing information. Not
  summarization — provably no information is lost. Use when specs, plans, or context documents
  exceed ~200 lines and need to fit in a smaller context window.
---

# Document Distillation Skill — Lossless Context Compression

A methodology for compressing large markdown documents into token-efficient formats while preserving
all information. This is fundamentally different from summarization — summaries lose detail;
distillation preserves it in a denser form. Inspired by BMAD-METHOD's Distillator pattern.

## When to use this skill

- When a SPEC.md, PLAN.md, or architecture doc exceeds ~200 lines.
- When context window is filling up and documents need to be re-loaded smaller.
- When handing off context between agents or conversations (`/export-context`).
- When the user says "compress this" or "make this shorter without losing anything."

## How this skill is used

**Users do not invoke skills directly.** The AI applies distillation when documents are too large
for the current context, or when explicitly referenced.

- **Referenced by:** `/export-context`, `/spec`, `/plan`, `/start`, `/continue`

---

## Core Principle

**Summarization removes information. Distillation restructures it.**

A distilled document must pass the reconstruction test: given only the distilled version, can the
original be reconstructed without loss of meaning, intent, or detail?

---

## Distillation Techniques

### 1. Structural Compression

Replace verbose markdown structures with dense equivalents:

**Before (42 tokens):**

```markdown
## User Stories

### P1 — Must Have

- As a developer, I want to authenticate via OAuth2, so that I can access protected resources.
- As a developer, I want to refresh expired tokens, so that my session doesn't interrupt.
```

**After (28 tokens):**

```markdown
## Stories

P1: Developer OAuth2 auth → access protected resources | Token refresh → uninterrupted session
```

Rules:

- Collapse heading hierarchy where nesting adds no meaning.
- Use `|` separators instead of bullet lists for parallel items.
- Remove "As a... I want to... so that..." when actor/action/benefit are clear from context.

### 2. Vocabulary Compression

Replace repeated phrases with abbreviations, defined once:

```markdown
<!-- Glossary: AC=acceptance criteria, CC=constitution check, US=user story, impl=implementation -->

## Spec: User Auth

P1 US: OAuth2 login, token refresh, session mgmt AC per US: Given/When/Then format, 2-5 per P1 US
CC: Art.1 (security), Art.9 (stack) — passed
```

Rules:

- Define abbreviations in a comment block at the top.
- Only abbreviate terms that appear 3+ times.
- Keep domain-specific terms unabbreviated (they're already precise).

### 3. Table Densification

Convert prose descriptions to tables:

**Before (85 tokens):**

```markdown
The authentication module handles three flows. The login flow accepts email and password, validates
credentials against the database, and returns a JWT token. The refresh flow accepts a refresh token
and returns a new access token. The logout flow invalidates the refresh token in the database.
```

**After (45 tokens):**

```markdown
| Flow    | Input            | Action            | Output           |
| ------- | ---------------- | ----------------- | ---------------- |
| Login   | email + password | validate vs DB    | JWT              |
| Refresh | refresh token    | validate + rotate | new access token |
| Logout  | refresh token    | invalidate in DB  | —                |
```

### 4. Redundancy Elimination

Remove information that can be derived:

- **Remove timestamps** if they can be found in git history.
- **Remove "Status: READY"** if the document's existence implies readiness.
- **Remove template placeholders** that were never filled in.
- **Remove meta-commentary** ("This section describes..." — just describe it).

### 5. Inline Code References

Replace file path descriptions with compact references:

**Before:**

```markdown
The authentication middleware is located in `src/infrastructure/auth/middleware.ts`. It imports the
token service from `src/application/services/token-service.ts` and the user repository from
`src/infrastructure/repositories/user-repository.ts`.
```

**After:**

```markdown
Auth middleware: `infra/auth/middleware.ts` → uses `app/services/token-service.ts`,
`infra/repos/user-repository.ts`
```

---

## Distillation Process

### Step 1: Measure

Count original lines and estimate tokens. Target: 40-60% reduction.

### Step 2: Identify redundancy

- Repeated phrases and patterns
- Template boilerplate that adds no information
- Verbose structures that can be tabularized
- Meta-commentary and filler text

### Step 3: Compress

Apply techniques 1-5 in order. After each technique, verify no information was lost.

### Step 4: Verify (Reconstruction Test)

Read the distilled version and ask: "Can I reconstruct the original meaning from this alone?"

- If yes for every section → distillation is valid.
- If no for any section → that section was over-compressed. Restore detail.

### Step 5: Mark as distilled

Add a header note so future readers know:

```markdown
<!-- Distilled from original (<original lines> → <distilled lines>). Full version in git history. -->
```

---

## When NOT to Distill

- **User-facing documents** (README, USER_GUIDE) — readability matters more than density.
- **Documents under 100 lines** — the overhead isn't worth it.
- **Legal or compliance text** — exact wording may be contractually required.
- **Code** — code has its own compression (functions, abstractions). Don't distill code.

## Anti-patterns

- **Lossy compression disguised as distillation** — If you can't reconstruct the original, it's
  summarization, not distillation.
- **Over-abbreviation** — `US→AC→CC→impl` is unreadable. Keep it parseable by a human.
- **Distilling too early** — Don't distill a spec that's still being written. Distill finished
  artifacts.
- **Distilling for storage** — Git stores the original. Distillation is for context windows, not for
  saving disk space.
