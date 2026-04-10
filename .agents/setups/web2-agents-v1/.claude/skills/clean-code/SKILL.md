---
name: clean-code
description: >
  SOLID principles, clean code, design patterns, naming, coupling, cohesion. Auto-loaded by
  tech-lead, architect, and dev-senior-a/b. Invoke directly for any OOP design question,
  refactoring, or pattern choice.
---

# Clean Code Reference

## SOLID

### S — Single Responsibility

One class/function = one reason to change.

```typescript
// ❌ does too many things
class UserService {
  createUser(data) {
    /* validation + save + email + log */
  }
}
// ✅ separated responsibilities
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
// ❌ modify the class for every new type
class PaymentProcessor {
  process(type: string) {
    if (type === 'stripe') { ... }
    if (type === 'paypal') { ... } // modify for every new provider
  }
}
// ✅ extend without modifying
interface PaymentProvider { charge(amount: number): Promise<void> }
class StripeProvider implements PaymentProvider { ... }
class PayPalProvider implements PaymentProvider { ... }
class PaymentProcessor { process(provider: PaymentProvider) { ... } }
```

### L — Liskov Substitution

A subtype can replace its parent without breaking the program.

### I — Interface Segregation

Prefer several specific interfaces over one general interface.

```typescript
// ❌ forces implementing unneeded methods
interface Repository {
  findAll();
  findById();
  save();
  delete();
  bulkImport();
}
// ✅
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
// ❌ tight coupling to the implementation
class OrderService {
  private db = new PostgresDB();
}
// ✅ dependency injection
class OrderService {
  constructor(private db: DatabasePort) {}
}
```

## Naming

```typescript
// Variables: name + context
❌ const d = new Date()
✅ const createdAt = new Date()

// Functions: verb + object
❌ function user(id) {}
✅ function getUserById(id: string): Promise<User> {}

// Booleans: is/has/can
❌ const active = user.subscription !== null
✅ const hasActiveSubscription = user.subscription !== null

// Classes: nouns (no generic Manager, Handler, Processor)
❌ class UserManager {}
✅ class UserRegistration {}
```

## Functions

```typescript
// Max 3 parameters → beyond that, use an object
❌ function createUser(name, email, password, role, plan) {}
✅ function createUser(dto: CreateUserDto) {}

// No hidden side effects
❌ function getUser(id) { logAccess(id); return user; } // surprising side effect
✅ function getUser(id) { return user; } // logAccess called separately

// Early return rather than nested else
❌ if (user) { if (user.active) { if (user.plan) { ... } } }
✅ if (!user) return null
   if (!user.active) return null
   if (!user.plan) return null
   // happy path here
```

## Anti-Patterns to Avoid

| Anti-pattern             | Problem                                   | Alternative                           |
| ------------------------ | ----------------------------------------- | ------------------------------------- |
| God Class                | One class does everything                 | Break up by responsibility            |
| Magic Numbers            | `if (status === 3)`                       | `if (status === OrderStatus.SHIPPED)` |
| Shotgun Surgery          | One change = 10 files                     | Group related logic                   |
| Feature Envy             | Class that uses another class's data more | Move the method                       |
| Primitive Obsession      | `string` for email, phone, etc.           | Value Objects                         |
| Long Method              | > 20 lines                                | Extract named functions               |
| Comments instead of code | `// check if user is premium`             | `if (user.isPremium())`               |

## The Boy Scout Rule

Leave the code a little cleaner than you found it. No unsolicited full refactorings — just a small
cleanup as you pass through.
