# TypeScript Utility Types — Production Patterns

## Pick, Omit, Partial — Real Usage

```typescript
// Base type
type User = {
  id: UserId;
  email: string;
  passwordHash: string;
  role: UserRole;
  createdAt: Date;
  deletedAt: Date | null;
};

// Response DTO — exclude sensitive data
type UserResponse = Omit<User, 'passwordHash' | 'deletedAt'>;
// → { id, email, role, createdAt }

// Creation DTO — without id or timestamps (generated)
type CreateUserInput = Omit<User, 'id' | 'createdAt' | 'deletedAt'>;
// → { email, passwordHash, role }

// Update DTO — everything optional except id
type UpdateUserInput = Partial<Omit<User, 'id' | 'createdAt'>>;
// → { email?, passwordHash?, role?, deletedAt? }

// Precise selection for a specific use case
type UserCredentials = Pick<User, 'email' | 'passwordHash'>;
// → { email, passwordHash }
```

## Record — Typed Maps

```typescript
// VAT rate config by country
type VATRates = Record<CountryCode, number>;
const vatRates: VATRates = {
  FR: 0.2,
  DE: 0.19,
  UK: 0.2,
  US: 0,
};

// Domain error → HTTP status mapping
type ErrorStatusMap = Record<string, number>;
const httpStatusByErrorCode: ErrorStatusMap = {
  EMAIL_ALREADY_EXISTS: 409,
  WEAK_PASSWORD: 400,
  USER_NOT_FOUND: 404,
  UNAUTHORIZED: 403,
};

// Permissions by role
type PermissionMap = Record<UserRole, string[]>;
const permissions: PermissionMap = {
  [UserRole.ADMIN]: ['users:read', 'users:write', 'users:delete', 'reports:read'],
  [UserRole.MANAGER]: ['users:read', 'reports:read'],
  [UserRole.USER]: ['profile:read', 'profile:write'],
};
```

## Conditional Types

```typescript
// Extract the return type of a promise
type Awaited<T> = T extends Promise<infer R> ? R : T;
// Already built-in since TS 4.5+

// Make certain fields required
type RequireFields<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

type UserWithRequiredEmail = RequireFields<User, 'email'>;
// → id?, email (required), passwordHash?, role?, ...

// Different type depending on context
type ApiResponse<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: { code: string; message: string } };

async function getUser(id: string): Promise<ApiResponse<UserResponse>> {
  try {
    const user = await userRepo.findById(id);
    if (!user) return { status: 'error', error: { code: 'NOT_FOUND', message: 'User not found' } };
    return { status: 'success', data: toUserResponse(user) };
  } catch {
    return { status: 'error', error: { code: 'INTERNAL_ERROR', message: 'Unexpected error' } };
  }
}
```

## Template Literal Types

```typescript
// Specific IDs to avoid confusion
type PrefixedId<Prefix extends string> = `${Prefix}_${string}`
type UserId = PrefixedId<'usr'>    // "usr_abc123"
type OrderId = PrefixedId<'ord'>   // "ord_xyz789"

// Typed API routes
type ApiRoute = `/api/v1/${string}`
function callApi(route: ApiRoute) { ... }
callApi('/api/v1/users')      // ✅
callApi('/api/v2/users')      // ❌ TypeScript error

// Typed event names
type DomainEventName =
  | `${string}Created`
  | `${string}Updated`
  | `${string}Deleted`
  | `${string}Cancelled`

// All the keys of an object as event names
type UserEvents = `User${Capitalize<keyof User>}Changed`
// → "UserIdChanged" | "UserEmailChanged" | ...
```

## Mapped Types

```typescript
// Transform every method into async
type Async<T> = {
  [K in keyof T]: T[K] extends (...args: infer A) => infer R
    ? (...args: A) => Promise<Awaited<R>>
    : T[K];
};

// Deep readonly (recursive)
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object
    ? T[P] extends Function
      ? T[P]
      : DeepReadonly<T[P]>
    : T[P];
};

// Make every property nullable
type Nullable<T> = { [K in keyof T]: T[K] | null };

// Make selected properties optional
type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
type CreateOrder = PartialBy<Order, 'id' | 'createdAt' | 'updatedAt'>;
```
