# Async Testing TypeScript

## Async/Await — Basics

```typescript
// Toujours retourner/await les promesses dans les tests
it('should save user asynchronously', async () => {
  const result = await userService.create(validInput);
  expect(result.id).toBeDefined();
});

// ❌ Oublier await — le test passe toujours (faux positif!)
it('dangerous test without await', () => {
  userService.create(validInput); // promesse non attendue
  // le test passe même si create() throw
});
```

## Testing Async Errors

```typescript
// ✅ Avec rejects.toThrow
it('should throw for duplicate email', async () => {
  await repo.save(aUser({ email: new Email('taken@test.com') }));

  await expect(userService.create({ email: 'taken@test.com', password: 'Pass1!' })).rejects.toThrow(
    EmailAlreadyExistsError
  );
});

// ✅ Avec try/catch pour vérifier les détails de l'erreur
it('should include conflicting email in error', async () => {
  await repo.save(aUser({ email: new Email('taken@test.com') }));

  try {
    await userService.create({ email: 'taken@test.com', password: 'Pass1!' });
    fail('Should have thrown');
  } catch (error) {
    expect(error).toBeInstanceOf(EmailAlreadyExistsError);
    expect((error as EmailAlreadyExistsError).email).toBe('taken@test.com');
  }
});
```

## Timers and Delays

```typescript
// Utiliser jest fake timers pour les timeouts
describe('TokenExpiry', () => {
  beforeEach(() => jest.useFakeTimers());
  afterEach(() => jest.useRealTimers());

  it('should expire token after 15 minutes', async () => {
    const token = await tokenService.generate(userId);

    jest.advanceTimersByTime(15 * 60 * 1000 + 1); // 15min + 1ms

    await expect(tokenService.validate(token)).rejects.toThrow(TokenExpiredError);
  });

  it('should be valid within 15 minutes', async () => {
    const token = await tokenService.generate(userId);

    jest.advanceTimersByTime(14 * 60 * 1000); // 14 minutes

    await expect(tokenService.validate(token)).resolves.toBeTruthy();
  });
});
```

## Events and Observables

```typescript
// Tester les domain events émis
it('should emit UserRegistered event after creation', async () => {
  const events: DomainEvent[] = [];
  eventBus.subscribe(UserRegistered, (e) => events.push(e));

  await userService.create({ email: 'new@test.com', password: 'Pass1!' });

  expect(events).toHaveLength(1);
  expect(events[0]).toBeInstanceOf(UserRegistered);
  expect((events[0] as UserRegistered).email).toBe('new@test.com');
});

// Tester les streams/observables avec Vitest
it('should stream progress updates', async () => {
  const updates: ProgressUpdate[] = [];

  for await (const update of importService.import(largeFile)) {
    updates.push(update);
  }

  expect(updates.at(-1)?.percentage).toBe(100);
  expect(updates.every((u) => u.percentage >= 0 && u.percentage <= 100)).toBe(true);
});
```

## Concurrency and Race Conditions

```typescript
// Tester que l'idempotence est respectée
it('should not create duplicate on concurrent requests', async () => {
  const input = { email: 'concurrent@test.com', password: 'Pass1!' };

  // Simuler deux requêtes simultanées
  const [result1, result2] = await Promise.allSettled([
    userService.create(input),
    userService.create(input),
  ]);

  const successes = [result1, result2].filter((r) => r.status === 'fulfilled');
  const failures = [result1, result2].filter((r) => r.status === 'rejected');

  expect(successes).toHaveLength(1); // une seule création
  expect(failures).toHaveLength(1);
  expect((failures[0] as PromiseRejectedResult).reason).toBeInstanceOf(EmailAlreadyExistsError);
});
```
