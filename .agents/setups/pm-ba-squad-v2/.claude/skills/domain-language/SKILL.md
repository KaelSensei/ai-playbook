---
name: domain-language
description: >
  Building and maintaining the ubiquitous language. Domain glossary, vocabulary anti-patterns,
  techniques for extracting language from business experts. Loaded by PO, BA, Spec Reviewer.
---

# Domain Language — Ubiquitous Language

Source: Eric Evans, _Domain-Driven Design_ (2003), Chapter 2

---

## Why Ubiquitous Language

> "If the domain experts don't use the word 'policy', don't use it in your specs. If developers say
> 'mapping' when the business says 'correspondence', you have a problem."

A shared vocabulary prevents:

- Misunderstandings between business and tech
- Bugs caused by implicit translations
- Specs that use different terms for the same thing
- Code that speaks a different language from the specs

---

## Glossary Structure

```markdown
# Domain Glossary — [Project Name]

<!-- Last updated: YYYY-MM-DD -->
<!-- Owner: Business Analyst -->

## [Term]

**Definition**: [What it means in this specific context] **Examples**: [2-3 concrete examples] **Do
not confuse with**: [Similar but different term] **Rejected synonyms**: [Terms to avoid even if they
seem equivalent] **Used in**: [Features, specs where this term appears]
```

---

## Example — Travel/Insurance Domain

```markdown
## Booking

**Definition**: A formal agreement between a traveller and a provider for a travel service at
specific dates, resulting in full or partial payment. A booking can be in one of the following
statuses: Draft → Confirmed → In progress → Completed | Cancelled. **Examples**:

- Hotel room March 15–20 in Lyon
- Flight Paris–Tokyo April 5 at 2:30pm
- Car rental July 1–7 in Barcelona **Do not confuse with**:
- "Order": e-commerce term, do not use
- "booking" (lowercase): acceptable verbally between devs but not in specs **Rejected synonyms**:
  "order", "request", "purchase" **Used in**: FEAT-012 Cancellation, FEAT-018 Refund, FEAT-025
  History

## Cancellation policy

**Definition**: Rules that determine the conditions and refund amount when a booking is cancelled.
Each provider can define their own policy. A default platform policy exists. **Examples**:

- "Free cancellation up to 48h before arrival"
- "Non-refundable"
- "50% refunded if cancelled between 24h and 48h" **Do not confuse with**:
- "Terms and conditions": broader set also including usage rules
- "Right of withdrawal": legal term, different from commercial policy **Rejected synonyms**:
  "cancellation rules", "cancellation conditions"

## Refund

**Definition**: Restitution of part or all of the amount paid by the traveller, following
cancellation of a booking or a resolved dispute. Refund is always calculated on the total price paid
(incl. tax), excluding service fees (non-refundable except for provider cancellation). **Examples**:

- Full refund (100%): cancellation >48h before with standard policy
- Partial refund (50%): cancellation between 24h and 48h
- 0% refund: cancellation <24h with standard policy **Do not confuse with**:
- "Credit": account credit usable on the platform, distinct from refund
- "Compensation": unilateral commercial gesture from the provider **Rejected synonyms**:
  "reimbursement", "money back", "credit"
```

---

## Techniques for Extracting Expert Language

### Active listening during interviews

```
When an expert says an important word → note it exactly
"You said 'cancel' and 'terminate' — are these the same thing in your domain?"
"When do you say 'refund' vs 'credit'?"
"This 'file' you mentioned — is it the same thing as a 'booking'?"
```

### Clarifying questions on boundaries

```
"Can a booking 'in progress' be cancelled?"
"The cancellation policy — is it set at creation or can it change?"
"'Confirmed status' — is that when the provider confirms or when payment goes through?"
```

### Testing the glossary

After writing a spec, have a domain expert read it with these questions:

- "Are there any words you wouldn't use?"
- "Are there any words that mean something different to you?"
- "Are there any important distinctions missing?"

---

## Vocabulary Anti-Patterns

```
❌ Mixing English and native language terms in specs
   "booking", "user", "order" → pick one language and stick to it

❌ Using synonyms as if they were equivalent
   "order" / "booking" / "purchase" → define which one is canonical

❌ Technical terms in functional specs
   "the DB records", "the API returns 404" → specs speak business

❌ Undefined internal jargon
   "gold client", "premium profile" → define what it actually means

❌ Vague verbs
   "manage", "process", "handle" → specify the concrete action
```
