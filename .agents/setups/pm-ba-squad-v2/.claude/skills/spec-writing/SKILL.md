---
name: spec-writing
description: >
  Writing rich functional specs: user stories, acceptance criteria, business rules, non-functional
  requirements, edge cases. Examples and real anti-patterns. Loaded by product-owner,
  business-analyst, spec-reviewer.
---

# Spec Writing — Complete Guide

---

## Anatomy of a Complete Spec

```markdown
# Feature: [Feature name]

<!-- ID: FEAT-XXX -->
<!-- Author: [PM/PO/BA] -->
<!-- Version: 1.0 — Date: YYYY-MM-DD -->
<!-- Status: Draft | In Review | Approved | Implemented -->

## Context and problem solved

[2-3 sentences: why this feature exists, what user problem it solves]

## Users concerned

[Affected personas and their impact]

## Scope

### In scope

- [What is explicitly included]

### Out of scope

- [What will NOT be done in this iteration]
- [What will be done later — link to future feature]

## User Stories

### Story 1: [Title]

**As a** [persona] **I want** [action] **So that** [benefit]

#### Acceptance criteria

[Gherkin scenarios]

#### Business rules

- [BR-01]: [rule]
- [BR-02]: [rule]

## Edge cases and boundaries

[Cases not in the main scenarios but that must be specified]

## Non-Functional

- Performance: [e.g. page loads in < 2s with 10,000 bookings]
- Accessibility: [e.g. WCAG 2.1 AA minimum]
- Security: [e.g. only the owner can cancel their booking]

## Open questions

- [Question] → [Answer or "To decide before dev"]

## Dependencies

- [Feature or system this spec depends on]
- [Feature that depends on this spec]
```

---

## User Stories — Writing Precisely

### Format and granularity

```markdown
# ❌ Too broad — not directly implementable

As a user, I want to manage my bookings

# ❌ Too technical — talks about implementation

As a system, I want to call the cancellation API with a PUT on /api/bookings/{id}/cancel

# ✅ Right level — one user action, one clear benefit

As a logged-in traveller, I want to cancel a confirmed booking so that I am refunded according to
the applicable policy and my slot is freed up for other travellers
```

### Acceptance Criteria — Quality Levels

```gherkin
# ❌ Level 1 — too vague to be testable
Scenario: User cancels their booking
  Given a logged-in user
  When they cancel their booking
  Then the booking is cancelled

# ✅ Level 2 — clear observable behaviour
Scenario: Cancellation with full refund (more than 48h before)
  Given I am logged in as "Marie Dupont"
  And I have confirmed booking "RES-2024-042" starting March 20
  And today is March 17 (3 days before)
  When I cancel booking "RES-2024-042"
  Then I see: "Your booking has been cancelled. Refund of €120 within 5-7 business days."
  And the booking status is "Cancelled"
  And I receive a cancellation confirmation email

# ✅ Level 2+ — critical business rule with real data
Scenario: Boundary case — cancellation exactly 48h before
  Given I have a booking starting March 20 at 2pm
  And today is March 18 at 2pm (exactly 48h before)
  When I cancel my booking
  Then I am refunded 100%
  # Note: the rule is "more than 48h" — exactly 48h is the inclusive boundary
```

---

## Business Rules — Documenting Correctly

```markdown
## Business Rules: Cancellation Policy

### [BR-01] Refund thresholds

| Time before departure           | Refund rate |
| ------------------------------- | ----------- |
| > 48h                           | 100%        |
| Between 24h and 48h (inclusive) | 50%         |
| < 24h                           | 0%          |

**Boundary notes**:

- Exactly 48h → 100% (inclusive boundary for "more than 48h")
- Exactly 24h → 50% (inclusive boundary for "between 24h and 48h")

### [BR-02] Refund calculation

Refund is calculated on the total price paid (incl. tax). Service fees (max €5) are non-refundable.
Formula: Refund = (Total price incl. tax - Service fees) × Rate

Example:

- Booking: €120 incl. tax
- Service fee: €5
- Cancellation 3 days before (100% rate)
- Refund = (120 - 5) × 100% = €115

### [BR-03] Exceptions to standard policy

These cases fall under a special policy (out of scope for this feature):

- Medical cancellation with documentation
- Cancellation following government travel advisory
- Cancellation by the provider
```

---

## Edge Cases — What Specs Often Miss

```markdown
## Edge Cases — Booking Cancellation

### Temporal boundaries

- What if the booking starts today at midnight?
- What if the user's timezone differs from the provider's timezone?
- What if the exact departure time is unknown (e.g. "arrival March 20")? → Decision: use 12:00 as
  default departure time

### Booking states

- Can a booking be cancelled while in progress (traveller already there)? → No — cancel button
  hidden if status = "In progress"
- Can an already-cancelled booking be cancelled? → No — explicit error: "This booking has already
  been cancelled"
- Can a partially paid booking be cancelled? → Yes — refund only covers the amount actually paid

### Refund

- What if payment was made in instalments? → Out of scope — delivery 2: instalment payments do not
  allow online cancellation
- What if the refund card has expired? → Display a message and direct to customer support

### Concurrency

- What if two members of the same account attempt to cancel simultaneously? → The second
  cancellation receives "This booking has already been cancelled"
```

---

## Spec Quality Criteria

```
✓ Each business rule is numbered and referenceable (BR-01, BR-02...)
✓ Boundaries are specified (inclusive/exclusive)
✓ Edge cases are documented, not just the happy path
✓ Out of scope is explicit (avoids debates during dev)
✓ Dependencies are listed
✓ Open questions have a responsible owner and a deadline
✓ Numerical examples illustrate complex rules
✓ The spec can be read by someone not in the meeting
```

---

## Spec Anti-Patterns

```markdown
# ❌ Ambiguous spec

"The system must display an appropriate message on error" → What is "appropriate"? What exact text?

# ❌ Spec that implies an implementation

"The system saves the cancellation in the bookings table with status CANCELLED" → That's
implementation, not behaviour

# ❌ Spec without documented business rule

"The user can cancel their booking and be refunded" → Based on what rule? Under what conditions?
What amount?

# ✅ Clear and actionable spec

"When the user cancels a confirmed booking more than 48h before the start date, they are refunded
(total price incl. tax - service fees) within 5-7 business days to the original payment method."
```

## Available References

- `references/personas.md` — project personas and their needs
- `references/glossary.md` — domain glossary
- `references/non-functional.md` — non-functional criteria templates
