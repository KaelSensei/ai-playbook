---
name: canon-tdd
description: >
  Canon TDD (Kent Beck 2023) + 3 Laws of TDD (Uncle Bob) with real TypeScript examples. Strict
  RED-GREEN-REFACTOR. Loaded by dev-senior-a, dev-senior-b, tech-lead. The project's TDD reference.
---

# Canon TDD — TypeScript

Source: Kent Beck, _Test-Driven Development by Example_ (2003) + _Canon TDD_ (2023) + Robert Martin,
_The Three Laws of TDD_

---

## The 3 Laws (Uncle Bob) — Non-Negotiable

```
Law 1: You may not write production code
       until you have first written a failing test.

Law 2: You may not write more of a test
       than is sufficient to fail.
       (A failing compilation counts as a failure)

Law 3: You may not write more production code
       than is sufficient to make the failing test pass.
```

---

## The RED → GREEN → REFACTOR Cycle

### 🔴 RED — Write ONE failing test

**RED Rules:**

- One test at a time — never two
- The test must fail for the **right reason** (assertion failure, not compile error)
- The test name describes the behaviour, not the implementation

```typescript
// ✅ Good name — describes behaviour
it('should reject a negative price', () => { ... })
it('should apply 20% VAT for standard products', () => { ... })
it('should throw InsufficientFundsError when balance is zero', () => { ... })

// ❌ Bad name — describes implementation
it('should call calculateVAT method', () => { ... })
it('should set isValid to false', () => { ... })
```

**AAA Structure (Arrange / Act / Assert):**

```typescript
it('should calculate total price with VAT', () => {
  // ARRANGE — set up state
  const product = new Product({ name: 'Laptop', priceHT: 1000 });
  const vatRate = VATRate.standard(); // 20%

  // ACT — trigger the action
  const result = product.calculateTTC(vatRate);

  // ASSERT — verify the result
  expect(result).toEqual(Money.of(1200, 'EUR'));
});
```

**The test must fail first — check the error message:**

```
Expected: Money { amount: 1200, currency: 'EUR' }
Received: undefined   ← good, class doesn't exist yet

NOT acceptable:
TypeError: Cannot read property 'calculateTTC' of undefined
← setup error, not assertion failure
```

---

### 🟢 GREEN — Minimum code to pass

**GREEN Rules:**

- Absolute MINIMUM. Nothing more.
- Hard-code for the first test if necessary
- Duplication is **allowed** — it's temporary
- Do NOT refactor during GREEN

```typescript
// First test: verify 1000€ HT → 1200€ TTC
// Acceptable GREEN — even if hardcoded
class Product {
  calculateTTC(_vatRate: VATRate): Money {
    return Money.of(1200, 'EUR'); // temporary hardcode
  }
}
```

**When to add a second test to generalise:**

```typescript
// Second test forces generalisation
it('should calculate total price with VAT for different amount', () => {
  const product = new Product({ name: 'Mouse', priceHT: 500 });
  const vatRate = VATRate.standard();
  const result = product.calculateTTC(vatRate);
  expect(result).toEqual(Money.of(600, 'EUR'));
});

// Now hardcode no longer works → implement for real
class Product {
  constructor(private props: { name: string; priceHT: number }) {}

  calculateTTC(vatRate: VATRate): Money {
    const ttc = this.props.priceHT * (1 + vatRate.value);
    return Money.of(ttc, 'EUR');
  }
}
```

---

### 🔵 REFACTOR — Eliminate duplication

**REFACTOR Rules:**

- Tests stay GREEN throughout
- Goal: eliminate **duplication**, not "clean up"
- No new functionality during refactor
- Small steps — one change at a time

```typescript
// BEFORE refactor — visible duplication
class OrderService {
  createOrder(items: CartItem[]): Order {
    const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
    const vat = subtotal * 0.2;
    const total = subtotal + vat;
    return new Order({ subtotal, vat, total, items });
  }

  calculateOrderTotal(items: CartItem[]): number {
    const subtotal = items.reduce((sum, item) => sum + item.price * item.qty, 0);
    const vat = subtotal * 0.2;
    return subtotal + vat;
  }
}

// AFTER refactor — duplication eliminated
class OrderService {
  createOrder(items: CartItem[]): Order {
    const total = this.calculateOrderTotal(items);
    return new Order({ ...total, items });
  }

  calculateOrderTotal(items: CartItem[]): OrderTotal {
    const subtotal = this.calculateSubtotal(items);
    const vat = this.applyStandardVAT(subtotal);
    return { subtotal, vat, total: subtotal + vat };
  }

  private calculateSubtotal(items: CartItem[]): number {
    return items.reduce((sum, item) => sum + item.price * item.qty, 0);
  }

  private applyStandardVAT(amount: number): number {
    return amount * VATRate.STANDARD;
  }
}
```

---

## Test List — The Mandatory Starting Point

Before writing the first test, **write the complete test list**. This is the plan. It evolves as you
implement.

```typescript
// Test list for UserRegistration
describe('UserRegistration', () => {
  // Happy path
  it('should register a user with valid email and password');
  it('should hash the password before saving');
  it('should return the created user without the password');
  it('should send a welcome email after registration');

  // Validation
  it('should reject an invalid email format');
  it('should reject a password shorter than 8 characters');
  it('should reject a password without uppercase');
  it('should reject a password without number');

  // Business rules
  it('should reject a duplicate email');
  it('should assign USER role by default');
  it('should generate a unique ID for each user');

  // Error cases
  it('should throw EmailAlreadyExistsError for duplicate');
  it('should throw WeakPasswordError with violations list');
  it('should rollback if email sending fails');
});
```

**Start with the simplest test** (Starter Test):

```typescript
// First test: the most trivial case
// Not the full happy path — just the foundation
it('should create a user with the provided email', async () => {
  const registration = new UserRegistration(mockRepo, mockEmailer);
  const user = await registration.execute({ email: 'a@b.com', password: 'Valid1Pass!' });
  expect(user.email).toBe('a@b.com');
});
```

---

## Test Doubles — What to Use and When

### Stub — returns predefined values

```typescript
const userRepositoryStub: UserRepository = {
  findByEmail: jest.fn().mockResolvedValue(null),
  save: jest.fn().mockResolvedValue(undefined),
};
```

### Fake — simplified but functional implementation (preferred over mocks)

```typescript
class InMemoryUserRepository implements UserRepository {
  private users: Map<string, User> = new Map();

  async findByEmail(email: string): Promise<User | null> {
    return this.users.get(email) ?? null;
  }

  async save(user: User): Promise<void> {
    this.users.set(user.email, user);
  }

  all(): User[] {
    return Array.from(this.users.values());
  }
}

// Usage
const repo = new InMemoryUserRepository();
const registration = new UserRegistration(repo, mockEmailer);
await registration.execute({ email: 'a@b.com', password: 'Valid1Pass!' });
expect(repo.all()).toHaveLength(1);
```

### Spy — records calls (use sparingly)

```typescript
const emailerSpy = { send: jest.fn().mockResolvedValue(undefined) };

await registration.execute({ email: 'a@b.com', password: 'Valid1Pass!' });

expect(emailerSpy.send).toHaveBeenCalledOnce();
expect(emailerSpy.send).toHaveBeenCalledWith(expect.objectContaining({ to: 'a@b.com' }));
```

**Rule**: Prefer **Fakes** over **Mocks**. Fakes test behaviour. Mocks test implementation.

---

## TDD Anti-Patterns — What NOT to Do

### Tests that test implementation

```typescript
// ❌ Implementation test — brittle, breaks on refactoring
it('should call hashPassword method', () => {
  const spy = jest.spyOn(service, 'hashPassword');
  await registration.execute(validInput);
  expect(spy).toHaveBeenCalled();
});

// ✅ Behaviour test — robust
it('should not store plain text password', async () => {
  await registration.execute({ email: 'a@b.com', password: 'MyPass1!' });
  const saved = await repo.findByEmail('a@b.com');
  expect(saved!.passwordHash).not.toBe('MyPass1!');
  expect(saved!.passwordHash).toMatch(/^\$2[ab]\$/); // bcrypt format
});
```

### Too much code before tests

```typescript
// ❌ Write 200 lines of code then test them
// Tests arrive too late — confirming what was written, not guiding it

// ✅ One test → minimum code → one test → minimum code
// Never more than 3-5 lines of prod code without a corresponding test
```

### Vague assertions

```typescript
// ❌ Too vague
expect(result).toBeTruthy();
expect(error).toBeDefined();

// ✅ Precise — verifies the exact expected behaviour
expect(result).toEqual(Money.of(1200, 'EUR'));
expect(error).toBeInstanceOf(WeakPasswordError);
expect(error.message).toContain('must contain at least one uppercase');
```

---

## Available References

- `references/test-naming.md` — naming patterns with examples
- `references/test-data-builders.md` — builder pattern for fixtures
- `references/async-testing.md` — async/await, timers, events
- `references/error-testing.md` — testing typed errors and exceptions
