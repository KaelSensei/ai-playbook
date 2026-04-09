# Domain Events — TypeScript

## Why les Domain Events

Les domain events permettent au domaine de signaler qu'un fait important s'est produit, sans savoir
qui va réagir. C'est ce qui découple les use cases.

```typescript
// Sans events : use case couplé à tout
class RegisterUser {
  async execute(input: RegisterInput): Promise<void> {
    await this.userRepo.save(user);
    await this.emailService.sendWelcome(user.email); // couplage direct
    await this.analyticsService.track('user_registered', user.id); // couplage direct
    await this.notificationService.push(user.id, 'Welcome!'); // couplage direct
    // → chaque nouveau "réacteur" nécessite de modifier le use case
  }
}

// Avec events : use case découplé
class RegisterUser {
  async execute(input: RegisterInput): Promise<void> {
    const user = User.register(params); // émet UserRegistered dans l'entité
    await this.userRepo.save(user);
    await this.eventBus.publishAll(user.pullEvents());
    // → les réacteurs s'abonnent, le use case ne les connaît pas
  }
}
```

## Defining Domain Events

```typescript
// domain/events/DomainEvent.ts
export abstract class DomainEvent {
  readonly occurredAt: Date;
  readonly eventId: string;

  constructor() {
    this.occurredAt = new Date();
    this.eventId = crypto.randomUUID();
  }
}

// domain/events/UserRegistered.ts
export class UserRegistered extends DomainEvent {
  constructor(
    readonly userId: UserId,
    readonly email: Email,
    readonly registeredAt: Date
  ) {
    super();
  }
}

// domain/events/BookingCancelled.ts
export class BookingCancelled extends DomainEvent {
  constructor(
    readonly bookingId: BookingId,
    readonly cancelledBy: UserId,
    readonly refundAmount: Money,
    readonly reason: string
  ) {
    super();
  }
}
```

## Emitting from Entities

```typescript
// domain/entities/User.ts
export class User {
  private _events: DomainEvent[] = [];

  static register(params: RegisterUserParams): User {
    const user = new User(params);
    user._events.push(new UserRegistered(params.id, params.email, new Date()));
    return user;
  }

  verifyEmail(): void {
    if (this._emailVerified) throw new AlreadyVerifiedError(this._id);
    this._emailVerified = true;
    this._events.push(new EmailVerified(this._id, new Date()));
  }

  // Pull pattern — les events sont consommés une seule fois
  pullEvents(): DomainEvent[] {
    const events = [...this._events];
    this._events = [];
    return events;
  }
}
```

## EventBus Port

```typescript
// application/ports/EventBus.ts
export interface EventBus {
  publish(event: DomainEvent): Promise<void>;
  publishAll(events: DomainEvent[]): Promise<void>;
}

// application/ports/EventHandler.ts
export interface EventHandler<T extends DomainEvent> {
  handle(event: T): Promise<void>;
}
```

## InMemoryEventBus for Tests

```typescript
// infrastructure/events/InMemoryEventBus.ts
export class InMemoryEventBus implements EventBus {
  private _published: DomainEvent[] = [];
  private _handlers: Map<string, EventHandler<DomainEvent>[]> = new Map();

  async publish(event: DomainEvent): Promise<void> {
    this._published.push(event);
    const handlers = this._handlers.get(event.constructor.name) ?? [];
    await Promise.all(handlers.map((h) => h.handle(event)));
  }

  async publishAll(events: DomainEvent[]): Promise<void> {
    await Promise.all(events.map((e) => this.publish(e)));
  }

  subscribe<T extends DomainEvent>(
    eventClass: new (...args: unknown[]) => T,
    handler: EventHandler<T>
  ): void {
    const key = eventClass.name;
    const existing = this._handlers.get(key) ?? [];
    this._handlers.set(key, [...existing, handler as EventHandler<DomainEvent>]);
  }

  // Helpers pour les tests
  get published(): DomainEvent[] {
    return [...this._published];
  }

  published_of<T extends DomainEvent>(eventClass: new (...args: unknown[]) => T): T[] {
    return this._published.filter((e) => e instanceof eventClass) as T[];
  }

  clear(): void {
    this._published = [];
  }
}

// Usage dans les tests
it('should publish UserRegistered event', async () => {
  const eventBus = new InMemoryEventBus();
  const sut = new RegisterUser(repo, hasher, emailer, eventBus);

  await sut.execute({ email: 'user@test.com', password: 'Pass1!xy' });

  const events = eventBus.published_of(UserRegistered);
  expect(events).toHaveLength(1);
  expect(events[0].email.value).toBe('user@test.com');
});
```

## Event Handlers

```typescript
// application/event-handlers/SendWelcomeEmailOnUserRegistered.ts
export class SendWelcomeEmailOnUserRegistered implements EventHandler<UserRegistered> {
  constructor(private readonly emailService: EmailService) {}

  async handle(event: UserRegistered): Promise<void> {
    await this.emailService.sendWelcomeEmail(event.email);
  }
}

// Enregistrement dans la composition root (Express app)
const eventBus = new InMemoryEventBus(); // ou RabbitMQ en prod

eventBus.subscribe(UserRegistered, new SendWelcomeEmailOnUserRegistered(emailService));
eventBus.subscribe(UserRegistered, new TrackUserRegistration(analyticsService));
```
