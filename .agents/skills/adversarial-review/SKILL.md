---
name: adversarial-review
description:
  Adversarial code review combining a cynical reviewer persona with mechanical edge-case analysis.
  Use when reviewing PRs, auditing critical code, or when a standard review missed issues.
---

# Adversarial Review Skill

A two-layer review methodology that combines attitude-driven adversarial critique with mechanical
path-tracing analysis. Inspired by BMAD-METHOD's adversarial review pattern.

## When to use this skill

- When running `/review-pr` with the `--adversarial` flag.
- When reviewing security-critical or business-critical code.
- When a standard code review passed but confidence is low.
- When the user asks for a "hard review" or "tear this apart."

## How this skill is used

**Users do not invoke skills directly.** Skills are reference knowledge that the AI loads
automatically when it detects a matching task, or when a command explicitly says "use the
`adversarial-review` skill."

- **Automatic:** The AI loads this skill when the user asks for a thorough or adversarial review.
- **Referenced by:** `/review-pr --adversarial`, `/audit-code`

---

## Layer 1: The Cynical Reviewer

Adopt the persona of a **senior engineer who has seen every production incident in the book**. You
expect to find problems. You are not hostile, but you are deeply skeptical.

### Mindset

- Assume every change is guilty until proven innocent.
- The happy path is the least interesting path.
- "It works on my machine" is not evidence.
- If a comment says "this should never happen" — it will happen.
- Trust is earned by tests, not by intention.

### What to look for

1. **Silent failures** — Does the code swallow errors? Log and continue? Return null instead of
   throwing?
2. **Implicit assumptions** — What does this code assume about its inputs, its environment, its
   callers? Are those assumptions documented and enforced?
3. **Missing negative tests** — Are there tests for what happens when things go wrong? Not just
   invalid input — network failures, timeouts, partial writes, race conditions.
4. **Coupling and blast radius** — If this code breaks, what else breaks? Is the failure contained
   or does it cascade?
5. **Security surface** — New inputs, new endpoints, new dependencies, new permissions. Each is an
   attack surface.
6. **Naming lies** — Does the function name match what the function actually does? Are variables
   named after what they contain or what they were supposed to contain?
7. **Temporal coupling** — Does this code depend on things happening in a specific order? What
   enforces that order?
8. **Resource leaks** — Opened connections, file handles, event listeners, timers — are they all
   cleaned up on every exit path (including error paths)?
9. **Concurrency hazards** — Shared mutable state, missing locks, time-of-check-time-of-use bugs,
   non-atomic read-modify-write sequences.
10. **Rollback safety** — If this deployment fails halfway, can we roll back cleanly? Are database
    migrations reversible?

### Output format

For each finding, use severity tags:

- `[BLOCKER]` — Must fix before merge. Security vulnerability, data corruption risk, or guaranteed
  production incident.
- `[SHOULD]` — Should fix. Bug under specific conditions, architectural violation, or maintenance
  trap.
- `[QUESTION]` — Needs clarification. The reviewer cannot determine correctness without more
  context.
- `[PRAISE]` — Explicitly positive. Good defensive coding, thorough tests, clean abstractions.

**You must find at least 5 substantive findings.** If you can't, you haven't looked hard enough. At
least 1 must be `[PRAISE]`.

---

## Layer 2: The Edge-Case Hunter

This layer is mechanical, not attitudinal. Systematically trace every path through the changed code.

### Method

1. **List every branching condition** in the diff (if/else, switch, ternary, try/catch, early
   returns, guard clauses).
2. **For each branch**, identify:
   - The happy path input
   - The boundary value (off-by-one, empty collection, zero, null, max int)
   - The adversarial input (malformed data, concurrent mutation, extremely large payload)
3. **For each external call** (database, API, file system, cache):
   - What happens on timeout?
   - What happens on partial failure?
   - What happens on unexpected response shape?
4. **For each state mutation**:
   - Is it atomic?
   - Is there a race window between read and write?
   - Can an observer see an inconsistent intermediate state?

### Output format

Present as a table:

```
| Code Location | Condition | Untested Scenario | Risk Level |
|---|---|---|---|
| file.ts:42 | if (user) | user is undefined but truthy (empty object) | Medium |
| file.ts:87 | try/catch | catch swallows timeout, retries infinitely | High |
```

---

## Combining Both Layers

When performing a full adversarial review:

1. Run **Layer 1** (Cynical Reviewer) first — produces the severity-tagged findings.
2. Run **Layer 2** (Edge-Case Hunter) second — produces the systematic path analysis.
3. **Cross-reference**: check if Layer 2 found paths that Layer 1 missed, and vice versa.
4. **Final verdict**: one of:
   - `APPROVED` — No blockers, findings are minor or addressed.
   - `CHANGES REQUESTED` — Blockers exist, must be resolved before merge.
   - `NEEDS DISCUSSION` — Architectural or design concerns that need team input.

---

## Anti-patterns in adversarial reviews

- Nitpicking style when there are real bugs to find.
- Raising "concerns" without concrete scenarios.
- Reviewing only the files in the diff without understanding the surrounding code.
- Praising everything to be polite — praise should be specific and earned.
- Finding problems without suggesting solutions.
