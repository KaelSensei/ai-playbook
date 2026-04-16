---
name: clean-architecture
description: >
  Hexagonal architecture (Ports & Adapters) in TypeScript. Domain, Application, Infrastructure,
  Presentation. Dependency rule, dependency injection, full examples. Loaded by tech-lead,
  dev-senior-a/b.
---

# Clean Architecture — TypeScript

Source: Robert C. Martin, _Clean Architecture_ (2017) + Alistair Cockburn, _Hexagonal Architecture_
(2005)

---

## Folder Structure

```
src/
├── domain/                     # Innermost layer — zero dependencies
│   ├── entities/
│   │   ├── User.ts
│   │   └── User.test.ts        # Tests co-located with the code
│   ├── value-objects/
│   │   ├── Email.ts
│   │   ├── Money.ts
│   │   └── UserId.ts
│   ├── errors/
│   │   ├── DomainError.ts
│   │   ├── EmailAlreadyExistsError.ts
│   │   └── WeakPasswordError.ts
│   └── events/
│       ├── DomainEvent.ts
│       └── UserRegistered.ts
│
├── application/                # Orchestration — depends only on domain
│   ├── use-cases/
│   │   ├── RegisterUser.ts
│   │   ├── RegisterUser.test.ts
│   │   └── DeleteUser.ts
│   └── ports/                  # Interfaces defined by the application
│       ├── UserRepository.ts   # Secondary (outbound) port
│       ├── PasswordHasher.ts
│       ├── EmailService.ts
│       └── EventBus.ts
│
├── infrastructure/             # Adapters — implement the ports
│   ├── persistence/
│   │   ├── PrismaUserRepository.ts
│   │   └── InMemoryUserRepository.ts  # For integration tests
│   ├── security/
│   │   └── BcryptPasswordHasher.ts
│   ├── email/
│   │   └── SendgridEmailService.ts
│   └── events/
│       └── InMemoryEventBus.ts
│
└── presentation/               # Primary adapters — HTTP, CLI, etc.
    ├── http/
    │   ├── controllers/
    │   │   └── UserController.ts
    │   ├── middlewares/
    │   │   └── authMiddleware.ts
    │   └── routes/
    │       └── userRoutes.ts
    └── dto/
        ├── RegisterUserDto.ts
        └── UserResponseDto.ts
```

---

## The Dependency Rule

```
presentation  →  application  →  domain
       ↗                ↗
 infrastructure  ────────────────→

Arrow = "depends on"
domain knows NOTHING about outer layers
application knows ONLY domain
infrastructure implements the ports from application
presentation calls the use cases from application
```

**Practical check:**

```typescript
// ✅ domain/entities/User.ts — no external imports
import { Email } from '../value-objects/Email';
import { UserId } from '../value-objects/UserId';
import { UserRegistered } from '../events/UserRegistered';

// ❌ VIOLATION — domain importing infrastructure
import { PrismaClient } from '@prisma/client'; // FORBIDDEN in domain/
import { Request } from 'express'; // FORBIDDEN in domain/
```

---

## Domain Layer — Full Examples

### Value Object: Email

```typescript
// domain/value-objects/Email.ts
export class Email {
  private readonly _value: string;

  private constructor(value: string) {
    this._value = value.toLowerCase().trim();
  }

  static create(value: string): Email {
    if (!value || value.length === 0) {
      throw new InvalidEmailError('Email cannot be empty');
    }
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(value)) {
      throw new InvalidEmailError(`"${value}" is not a valid email`);
    }
    return new Email(value);
  }

  get value(): string {
    return this._value;
  }

  equals(other: Email): boolean {
    return this._value === other._value;
  }

  toString(): string {
    return this._value;
  }
}

// domain/value-objects/Email.test.ts
describe('Email', () => {
  it('should create valid email');
  it('should normalize to lowercase');
  it('should trim whitespace');
  it('should throw for empty string');
  it('should throw for missing @');
  it('should throw for missing domain');
  it('should consider equal emails with same value');
});
```

### Entity: User

```typescript
// domain/entities/User.ts
export class User {
  private _events: DomainEvent[] = [];

  private constructor(private readonly props: UserProps) {}

  static register(params: { id: UserId; email: Email; hashedPassword: HashedPassword }): User {
    const user = new User({
      ...params,
      role: UserRole.USER,
      createdAt: new Date(),
      emailVerified: false,
      deletedAt: null,
    });

    user._events.push(
      new UserRegistered({
        userId: params.id,
        email: params.email,
        occurredAt: new Date(),
      })
    );

    return user;
  }

  changeEmail(newEmail: Email): void {
    if (this.isDeleted()) {
      throw new DeletedUserError(this.props.id);
    }
    this.props.email = newEmail;
    this._events.push(
      new UserEmailChanged({
        userId: this.props.id,
        oldEmail: this.props.email,
        newEmail,
        occurredAt: new Date(),
      })
    );
  }

  delete(): void {
    if (this.isDeleted()) {
      throw new AlreadyDeletedError(this.props.id);
    }
    this.props.deletedAt = new Date();
  }

  isDeleted(): boolean {
    return this.props.deletedAt !== null;
  }

  get id(): UserId {
    return this.props.id;
  }
  get email(): Email {
    return this.props.email;
  }
  get role(): UserRole {
    return this.props.role;
  }

  pullEvents(): DomainEvent[] {
    const events = [...this._events];
    this._events = [];
    return events;
  }
}
```

---

## Application Layer — Use Cases

```typescript
// application/use-cases/RegisterUser.ts
export class RegisterUser {
  constructor(
    private readonly userRepo: UserRepository, // Port
    private readonly passwordHasher: PasswordHasher, // Port
    private readonly emailService: EmailService, // Port
    private readonly eventBus: EventBus // Port
  ) {}

  async execute(input: RegisterUserInput): Promise<RegisterUserOutput> {
    // 1. Check email uniqueness
    const existing = await this.userRepo.findByEmail(input.email);
    if (existing) {
      throw new EmailAlreadyExistsError(input.email);
    }

    // 2. Validate and create the value objects
    const email = Email.create(input.email);
    const password = Password.create(input.password); // validation in VO

    // 3. Hash the password
    const hashedPassword = await this.passwordHasher.hash(password);

    // 4. Create the entity
    const user = User.register({
      id: UserId.generate(),
      email,
      hashedPassword,
    });

    // 5. Persist
    await this.userRepo.save(user);

    // 6. Publish the events
    const events = user.pullEvents();
    await this.eventBus.publishAll(events);

    // 7. Return the result (without the password hash)
    return {
      id: user.id.value,
      email: user.email.value,
      role: user.role,
    };
  }
}

// application/use-cases/RegisterUser.test.ts
describe('RegisterUser', () => {
  let sut: RegisterUser;
  let userRepo: InMemoryUserRepository;
  let passwordHasher: FakePasswordHasher;
  let emailService: SpyEmailService;
  let eventBus: InMemoryEventBus;

  beforeEach(() => {
    userRepo = new InMemoryUserRepository();
    passwordHasher = new FakePasswordHasher();
    emailService = new SpyEmailService();
    eventBus = new InMemoryEventBus();
    sut = new RegisterUser(userRepo, passwordHasher, emailService, eventBus);
  });

  it('should create user with provided email', async () => {
    const result = await sut.execute({ email: 'user@test.com', password: 'Pass1!xy' });
    expect(result.email).toBe('user@test.com');
  });

  it('should not store plain text password', async () => {
    await sut.execute({ email: 'user@test.com', password: 'Pass1!xy' });
    const user = await userRepo.findByEmail('user@test.com');
    expect(user!.passwordHash).not.toBe('Pass1!xy');
  });

  it('should throw EmailAlreadyExistsError for duplicate', async () => {
    await sut.execute({ email: 'user@test.com', password: 'Pass1!xy' });
    await expect(sut.execute({ email: 'user@test.com', password: 'Pass1!xy' })).rejects.toThrow(
      EmailAlreadyExistsError
    );
  });

  it('should publish UserRegistered event', async () => {
    await sut.execute({ email: 'user@test.com', password: 'Pass1!xy' });
    const events = eventBus.published;
    expect(events).toHaveLength(1);
    expect(events[0]).toBeInstanceOf(UserRegistered);
  });
});
```

---

## Ports — Interfaces

```typescript
// application/ports/UserRepository.ts
export interface UserRepository {
  findById(id: UserId): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<void>;
  delete(id: UserId): Promise<void>;
}

// application/ports/PasswordHasher.ts
export interface PasswordHasher {
  hash(password: Password): Promise<HashedPassword>;
  verify(password: Password, hash: HashedPassword): Promise<boolean>;
}

// application/ports/EmailService.ts
export interface EmailService {
  sendWelcomeEmail(to: Email, name: string): Promise<void>;
  sendPasswordResetEmail(to: Email, token: string): Promise<void>;
}
```

---

## Infrastructure Layer — Adapters

```typescript
// infrastructure/persistence/PrismaUserRepository.ts
export class PrismaUserRepository implements UserRepository {
  constructor(private readonly prisma: PrismaClient) {}

  async findByEmail(email: string): Promise<User | null> {
    const record = await this.prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });
    if (!record) return null;
    return this.toDomain(record);
  }

  async save(user: User): Promise<void> {
    await this.prisma.user.upsert({
      where: { id: user.id.value },
      create: this.toPersistence(user),
      update: this.toPersistence(user),
    });
  }

  private toDomain(record: PrismaUser): User {
    return User.reconstitute({
      // factory method without events
      id: new UserId(record.id),
      email: Email.create(record.email),
      hashedPassword: new HashedPassword(record.passwordHash),
      role: record.role as UserRole,
      createdAt: record.createdAt,
      emailVerified: record.emailVerified,
      deletedAt: record.deletedAt,
    });
  }

  private toPersistence(user: User): PrismaUserInput {
    return {
      id: user.id.value,
      email: user.email.value,
      passwordHash: user.passwordHash.value,
      role: user.role,
      emailVerified: user.emailVerified,
      deletedAt: user.isDeleted() ? new Date() : null,
    };
  }
}

// infrastructure/persistence/InMemoryUserRepository.ts
// Used for tests — behaviour identical to Prisma
export class InMemoryUserRepository implements UserRepository {
  private store: Map<string, User> = new Map();

  async findById(id: UserId): Promise<User | null> {
    return this.store.get(id.value) ?? null;
  }

  async findByEmail(email: string): Promise<User | null> {
    return (
      Array.from(this.store.values()).find((u) => u.email.value === email.toLowerCase()) ?? null
    );
  }

  async save(user: User): Promise<void> {
    this.store.set(user.id.value, user);
  }

  async delete(id: UserId): Promise<void> {
    this.store.delete(id.value);
  }

  // Helpers for assertions
  all(): User[] {
    return Array.from(this.store.values());
  }
  count(): number {
    return this.store.size;
  }
}
```

## Available References

- `references/dependency-injection.md` — DI with tsyringe/inversify/manual
- `references/error-handling.md` — error hierarchy, error boundaries
- `references/domain-events.md` — synchronous and asynchronous events
