---
name: refinement-process
description: >
  Backlog refinement process: preparation, facilitation, Definition of Ready criteria, refinement
  output, estimation. Templates and concrete examples. Loaded by product-owner and business-analyst.
---

# Refinement Process — Backlog Grooming

---

## Definition of Ready (DoR) — Exit Criteria

A story is "ready for dev" when it passes **all** of these criteria:

```
UNDERSTANDING:
[ ] A developer who was not in the meeting can implement it
[ ] Vocabulary used is in the domain glossary
[ ] Dependencies with other stories/features are identified

ACCEPTANCE CRITERIA:
[ ] Each AC is a complete Gherkin scenario (Given/When/Then)
[ ] All important business rules have a dedicated scenario
[ ] Main error cases have their ACs (not just the happy path)
[ ] Edge cases (boundaries, null values, concurrency) are documented

BUSINESS RULES:
[ ] Each rule is numbered (BR-XX) and referenceable
[ ] Thresholds and boundaries specified (inclusive/exclusive)
[ ] Formulas illustrated with numerical examples

SCOPE:
[ ] Scope is explicit
[ ] Out of scope is explicit (what will NOT be done)
[ ] Story is small enough to be delivered in one sprint

TECHNICAL:
[ ] Wireframes (if UI) are available or referenced
[ ] API contracts (if external dependency) are known
[ ] Open questions have been resolved (no "TBD" in ACs)
```

**A story with a single unchecked criterion does not go to dev.**

---

## Pre-Refinement Preparation (PO/BA)

### 3 days before the session

```
1. Select stories to refine (top 5-8 of the prioritised backlog)
2. For each story:
   a. Check the description is readable cold
   b. Prepare known open questions
   c. Identify experts to invite (legal, support, providers)
3. Distribute stories to participants 24h before
   → Devs arrive with questions, not blank stares
```

### Session agenda template (60 min)

```
00-05: Reminder of the goal — "We refine, we don't estimate yet"
05-25: Story 1 (read, questions, ACs, rules) — 20 min max
25-45: Story 2
45-55: Story 3 if time allows
55-60: DoR decision for each story, next actions
```

---

## Facilitating a Refinement Session

### For each story:

**1. Read aloud** (2 min) The PO reads the story without interpretation. If someone doesn't
understand → the problem is in the story.

**2. Round-table — Questions** (5 min max)

```
Rule: one question at a time, no parallel resolution
If the answer is not immediately known → note it, assign it, continue
```

**3. AC walkthrough** (10 min)

```
For each Gherkin scenario:
- "Does this scenario correctly describe what should happen?"
- "Which scenario is missing?"
- "Can anyone think of a case that breaks the current ACs?"
```

**4. Red Flag Check** (2 min)

```
"Is there an undefined term?"
"Is there an uncovered edge case?"
"Is there a dependency we haven't noted?"
```

**5. DoR verdict** (1 min)

```
READY: all criteria met → goes into sprint backlog
NOT READY + next actions: who does what before the next session
SPLIT NEEDED: story is too big → split it now
```

---

## Splitting — Breaking Up Oversized Stories

### By user flow

```
Feature: Booking management

Oversized story: "As a traveller, I want to manage my bookings"

Split by flow:
→ US-01: View list of my bookings
→ US-02: View booking details
→ US-03: Cancel a confirmed booking
→ US-04: Change a booking date
```

### By business rule

```
Oversized story: "Cancel a booking with refund"

Split by rule:
→ US-03a: Cancel with full refund (>48h) — baseline policy
→ US-03b: Cancel with partial refund (24-48h) — delivery 2
→ US-03c: Cancel with no refund (<24h) — delivery 2
→ US-03d: Special cancellation policy (medical, provider) — delivery 3
```

### By user type

```
Oversized story: "View bookings (admin + traveller)"

Split by persona:
→ US-04a: Traveller sees their own bookings
→ US-04b: Admin sees all bookings with filters
```

### The splitting rule

```
Each sub-story must deliver value independently.
"Create the data model" is NOT a story — it is a technical task.
```

---

## Estimation — T-Shirt Sizes

```
XS: < 1 day. A few lines, simple test, isolated impact.
    Example: change a label, add an optional field
S:  1-2 days. Simple feature, one main layer, obvious tests.
    Example: display a paginated list without filters
M:  3-4 days. Standard feature, multiple layers, multiple error cases.
    Example: form with validation + API + email
L:  5 days (1 sprint). Complex feature, many cases, dependencies.
    → Consider splitting
XL: > 1 sprint. MUST be split before entering a sprint.
```

**Signals for L/XL that need splitting:**

- "It depends on..." (unresolved dependency)
- "We first need to..." (unmodelled blocker)
- "It's complicated because..." (too-dense business rule)
- Nobody in the room is comfortable estimating

---

## Refinement Output — Meeting Notes Template

```markdown
## Refinement — [Date]

### Stories moved to READY

| Story                          | Size | Target sprint |
| ------------------------------ | ---- | ------------- |
| US-03 Cancellation with refund | M    | Sprint 8      |
| US-07 PDF export of bookings   | S    | Sprint 8      |

### Stories not yet READY

| Story                    | Blocker                | Owner      | Deadline |
| ------------------------ | ---------------------- | ---------- | -------- |
| US-11 Instalment payment | Refund rules undefined | Marie (PO) | 15/03    |

### New stories created (splits)

- US-03a, US-03b, US-03c from split of US-03

### Open questions resolved

- [Question] → [Answer] (source: [who])

### Next session

Date: [date] — Stories planned: [list]
```
