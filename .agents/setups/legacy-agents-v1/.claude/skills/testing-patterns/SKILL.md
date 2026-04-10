---
name: testing-patterns
description: >
  Canon TDD (Kent Beck), unit/integration/E2E testing patterns, mocking, test doubles, test pyramid.
  Auto-loaded by dev-senior-a/b, qa-engineer, tech-lead, spec-writer. Invoke for any TDD, test
  structure, or coverage strategy question.
---

# Testing Patterns Reference

## Canon TDD — The Workflow

Source: Kent Beck (2023) + 3 Laws of TDD (Uncle Bob)

```
1. TEST LIST  — list all behaviors to test (no code)
2. RED        — write ONE test that fails for the right reason
3. GREEN      — minimum code to make the test pass
4. BLUE       — refactor without breaking the tests
5. Repeat     — until the test list is empty
```

### The 3 Common Mistakes

```
Bad — write several tests before coding
Bad — refactor during GREEN (two hats at once)
Bad — write more code than necessary for GREEN
```

### Choose the Next Test (Starter Test principle)

- Start with the most trivial case (fixed return, empty input)
- Each test must be a step toward the goal
- If you get stuck → you took too big a step → step back

## AAA Structure (Arrange / Act / Assert)

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with hashed password', async () => {
      // ARRANGE
      const dto = { email: 'test@example.com', password: 'plain123' };
      const hasher = new FakePasswordHasher();
      const repo = new InMemoryUserRepository();
      const sut = new UserService(repo, hasher);

      // ACT
      const user = await sut.createUser(dto);

      // ASSERT
      expect(user.email).toBe(dto.email);
      expect(user.password).not.toBe(dto.password); // hashed
      expect(await repo.findByEmail(dto.email)).toBeDefined();
    });
  });
});
```

## Test Doubles (simplest to most complex)

```typescript
// DUMMY — object passed but never used
const dummyLogger = {} as Logger;

// STUB — returns predefined values
const stubRepo = { findById: async () => ({ id: '1', name: 'Alice' }) };

// FAKE — simplified but functional implementation (prefer fakes)
class InMemoryUserRepository implements UserRepository {
  private users = new Map<string, User>();
  async save(user: User) {
    this.users.set(user.id, user);
  }
  async findById(id: string) {
    return this.users.get(id) ?? null;
  }
}

// SPY — records calls
const spy = jest.spyOn(emailService, 'send');
expect(spy).toHaveBeenCalledWith(expect.objectContaining({ to: 'test@test.com' }));

// MOCK — verifies interactions (use sparingly)
const mockRepo = { save: jest.fn(), findById: jest.fn() };
```

**Rule**: prefer Fakes over Mocks. Fakes test behavior; Mocks test the implementation.

## Test Pyramid

```
        /\
       /E2E\       ← few, slow, flaky, expensive
      /------\
     /  Integ  \   ← a few per feature
    /------------\
   /     Unit     \ ← many, fast, deterministic
  /________________\
```

### Unit Tests

- Test an isolated unit (class, function)
- No DB, no HTTP, no filesystem
- Fast (< 1ms)
- Always deterministic

### Integration Tests

```typescript
// With a real DB (testcontainers or a test DB)
describe('UserRepository (integration)', () => {
  let db: Database;
  beforeAll(async () => {
    db = await createTestDatabase();
  });
  afterAll(async () => {
    await db.close();
  });
  afterEach(async () => {
    await db.truncate(['users']);
  });

  it('should persist and retrieve a user', async () => {
    const repo = new UserRepository(db);
    await repo.save(buildUser({ email: 'test@test.com' }));
    const found = await repo.findByEmail('test@test.com');
    expect(found?.email).toBe('test@test.com');
  });
});
```

### E2E Tests

```typescript
// Full HTTP with in-memory app
describe('POST /api/v1/auth/register', () => {
  it('should register a new user and return 201', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({ email: 'new@test.com', password: 'ValidPass1!' });
    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({ email: 'new@test.com' });
    expect(res.body).not.toHaveProperty('password');
  });
});
```

## Test Naming

```typescript
// Pattern: [unit] [expected behavior] [condition]
// Good
'should return null when user is not found';
'should throw InvalidEmailError when email format is wrong';
'should hash password before saving';

// Anti-patterns
// Bad
'test user creation'; // too vague
'it works'; // describes nothing
'test 1'; // useless
```

## Test Data Builders

```typescript
// Builder pattern for test data
function buildUser(overrides: Partial<User> = {}): User {
  return {
    id: randomUUID(),
    email: 'default@test.com',
    password: 'hashed_password',
    role: 'USER',
    createdAt: new Date('2024-01-01'),
    ...overrides,
  };
}

// Usage
const adminUser = buildUser({ role: 'ADMIN' });
const deletedUser = buildUser({ deletedAt: new Date() });
```

## What NOT to Test

- Trivial getters/setters with no logic
- Constructors with no logic
- External dependencies (test your own code, not Prisma)
- Implementation details (test behavior, not how)
