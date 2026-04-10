# Domain Glossary — Template

## How to Use This File

This file is the **source of truth for the project's vocabulary**. Any term used in a spec must be
defined here or reference this glossary.

Rules:

- Add every new business term while writing a spec
- Flag ambiguities and false synonyms
- Validate definitions with domain experts, not just developers

---

## Entry Template

```markdown
### [Canonical term]

**Definition**: [Precise description in the context of the project] **Examples**:

- [Example 1]
- [Example 2] **Do not confuse with**: [Similar but different term] **Rejected terms**: [What we
  will NOT use — and why] **Used in**: [Features or domains where this term appears]
```

---

## Glossary Template — E-commerce / Booking Domain

> Copy-paste this block as a starting point, then adapt it to the real project

### Order

**Definition**: A formalised purchase of one or more products by a customer, resulting in a payment
and a delivery. **Examples**:

- An order of 3 items placed on March 15, delivered on March 18 **Do not confuse with**: Booking
  (future service), Quote (non-binding) **Rejected terms**: "purchase" (too generic), "transaction"
  (accounting term, not business)

### User

**Definition**: A person with an account on the platform. Covers several roles: customer,
administrator, support. **Do not confuse with**:

- "Customer": subset of users who have placed at least one order
- "Visitor": unauthenticated person without an account **Rejected terms**: "member" (club /
  subscription connotation), "account holder" (too formal)

### Cart

**Definition**: A temporary selection of items by a user, not yet confirmed. The cart is tied to the
session and can expire. **Do not confuse with**: Order (finalised commitment) **Rejected terms**:
"basket" (depends on locale — pick one and stick to it), "selection" (too vague)

### Refund

**Definition**: Restitution of part or all of the amount paid by the customer, following a
cancellation or a resolved dispute. **Do not confuse with**:

- "Credit": store credit on the account, usable on a future purchase
- "Compensation": unilateral commercial gesture **Rejected terms**: "reimbursement" (inconsistent
  with codebase), "money back" (informal)

---

## Empty Entries — To Be Filled by the Team

> Replace this block with the terms of the project's real domain

### [Term 1]

**Definition**: To be defined **Status**: Not validated

### [Term 2]

**Definition**: To be defined **Status**: Not validated

---

## False Friends — Terms That Must Always Be Defined

A list of terms that look clear but are systematically ambiguous in projects. Define them upfront:

```
"Validate"  → Validated by whom? The system? A human? What action triggers it?
"Active"    → Active = not deleted? Or active = ongoing subscription?
"Edit"      → A single field? The whole profile? Does it trigger a notification?
"Send"      → Email? Push notification? SMS? All three?
"Archive"   → Soft delete? Status change? Visible only to admins?
"Confirm"   → By the user? By the provider? By the system?
"Status"    → What exact enum? Are the values listed in this glossary?
```
