# Error Types Hierarchy — TypeScript

## Base Structure

```typescript
// Base error — all domain errors inherit from this
export abstract class DomainError extends Error {
  abstract readonly code: string;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    // Fix stack trace in TypeScript
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

// Base error for application errors (use cases)
export abstract class ApplicationError extends Error {
  abstract readonly code: string;
  abstract readonly httpStatus: number;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
  }
}
```

## Domain Errors (domain/errors/)

```typescript
// Validation error — invalid input
export class InvalidEmailError extends DomainError {
  readonly code = 'INVALID_EMAIL';

  constructor(email: string) {
    super(`"${email}" is not a valid email address`);
  }
}

// Business error — business rule violated
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

// State error — invalid state transition
export class AlreadyCancelledError extends DomainError {
  readonly code = 'ALREADY_CANCELLED';

  constructor(readonly bookingId: string) {
    super(`Booking ${bookingId} is already cancelled`);
  }
}
```

## Application Errors (application/errors/)

```typescript
// "Not found" error — missing resource
export class BookingNotFoundError extends ApplicationError {
  readonly code = 'BOOKING_NOT_FOUND';
  readonly httpStatus = 404;

  constructor(readonly bookingId: string) {
    super(`Booking with id "${bookingId}" not found`);
  }
}

// "Conflict" error — uniqueness constraint
export class EmailAlreadyExistsError extends ApplicationError {
  readonly code = 'EMAIL_ALREADY_EXISTS';
  readonly httpStatus = 409;

  constructor(readonly email: string) {
    super(`An account with email "${email}" already exists`);
  }
}

// "Unauthorized" error
export class UnauthorizedError extends ApplicationError {
  readonly code = 'UNAUTHORIZED';
  readonly httpStatus = 403;

  constructor(action: string) {
    super(`You are not authorized to ${action}`);
  }
}
```

## HTTP Mapping in the Controller

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

  // Unexpected error — do not expose details in production
  console.error('Unexpected error:', error)
  return {
    status: 500,
    body: { error: { code: 'INTERNAL_ERROR', message: 'An unexpected error occurred' } },
  }
}

// In the controller
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
