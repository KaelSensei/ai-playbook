# Dependency Injection — TypeScript

## Injection Manuelle (sans framework)

```typescript
// Composition Root — src/app.ts ou src/infrastructure/container.ts
// C'est le seul endroit où on instancie les vraies dépendances

import { PrismaClient } from '@prisma/client';
import { BcryptPasswordHasher } from './security/BcryptPasswordHasher';
import { SendgridEmailService } from './email/SendgridEmailService';
import { PrismaUserRepository } from './persistence/PrismaUserRepository';
import { InMemoryEventBus } from './events/InMemoryEventBus';
import { RegisterUser } from '../application/use-cases/RegisterUser';
import { UserController } from '../presentation/http/controllers/UserController';

const prisma = new PrismaClient();
const userRepo = new PrismaUserRepository(prisma);
const passwordHasher = new BcryptPasswordHasher(12);
const emailService = new SendgridEmailService(process.env.SENDGRID_API_KEY!);
const eventBus = new InMemoryEventBus();

// Use cases
const registerUser = new RegisterUser(userRepo, passwordHasher, emailService, eventBus);

// Controllers
export const userController = new UserController(registerUser);
```

## Dans les Tests — Injection de Fakes

```typescript
// test/setup.ts — utilitaires partagés
export function createTestDependencies() {
  const userRepo = new InMemoryUserRepository();
  const passwordHasher = new FakePasswordHasher();
  const emailService = new SpyEmailService();
  const eventBus = new InMemoryEventBus();

  return { userRepo, passwordHasher, emailService, eventBus };
}

// RegisterUser.test.ts
describe('RegisterUser', () => {
  let sut: RegisterUser;
  let deps: ReturnType<typeof createTestDependencies>;

  beforeEach(() => {
    deps = createTestDependencies();
    sut = new RegisterUser(deps.userRepo, deps.passwordHasher, deps.emailService, deps.eventBus);
  });

  it('should register user with valid credentials', async () => {
    const result = await sut.execute({ email: 'a@b.com', password: 'Pass1!' });
    expect(result.email).toBe('a@b.com');
  });
});
```

## FakePasswordHasher — Exemple de Fake Simple

```typescript
export class FakePasswordHasher implements PasswordHasher {
  // Préfixe reconnaissable pour vérifier dans les tests
  async hash(password: Password): Promise<HashedPassword> {
    return new HashedPassword(`hashed:${password.value}`);
  }

  async verify(password: Password, hash: HashedPassword): Promise<boolean> {
    return hash.value === `hashed:${password.value}`;
  }
}

// Dans un test :
it('should not store plain text password', async () => {
  await sut.execute({ email: 'a@b.com', password: 'Pass1!' });
  const user = await deps.userRepo.findByEmail('a@b.com');
  expect(user!.passwordHash.value).toBe('hashed:Pass1!');
  expect(user!.passwordHash.value).not.toBe('Pass1!');
});
```
