---
name: testing-patterns
description: >
  Canon TDD (Kent Beck), patterns de tests unitaires/integration/E2E, mocking, test doubles,
  pyramide de tests. Auto-chargé par dev-senior-a/b, qa-engineer, tech-lead, spec-writer. Invoke
  pour toute question sur TDD, structure de tests, ou stratégie de couverture.
---

# Testing Patterns Reference

## Canon TDD — Le Workflow

Source : Kent Beck (2023) + 3 Laws of TDD (Uncle Bob)

```
1. TEST LIST  — lister tous les comportements à tester (pas de code)
2. RED        — écrire UN test qui échoue pour la bonne raison
3. GREEN      — minimum de code pour faire passer le test
4. BLUE       — refactorer sans casser les tests
5. Répéter    — jusqu'à ce que la test list soit vide
```

### Les 3 erreurs communes

```
❌ Écrire plusieurs tests avant de coder
❌ Refactorer pendant GREEN (deux chapeaux en même temps)
❌ Écrire plus de code que nécessaire pour GREEN
```

### Choisir le prochain test (Starter Test principle)

- Commencer par le cas le plus trivial (retour fixe, input vide)
- Chaque test doit être un pas vers l'objectif
- Si tu es bloqué → tu as fait un trop grand pas → revenir en arrière

## Structure AAA (Arrange / Act / Assert)

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

## Test Doubles (du plus simple au plus complexe)

```typescript
// DUMMY — objet passé mais jamais utilisé
const dummyLogger = {} as Logger;

// STUB — retourne des valeurs prédéfinies
const stubRepo = { findById: async () => ({ id: '1', name: 'Alice' }) };

// FAKE — implémentation simplifiée mais fonctionnelle (préférer les fakes)
class InMemoryUserRepository implements UserRepository {
  private users = new Map<string, User>();
  async save(user: User) {
    this.users.set(user.id, user);
  }
  async findById(id: string) {
    return this.users.get(id) ?? null;
  }
}

// SPY — enregistre les appels
const spy = jest.spyOn(emailService, 'send');
expect(spy).toHaveBeenCalledWith(expect.objectContaining({ to: 'test@test.com' }));

// MOCK — vérifie les interactions (utiliser avec parcimonie)
const mockRepo = { save: jest.fn(), findById: jest.fn() };
```

**Règle** : préférer les Fakes aux Mocks. Les Fakes testent le comportement, les Mocks testent
l'implémentation.

## Pyramide de Tests

```
        /\
       /E2E\       ← peu, lents, flaky, coûteux
      /------\
     /  Integ  \   ← quelques-uns par feature
    /------------\
   /     Unit     \ ← beaucoup, rapides, déterministes
  /________________\
```

### Unit Tests

- Testent une unité isolée (classe, fonction)
- Pas de BDD, pas d'HTTP, pas de filesystem
- Rapides (< 1ms)
- Déterministes toujours

### Integration Tests

```typescript
// Avec vraie BDD (testcontainers ou BDD de test)
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
// HTTP complet avec app en mémoire
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

## Nommage des Tests

```typescript
// Pattern : [unité] [comportement attendu] [condition]
✅ 'should return null when user is not found'
✅ 'should throw InvalidEmailError when email format is wrong'
✅ 'should hash password before saving'

// Anti-patterns
❌ 'test user creation'  // trop vague
❌ 'it works'           // ne décrit rien
❌ 'test 1'             // inutile
```

## Test Data Builders

```typescript
// Builder pattern pour les données de test
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

## Ce qu'il ne faut PAS tester

- Les getters/setters triviaux sans logique
- Les constructeurs qui n'ont pas de logique
- Les dépendances externes (tester son propre code, pas Prisma)
- Les détails d'implémentation (tester le comportement, pas comment)
