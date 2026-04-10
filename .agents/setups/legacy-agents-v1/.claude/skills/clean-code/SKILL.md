---
name: clean-code
description: >
  SOLID principles, clean code, design patterns, naming, coupling, cohesion. Auto-loaded by
  tech-lead, architect, dev-senior-a/b. Invoke directly for any OOP design, refactoring, or
  pattern-selection question.
---

# Clean Code Reference

## SOLID

### S — Single Responsibility

One class/function = one reason to change.

```typescript
// Bad — does too many things
class UserService {
  createUser(data) {
    /* validation + save + email + log */
  }
}
// Good — separated responsibilities
class UserService {
  createUser(dto) {
    /* orchestrate */
  }
}
class UserValidator {
  validate(dto) {
    /* validation only */
  }
}
class UserRepository {
  save(user) {
    /* persistence only */
  }
}
class EmailService {
  sendWelcome(user) {
    /* email only */
  }
}
```

### O — Open/Closed

Open for extension, closed for modification.

```typescript
// Bad — modify the class for each new type
class PaymentProcessor {
  process(type: string) {
    if (type === 'stripe') { ... }
    if (type === 'paypal') { ... } // modify for each new provider
  }
}
// Good — extend without modifying
interface PaymentProvider { charge(amount: number): Promise<void> }
class StripeProvider implements PaymentProvider { ... }
class PayPalProvider implements PaymentProvider { ... }
class PaymentProcessor { process(provider: PaymentProvider) { ... } }
```

### L — Liskov Substitution

A subtype can replace its parent without breaking the program.

### I — Interface Segregation

Prefer several specific interfaces to one general interface.

```typescript
// Bad — forces implementing unnecessary methods
interface Repository {
  findAll();
  findById();
  save();
  delete();
  bulkImport();
}
// Good
interface Reader {
  findAll();
  findById();
}
interface Writer {
  save();
  delete();
}
```

### D — Dependency Inversion

Depend on abstractions, not on implementations.

```typescript
// Bad — tight coupling to the implementation
class OrderService {
  private db = new PostgresDB();
}
// Good — dependency injection
class OrderService {
  constructor(private db: DatabasePort) {}
}
```

## Naming

```typescript
// Variables: name + context
// Bad
const d = new Date();
// Good
const createdAt = new Date();

// Functions: verb + object
// Bad
function user(id) {}
// Good
function getUserById(id: string): Promise<User> {}

// Booleans: is/has/can
// Bad
const active = user.subscription !== null;
// Good
const hasActiveSubscription = user.subscription !== null;

// Classes: nouns (no generic Manager, Handler, Processor)
// Bad
class UserManager {}
// Good
class UserRegistration {}
```

## Functions

```typescript
// Max 3 parameters → beyond, use an object
// Bad
function createUser(name, email, password, role, plan) {}
// Good
function createUser(dto: CreateUserDto) {}

// No hidden side effects
// Bad
function getUser(id) { logAccess(id); return user; } // surprising side effect
// Good
function getUser(id) { return user; } // logAccess called separately

// Early return rather than nested else
// Bad
if (user) { if (user.active) { if (user.plan) { ... } } }
// Good
if (!user) return null
if (!user.active) return null
if (!user.plan) return null
// happy path here
```

## Anti-Patterns to Avoid

| Anti-pattern             | Problem                                             | Alternative                           |
| ------------------------ | --------------------------------------------------- | ------------------------------------- |
| God Class                | One class does everything                           | Split by responsibility               |
| Magic Numbers            | `if (status === 3)`                                 | `if (status === OrderStatus.SHIPPED)` |
| Shotgun Surgery          | One change = 10 files                               | Group the related logic               |
| Feature Envy             | A class uses another class's data more than its own | Move the method                       |
| Primitive Obsession      | `string` for email, phone, etc.                     | Value Objects                         |
| Long Method              | > 20 lines                                          | Extract named functions               |
| Comments instead of code | `// check if user is premium`                       | `if (user.isPremium())`               |

## The Boy Scout Rule

Leave the code a little cleaner than you found it. No unsolicited full refactoring — just a small
cleanup in passing.
