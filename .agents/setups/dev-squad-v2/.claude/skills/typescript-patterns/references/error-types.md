# Error Types Hierarchy — TypeScript

## Structure de Base

```typescript
// Base error — toutes les erreurs du domaine héritent de ça
export abstract class DomainError extends Error {
  abstract readonly code: string;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    // Fix stack trace en TypeScript
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

// Base error pour les erreurs d'application (use cases)
export abstract class ApplicationError extends Error {
  abstract readonly code: string;
  abstract readonly httpStatus: number;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
  }
}
```

## Erreurs Domaine (domain/errors/)

```typescript
// Erreur de validation — input invalide
export class InvalidEmailError extends DomainError {
  readonly code = 'INVALID_EMAIL';

  constructor(email: string) {
    super(`"${email}" is not a valid email address`);
  }
}

// Erreur métier — règle de gestion violée
export class InsufficientStockError extends DomainError {
  readonly code = 'INSUFFICIENT_STOCK';

  constructor(
    readonly productId: string,
    readonly requested: number,
    readonly available: number
  ) {
    super(`Cannot reserve ${requested} units of product ${productId}: only ${available} available`);
  }
}

// Erreur d'état — transition d'état invalide
export class AlreadyCancelledError extends DomainError {
  readonly code = 'ALREADY_CANCELLED';

  constructor(readonly bookingId: string) {
    super(`Booking ${bookingId} is already cancelled`);
  }
}
```

## Erreurs Application (application/errors/)

```typescript
// Erreur "not found" — ressource inexistante
export class BookingNotFoundError extends ApplicationError {
  readonly code = 'BOOKING_NOT_FOUND';
  readonly httpStatus = 404;

  constructor(readonly bookingId: string) {
    super(`Booking with id "${bookingId}" not found`);
  }
}

// Erreur "conflict" — contrainte d'unicité
export class EmailAlreadyExistsError extends ApplicationError {
  readonly code = 'EMAIL_ALREADY_EXISTS';
  readonly httpStatus = 409;

  constructor(readonly email: string) {
    super(`An account with email "${email}" already exists`);
  }
}

// Erreur "unauthorized"
export class UnauthorizedError extends ApplicationError {
  readonly code = 'UNAUTHORIZED';
  readonly httpStatus = 403;

  constructor(action: string) {
    super(`You are not authorized to ${action}`);
  }
}
```

## Mapping HTTP dans le Controller

```typescript
// presentation/http/errorHandler.ts
export function toHttpError(error: unknown): { status: number; body: object } {
  if (error instanceof ApplicationError) {
    return {
      status: error.httpStatus,
      body: { error: { code: error.code, message: error.message } },
    }
  }

  if (error instanceof DomainError) {
    return {
      status: 422,
      body: { error: { code: error.code, message: error.message } },
    }
  }

  // Erreur inattendue — ne pas exposer les détails en prod
  console.error('Unexpected error:', error)
  return {
    status: 500,
    body: { error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' } },
  }
}

// Dans le controller
async register(req: Request, res: Response) {
  try {
    const result = await this.registerUser.execute(req.body)
    res.status(201).json({ data: result })
  } catch (error) {
    const { status, body } = toHttpError(error)
    res.status(status).json(body)
  }
}
```
