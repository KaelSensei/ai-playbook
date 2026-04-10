# Domain Events — TypeScript

## Why Domain Events

Domain events allow the domain to signal that an important fact has occurred without knowing who
will react. This is what decouples the use cases.

```typescript
// Without events: use case coupled to everything
class RegisterUser {
  async execute(input: RegisterInput): Promise<void> {
    await this.userRepo.save(user);
    await this.emailService.sendWelcome(user.email); // direct coupling
    await this.analyticsService.track('user_registered', user.id); // direct coupling
    await this.notificationService.push(user.id, 'Welcome!'); // direct coupling
    // → every new "reactor" requires modifying the use case
  }
}

// With events: use case decoupled
class RegisterUser {
  async execute(input: RegisterInput): Promise<void> {
    const user = User.register(params); // emits UserRegistered in the entity
    await this.userRepo.save(user);
    await this.eventBus.publishAll(user.pullEvents());
    // → reactors subscribe, the use case does not know them
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

  // Pull pattern — events are consumed once
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

  // Helpers for tests
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

// Usage in tests
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

// Registration in the composition root (Express app)
const eventBus = new InMemoryEventBus(); // or RabbitMQ in prod

eventBus.subscribe(UserRegistered, new SendWelcomeEmailOnUserRegistered(emailService));
eventBus.subscribe(UserRegistered, new TrackUserRegistration(analyticsService));
```
