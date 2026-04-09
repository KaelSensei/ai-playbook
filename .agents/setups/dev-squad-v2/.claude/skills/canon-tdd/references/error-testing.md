# Testing Errors in TypeScript

## Typed Errors — Hierarchy

```typescript
// Erreurs de base — à mettre dans domain/errors/
export abstract class DomainError extends Error {
  abstract readonly code: string;
  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    // Fix prototype chain pour instanceof
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
// Méthode 1 : rejects.toThrow (simple)
it('should throw EmailAlreadyExistsError for duplicate email', async () => {
  await repo.save(aUser({ email: 'taken@test.com' }));

  await expect(
    registration.execute({ email: 'taken@test.com', password: 'Pass1!xy' })
  ).rejects.toThrow(EmailAlreadyExistsError);
});

// Méthode 2 : rejects.toMatchObject (vérifier les propriétés)
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

// Méthode 3 : catch explicite (vérifications détaillées)
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
// Pour les Value Objects — validation dans le constructeur
it('should throw for invalid email format', () => {
  expect(() => Email.create('not-an-email')).toThrow(InvalidEmailError);
});

it('should throw for empty email', () => {
  expect(() => Email.create(''))
    .toThrow(new InvalidEmailError('Email cannot be empty'))
    // OU
    .toThrow('Email cannot be empty');
});

// Vérifier qu'une erreur N'est PAS levée
it('should not throw for valid email', () => {
  expect(() => Email.create('valid@test.com')).not.toThrow();
});
```

## Testing Error Mapping Domaine → HTTP

```typescript
// Dans les tests d'intégration du controller
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
    // Ne pas exposer l'adresse email dans le message d'erreur public
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

## Unexpected Errors — Ne Pas Masquer

```typescript
// ✅ Gérer les erreurs métier connues, laisser passer les autres
try {
  await registration.execute(input);
} catch (error) {
  if (error instanceof EmailAlreadyExistsError) {
    return res.status(409).json({ error: { code: error.code } });
  }
  if (error instanceof WeakPasswordError) {
    return res.status(400).json({ error: { code: error.code, violations: error.violations } });
  }
  // Erreur inattendue → propager (sera catchée par le middleware global)
  throw error;
}

// ❌ Catch-all qui cache les bugs
try {
  await registration.execute(input);
} catch (error) {
  return res.status(400).json({ error: 'Something went wrong' }); // masque tout
}
```
