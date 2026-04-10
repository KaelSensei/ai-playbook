---
name: typescript-patterns
description: >
  TypeScript patterns for production projects: strict types, typed errors, Result type, Zod
  validation, immutability, advanced generics. Loaded by dev-senior-a/b and tech-lead.
---

# TypeScript Patterns — Production

---

## Strict TypeScript Configuration

```json
// tsconfig.json — required settings
{
  "compilerOptions": {
    "strict": true, // enables all strict checks
    "noUncheckedIndexedAccess": true, // array[0] is T | undefined
    "exactOptionalPropertyTypes": true, // { a?: string } ≠ { a: string | undefined }
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true,
    "resolveJsonModule": true
  }
}
```

---

## Result Type — Errors Without Exceptions

```typescript
// types/Result.ts
export type Result<T, E = Error> = { ok: true; value: T } | { ok: false; error: E };

export const Result = {
  ok: <T>(value: T): Result<T, never> => ({ ok: true, value }),
  err: <E>(error: E): Result<never, E> => ({ ok: false, error }),
};

// Usage — no exceptions for expected business errors
type RegisterError = EmailAlreadyExistsError | WeakPasswordError | InvalidEmailError;

async function registerUser(input: RegisterInput): Promise<Result<User, RegisterError>> {
  const existing = await userRepo.findByEmail(input.email);
  if (existing) {
    return Result.err(new EmailAlreadyExistsError(input.email));
  }

  const passwordResult = Password.validate(input.password);
  if (!passwordResult.ok) {
    return Result.err(passwordResult.error);
  }

  const user = await createUser(input);
  return Result.ok(user);
}

// Consumption in the controller
const result = await registerUser(input);
if (!result.ok) {
  switch (result.error.constructor) {
    case EmailAlreadyExistsError:
      return res.status(409).json({ error: 'EMAIL_TAKEN' });
    case WeakPasswordError:
      return res.status(400).json({ error: 'WEAK_PASSWORD', hint: result.error.hint });
    default:
      return res.status(400).json({ error: 'VALIDATION_ERROR' });
  }
}
return res.status(201).json(toUserDto(result.value));
```

---

## Branded Types — Avoid Primitive Obsession

```typescript
// Branded types for IDs — avoids confusion between types
declare const __brand: unique symbol
type Brand<T, B> = T & { [__brand]: B }

type UserId = Brand<string, 'UserId'>
type OrderId = Brand<string, 'OrderId'>
type Email = Brand<string, 'Email'>

// Factories with validation
const UserId = {
  create: (id: string): UserId => {
    if (!id.match(/^[0-9a-f-]{36}$/)) throw new Error('Invalid UUID')
    return id as UserId
  },
  generate: (): UserId => crypto.randomUUID() as UserId,
}

// TypeScript prevents confusion
function getUser(id: UserId): Promise<User> { ... }
function getOrder(id: OrderId): Promise<Order> { ... }

const userId = UserId.generate()
const orderId = OrderId.generate()

getUser(userId)   // ✅
getUser(orderId)  // ❌ TypeScript error: OrderId ≠ UserId
```

---

## Validation with Zod

```typescript
import { z } from 'zod';

// Validation schema — source of truth for the type
const RegisterUserSchema = z.object({
  email: z
    .string()
    .email('Invalid email format')
    .max(255, 'Email too long')
    .transform((s) => s.toLowerCase().trim()),

  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .max(100, 'Password too long')
    .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
    .regex(/[0-9]/, 'Password must contain at least one number')
    .regex(/[^A-Za-z0-9]/, 'Password must contain at least one special character'),

  name: z.string().min(1, 'Name is required').max(100, 'Name too long').trim(),
});

// Type inferred from the schema
type RegisterUserInput = z.infer<typeof RegisterUserSchema>;

// Express validation middleware
const validateBody =
  <T>(schema: z.ZodType<T>) =>
  (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({
        error: 'VALIDATION_ERROR',
        details: result.error.errors.map((e) => ({
          field: e.path.join('.'),
          message: e.message,
        })),
      });
    }
    req.body = result.data; // transformed and validated data
    next();
  };

// Usage
router.post('/users', validateBody(RegisterUserSchema), userController.register);
```

---

## Immutability

```typescript
// Use readonly everywhere in the domain
type UserProps = Readonly<{
  id: UserId;
  email: Email;
  role: UserRole;
  createdAt: Date;
}>;

// Recursive readonly for nested objects
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

// For arrays — use ReadonlyArray
type OrderItems = ReadonlyArray<CartItem>;

// Immutable update with spread
const updatedUser = { ...user, email: newEmail }; // creates a new object

// Or with immer for complex structures
import produce from 'immer';

const newState = produce(state, (draft) => {
  draft.users[userId].email = newEmail; // mutation on the draft
});
```

---

## Discriminated Unions — State Modeling

```typescript
// Model an order's states with discriminated unions
type Order =
  | { status: 'draft'; items: CartItem[]; userId: UserId }
  | { status: 'confirmed'; items: CartItem[]; userId: UserId; confirmedAt: Date; total: Money }
  | {
      status: 'shipped';
      items: CartItem[];
      userId: UserId;
      confirmedAt: Date;
      total: Money;
      trackingId: string;
    }
  | {
      status: 'delivered';
      items: CartItem[];
      userId: UserId;
      confirmedAt: Date;
      total: Money;
      trackingId: string;
      deliveredAt: Date;
    }
  | { status: 'cancelled'; items: CartItem[]; userId: UserId; cancelledAt: Date; reason: string };

// TypeScript forces handling of all cases
function renderOrderStatus(order: Order): string {
  switch (order.status) {
    case 'draft':
      return `Draft (${order.items.length} items)`;
    case 'confirmed':
      return `Confirmed — Total: ${order.total}`;
    case 'shipped':
      return `Shipped — Tracking: ${order.trackingId}`;
    case 'delivered':
      return `Delivered on ${order.deliveredAt.toLocaleDateString()}`;
    case 'cancelled':
      return `Cancelled — ${order.reason}`;
    // TypeScript error if a case is missing (exhaustive check)
  }
}

// Typed state transitions
function confirmOrder(
  order: Extract<Order, { status: 'draft' }>
): Extract<Order, { status: 'confirmed' }> {
  return {
    ...order,
    status: 'confirmed',
    confirmedAt: new Date(),
    total: calculateTotal(order.items),
  };
}
```

---

## Advanced Generics

```typescript
// Typed generic repository
interface Repository<T, ID> {
  findById(id: ID): Promise<T | null>
  findAll(): Promise<T[]>
  save(entity: T): Promise<void>
  delete(id: ID): Promise<void>
}

// Generic use case with validation
abstract class UseCase<Input, Output> {
  abstract execute(input: Input): Promise<Output>

  async run(input: unknown): Promise<Output> {
    const validated = this.validate(input)
    return this.execute(validated)
  }

  protected abstract validate(input: unknown): Input
}

// Typed pagination
type PaginatedResult<T> = {
  data: T[]
  total: number
  page: number
  pageSize: number
  hasNextPage: boolean
  hasPrevPage: boolean
}

async function findUsers(
  filter: UserFilter,
  pagination: { page: number; pageSize: number }
): Promise<PaginatedResult<User>> { ... }
```

---

## Available References

- `references/error-types.md` — domain/application error hierarchy
- `references/utility-types.md` — Pick, Omit, Partial, Record patterns
- `references/decorators.md` — decorators for validation and DI
