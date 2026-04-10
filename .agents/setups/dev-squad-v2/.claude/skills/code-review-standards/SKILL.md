---
name: code-review-standards
description: >
  Async code review standards for TypeScript. Per-layer checklist, examples of good and bad
  comments, constructive critique. Loaded by dev-senior-b and tech-lead.
---

# Code Review Standards — TypeScript

---

## Review Philosophy

Review has two distinct goals — do not mix them up:

1. **Find the bugs** — incorrect behaviours, unhandled cases, security
2. **Improve quality** — readability, maintainability, architecture

The goal is not to prove the code is bad. The goal is to improve the product collectively.

---

## How to Comment — The Difference Matters

### ❌ Destructive or vague comments

```
"This code is unreadable"
"Bad approach"
"Why are you doing this?"
"It doesn't work"
```

### ✅ Constructive comments with an example

```
// For a bug
"This case is not handled: if user is null here,
 we will get a TypeError on line 47.
 Suggestion: early return with a check or optional chaining."

// For a readability improvement
"This function does two things: validate and transform.
 Extracting the validation into validateUserInput() would improve
 readability and testability separately.
 What do you think of that approach?"

// For an architecture problem
"This use case depends directly on PrismaClient on line 12.
 That will couple every test to a real database.
 If we inject a UserRepository (interface), we can mock it in the tests.
 See the pattern in src/application/use-cases/RegisterUser.ts."
```

---

## Severity Levels

Always prefix comments with the level:

```
[BLOCKER]      → must be fixed before merge. Bug, security, architecture violation.
[SHOULD]       → should be fixed, not critical for this PR.
[SUGGESTION]   → possible improvement, not mandatory.
[QUESTION]     → clarification needed before judging.
[PRAISE]       → good practice to call out explicitly.
[NIT]          → minor stylistic detail.
```

### Examples

```typescript
// [BLOCKER] Possible SQL injection — never interpolate in a query
const users = await db.query(`SELECT * FROM users WHERE email = '${email}'`)
// → Use Prisma parameters: where: { email }

// [SHOULD] Password validation should live in the domain
// rather than the controller — this duplicates the business logic
if (password.length < 8) { ... }

// [SUGGESTION] `Array.from(map.values()).find()` can be written
// with destructuring: for (const user of map.values())
// but it's a matter of preference, not a problem.

// [QUESTION] Why do we generate a new token even if the old one
// is still valid? Is this intentional (security) or an oversight?

// [PRAISE] Nice use of discriminated unions here — TypeScript
// protects us from impossible states.

// [NIT] `const x` → `const userId` would be more expressive.
```

---

## Checklist per Layer

### Domain

```
[ ] Value objects: validation in the constructor, nowhere else
[ ] Entities: invariants enforced (no invalid state possible)
[ ] Business methods: named with domain vocabulary
[ ] Zero imports of external libraries (express, prisma, etc.)
[ ] Events emitted at the right times (in methods that change state)
[ ] Typed errors (no throw new Error('generic message'))
[ ] Unit tests without mocks of external services (pure domain)
```

### Application (Use Cases)

```
[ ] One responsibility per use case (SRP)
[ ] All ports (interfaces) injected as dependencies
[ ] Validation delegated to the domain (no validation here)
[ ] No business logic in the use case (delegate to entities)
[ ] Transactions handled correctly for multi-step operations
[ ] Events published after persistence (not before)
[ ] Tests with fakes/stubs, no real services
```

### Infrastructure

```
[ ] Implements exactly the port interface (no more, no less)
[ ] toDomain() and toPersistence() mapping separated and tested
[ ] Prisma/DB error handling (unique constraint, not found...)
[ ] No business logic in the adapters
[ ] No N+1 queries (include/eager loading)
[ ] Indexes present on filter columns
```

### Presentation (Controllers)

```
[ ] Input validation with Zod (before calling the use case)
[ ] Clear mapping HTTP input → use case input
[ ] Clear mapping use case output → HTTP response
[ ] No business logic in the controller
[ ] Correct status codes (201/200/204/400/401/403/404/409)
[ ] Domain errors mapped to HTTP errors
[ ] No sensitive data in responses (password hash, tokens)
```

---

## Patterns to Approve vs Reject

### ✅ Approve

```typescript
// Early return — readable, avoids nesting
async function getUser(id: UserId): Promise<User> {
  const user = await repo.findById(id);
  if (!user) throw new UserNotFoundError(id);
  if (user.isDeleted()) throw new DeletedUserError(id);
  return user;
}

// Expressive naming with business vocabulary
const hasExceededMaxAttempts = failedAttempts >= MAX_LOGIN_ATTEMPTS;
const isPremiumSubscriber = user.plan === Plan.PREMIUM;
const isEligibleForDiscount = order.totalHT > DISCOUNT_THRESHOLD;

// Typed and informative errors
throw new InsufficientStockError({
  productId: item.productId,
  requested: item.quantity,
  available: stock.quantity,
});
```

### ❌ Reject

```typescript
// [BLOCKER] Callback hell — move to async/await
getUser(id, (err, user) => {
  if (err) throw err
  getOrders(user.id, (err, orders) => { ... })
})

// [BLOCKER] Silent catch — errors disappear
try {
  await riskyOperation()
} catch (e) {
  // silent
}

// [BLOCKER] any type — loses all TypeScript safety
function processData(data: any): any {
  return data.items.map((x: any) => x.value)
}

// [SHOULD] Unhandled promise — risky fire and forget
emailService.send(welcomeEmail) // no await, error lost

// [SHOULD] Magic numbers
if (password.length < 8) { ... }     // 8 = ?
if (attempts > 5) { ... }             // 5 = ?
// → named constants: MIN_PASSWORD_LENGTH, MAX_LOGIN_ATTEMPTS

// [SHOULD] Comment that repeats the code
// Check if user exists
const user = await repo.findById(id)
// → the comment adds nothing. If needed: explain the WHY

// [NIT] Boolean flag as a parameter
sendEmail(user, true) // true = ?
// → object: sendEmail(user, { sendWelcome: true })
```

---

## PR Review — Response Structure

```markdown
## Review of [PR Name]

### Overview

[What I understood about the PR — 2-3 sentences]

### Verdict

APPROVE / APPROVE_WITH_CHANGES / REQUEST_CHANGES

### [BLOCKER] Blocking issues

[Numbered list of critical problems]

### [SHOULD] Suggestions

[List of non-critical points]

### [PRAISE] Positive points

[What is well done — always include at least one]

### [QUESTION] Open questions

[What I need to understand before judging]
```

---

## What Is NOT in Scope for Review

```
✗ Code style (single vs double quotes, etc.)
  → handled by ESLint/Prettier — configure and forget

✗ Personal preferences without objective justification
  → "I would have done it differently" without explanation = noise

✗ Refactoring the entire existing file
  → the PR has a scope. The rest = known debt = future PR

✗ Complete alternative designs in the review
  → that belongs upstream, not in the PR
```

---

## Available References

- `references/security-review.md` — OWASP, injections, auth, secrets
- `references/performance-review.md` — N+1, indexes, pagination
- `references/common-bugs-ts.md` — common TypeScript bugs to detect
