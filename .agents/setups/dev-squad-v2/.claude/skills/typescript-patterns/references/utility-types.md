# TypeScript Utility Types — Production Patterns

## Pick, Omit, Partial — Real Usage

```typescript
// Type de base
type User = {
  id: UserId;
  email: string;
  passwordHash: string;
  role: UserRole;
  createdAt: Date;
  deletedAt: Date | null;
};

// DTO de réponse — exclure les données sensibles
type UserResponse = Omit<User, 'passwordHash' | 'deletedAt'>;
// → { id, email, role, createdAt }

// DTO de création — sans id ni timestamps (générés)
type CreateUserInput = Omit<User, 'id' | 'createdAt' | 'deletedAt'>;
// → { email, passwordHash, role }

// DTO de mise à jour — tout optionnel sauf id
type UpdateUserInput = Partial<Omit<User, 'id' | 'createdAt'>>;
// → { email?, passwordHash?, role?, deletedAt? }

// Sélection précise pour un use case spécifique
type UserCredentials = Pick<User, 'email' | 'passwordHash'>;
// → { email, passwordHash }
```

## Record — Typed Maps

```typescript
// Config de taux de TVA par pays
type VATRates = Record<CountryCode, number>;
const vatRates: VATRates = {
  FR: 0.2,
  DE: 0.19,
  UK: 0.2,
  US: 0,
};

// Mapping erreur domaine → status HTTP
type ErrorStatusMap = Record<string, number>;
const httpStatusByErrorCode: ErrorStatusMap = {
  EMAIL_ALREADY_EXISTS: 409,
  WEAK_PASSWORD: 400,
  USER_NOT_FOUND: 404,
  UNAUTHORIZED: 403,
};

// Permissions par rôle
type PermissionMap = Record<UserRole, string[]>;
const permissions: PermissionMap = {
  [UserRole.ADMIN]: ['users:read', 'users:write', 'users:delete', 'reports:read'],
  [UserRole.MANAGER]: ['users:read', 'reports:read'],
  [UserRole.USER]: ['profile:read', 'profile:write'],
};
```

## Conditional Types

```typescript
// Extraire le type de retour d'une promesse
type Awaited<T> = T extends Promise<infer R> ? R : T;
// Déjà inclus dans TS 4.5+

// Rendre certains champs obligatoires
type RequireFields<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

type UserWithRequiredEmail = RequireFields<User, 'email'>;
// → id?, email (required), passwordHash?, role?, ...

// Type différent selon le contexte
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
// IDs spécifiques pour éviter les confusions
type PrefixedId<Prefix extends string> = `${Prefix}_${string}`
type UserId = PrefixedId<'usr'>    // "usr_abc123"
type OrderId = PrefixedId<'ord'>   // "ord_xyz789"

// Routes API typées
type ApiRoute = `/api/v1/${string}`
function callApi(route: ApiRoute) { ... }
callApi('/api/v1/users')      // ✅
callApi('/api/v2/users')      // ❌ TypeScript error

// Event names typés
type DomainEventName =
  | `${string}Created`
  | `${string}Updated`
  | `${string}Deleted`
  | `${string}Cancelled`

// Toutes les clés d'un objet en event names
type UserEvents = `User${Capitalize<keyof User>}Changed`
// → "UserIdChanged" | "UserEmailChanged" | ...
```

## Mapped Types

```typescript
// Transformer toutes les méthodes en async
type Async<T> = {
  [K in keyof T]: T[K] extends (...args: infer A) => infer R
    ? (...args: A) => Promise<Awaited<R>>
    : T[K];
};

// Readonly profond (récursif)
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object
    ? T[P] extends Function
      ? T[P]
      : DeepReadonly<T[P]>
    : T[P];
};

// Nullable toutes les propriétés
type Nullable<T> = { [K in keyof T]: T[K] | null };

// Rendre optional les propriétés d'un sous-objet
type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;
type CreateOrder = PartialBy<Order, 'id' | 'createdAt' | 'updatedAt'>;
```
