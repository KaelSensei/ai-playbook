# Testing Errors in TypeScript

## Typed Errors — Hierarchy

```typescript
// Base errors — place in domain/errors/
export abstract class DomainError extends Error {
  abstract readonly code: string;
  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    // Fix prototype chain for instanceof
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export class EmailAlreadyExistsError extends DomainError {
  readonly code = 'EMAIL_ALREADY_EXISTS';
  constructor(readonly email: string) {
    super(`Email "${email}" is already registered`);
  }
}

export class WeakPasswordError extends DomainError {
  readonly code = 'WEAK_PASSWORD';
  constructor(readonly violations: string[]) {
    super(`Password does not meet requirements: ${violations.join(', ')}`);
  }
}

export class UserNotFoundError extends DomainError {
  readonly code = 'USER_NOT_FOUND';
  constructor(readonly userId: string) {
    super(`User "${userId}" not found`);
  }
}
```

## Testing That an Error is Thrown

```typescript
// Method 1: rejects.toThrow (simple)
it('should throw EmailAlreadyExistsError for duplicate email', async () => {
  await repo.save(aUser({ email: 'taken@test.com' }));

  await expect(
    registration.execute({ email: 'taken@test.com', password: 'Pass1!xy' })
  ).rejects.toThrow(EmailAlreadyExistsError);
});

// Method 2: rejects.toMatchObject (check properties)
it('should include email in error', async () => {
  await repo.save(aUser({ email: 'taken@test.com' }));

  await expect(
    registration.execute({ email: 'taken@test.com', password: 'Pass1!xy' })
  ).rejects.toMatchObject({
    code: 'EMAIL_ALREADY_EXISTS',
    email: 'taken@test.com',
    message: expect.stringContaining('taken@test.com'),
  });
});

// Method 3: explicit catch (detailed checks)
it('should list all password violations', async () => {
  try {
    await registration.execute({ email: 'user@test.com', password: 'abc' });
    fail('Expected WeakPasswordError to be thrown');
  } catch (error) {
    expect(error).toBeInstanceOf(WeakPasswordError);
    const e = error as WeakPasswordError;
    expect(e.violations).toContain('must be at least 8 characters');
    expect(e.violations).toContain('must contain at least one uppercase letter');
    expect(e.violations).toContain('must contain at least one number');
  }
});
```

## Testing Synchronous Errors

```typescript
// For Value Objects — validation in the constructor
it('should throw for invalid email format', () => {
  expect(() => Email.create('not-an-email')).toThrow(InvalidEmailError);
});

it('should throw for empty email', () => {
  expect(() => Email.create(''))
    .toThrow(new InvalidEmailError('Email cannot be empty'))
    // OR
    .toThrow('Email cannot be empty');
});

// Verify that an error is NOT thrown
it('should not throw for valid email', () => {
  expect(() => Email.create('valid@test.com')).not.toThrow();
});
```

## Testing Error Mapping Domain → HTTP

```typescript
// In the controller's integration tests
describe('POST /api/users — error mapping', () => {
  it('should return 409 for duplicate email', async () => {
    await repo.save(aUser({ email: 'taken@test.com' }));

    const response = await request(app)
      .post('/api/users')
      .send({ email: 'taken@test.com', password: 'Pass1!xy' });

    expect(response.status).toBe(409);
    expect(response.body).toMatchObject({
      error: { code: 'EMAIL_ALREADY_EXISTS' },
    });
    // Do not expose the email address in the public error message
    expect(response.body.error.message).not.toContain('taken@test.com');
  });

  it('should return 400 with details for weak password', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'new@test.com', password: 'abc' });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('WEAK_PASSWORD');
    expect(response.body.error.violations).toBeInstanceOf(Array);
    expect(response.body.error.violations.length).toBeGreaterThan(0);
  });
});
```

## Unexpected Errors — Do Not Mask

```typescript
// ✅ Handle known business errors, let the others propagate
try {
  await registration.execute(input);
} catch (error) {
  if (error instanceof EmailAlreadyExistsError) {
    return res.status(409).json({ error: { code: error.code } });
  }
  if (error instanceof WeakPasswordError) {
    return res.status(400).json({ error: { code: error.code, violations: error.violations } });
  }
  // Unexpected error → propagate (will be caught by the global middleware)
  throw error;
}

// ❌ Catch-all that hides bugs
try {
  await registration.execute(input);
} catch (error) {
  return res.status(400).json({ error: 'Something went wrong' }); // hides everything
}
```
