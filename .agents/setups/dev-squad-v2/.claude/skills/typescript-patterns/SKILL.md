---
name: typescript-patterns
description: >
  Patterns TypeScript pour projets production : types strict, erreurs typées, Result type,
  validation Zod, immutabilité, génériques avancés. Loaded by dev-senior-a/b et tech-lead.
---

# TypeScript Patterns — Production

---

## Strict TypeScript Configuration

```json
// tsconfig.json — settings obligatoires
{
  "compilerOptions": {
    "strict": true, // active tous les checks stricts
    "noUncheckedIndexedAccess": true, // array[0] est T | undefined
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

// Usage — pas d'exceptions pour les erreurs métier attendues
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

// Consommation dans le controller
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
// Branded types pour les IDs — évite les confusions entre types
declare const __brand: unique symbol
type Brand<T, B> = T & { [__brand]: B }

type UserId = Brand<string, 'UserId'>
type OrderId = Brand<string, 'OrderId'>
type Email = Brand<string, 'Email'>

// Factories avec validation
const UserId = {
  create: (id: string): UserId => {
    if (!id.match(/^[0-9a-f-]{36}$/)) throw new Error('Invalid UUID')
    return id as UserId
  },
  generate: (): UserId => crypto.randomUUID() as UserId,
}

// TypeScript empêche les confusions
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

// Schéma de validation — source de vérité pour le type
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

// Type inféré depuis le schéma
type RegisterUserInput = z.infer<typeof RegisterUserSchema>;

// Middleware de validation Express
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
    req.body = result.data; // données transformées et validées
    next();
  };

// Usage
router.post('/users', validateBody(RegisterUserSchema), userController.register);
```

---

## Immutability

```typescript
// Utiliser readonly partout dans le domain
type UserProps = Readonly<{
  id: UserId;
  email: Email;
  role: UserRole;
  createdAt: Date;
}>;

// Readonly récursif pour les objets imbriqués
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

// Pour les tableaux — utiliser ReadonlyArray
type OrderItems = ReadonlyArray<CartItem>;

// Mise à jour immutable avec spread
const updatedUser = { ...user, email: newEmail }; // crée un nouvel objet

// Ou avec immer pour les structures complexes
import produce from 'immer';

const newState = produce(state, (draft) => {
  draft.users[userId].email = newEmail; // mutation sur le draft
});
```

---

## Discriminated Unions — State Modeling

```typescript
// Modéliser les états d'une commande avec des unions discriminées
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

// TypeScript force à gérer tous les cas
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
    // TypeScript error si un cas manque (exhaustive check)
  }
}

// Transitions d'état typées
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
// Repository générique typé
interface Repository<T, ID> {
  findById(id: ID): Promise<T | null>
  findAll(): Promise<T[]>
  save(entity: T): Promise<void>
  delete(id: ID): Promise<void>
}

// Use case générique avec validation
abstract class UseCase<Input, Output> {
  abstract execute(input: Input): Promise<Output>

  async run(input: unknown): Promise<Output> {
    const validated = this.validate(input)
    return this.execute(validated)
  }

  protected abstract validate(input: unknown): Input
}

// Pagination typée
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

- `references/error-types.md` — hiérarchie d'erreurs domaine/application
- `references/utility-types.md` — Pick, Omit, Partial, Record patterns
- `references/decorators.md` — decorators pour validation et DI
