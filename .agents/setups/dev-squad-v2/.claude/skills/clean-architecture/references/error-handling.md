# Error Handling — Clean Architecture TypeScript

## Error Hierarchy

```typescript
// domain/errors/base.ts
export abstract class DomainError extends Error {
  abstract readonly code: string;
  abstract readonly httpStatus: number;

  constructor(message: string) {
    super(message);
    this.name = this.constructor.name;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

export abstract class NotFoundError extends DomainError {
  readonly httpStatus = 404;
}

export abstract class ConflictError extends DomainError {
  readonly httpStatus = 409;
}

export abstract class ValidationError extends DomainError {
  readonly httpStatus = 400;
}

export abstract class AuthorizationError extends DomainError {
  readonly httpStatus = 403;
}

// domain/errors/user.ts
export class UserNotFoundError extends NotFoundError {
  readonly code = 'USER_NOT_FOUND';
  constructor(readonly userId: string) {
    super(`User "${userId}" not found`);
  }
}

export class EmailAlreadyExistsError extends ConflictError {
  readonly code = 'EMAIL_ALREADY_EXISTS';
  constructor(readonly email: string) {
    super(`Email "${email}" is already registered`);
  }
}

export class WeakPasswordError extends ValidationError {
  readonly code = 'WEAK_PASSWORD';
  constructor(readonly violations: string[]) {
    super(`Password requirements not met: ${violations.join('; ')}`);
  }
}

export class InsufficientPermissionsError extends AuthorizationError {
  readonly code = 'INSUFFICIENT_PERMISSIONS';
  constructor(
    readonly userId: string,
    readonly action: string
  ) {
    super(`User "${userId}" is not allowed to perform "${action}"`);
  }
}
```

## Domain Error Mapping → HTTP dans le Controller

```typescript
// presentation/http/errorMapper.ts

// Générique — pour tous les controllers
export const mapDomainErrorToHttp = (error: unknown, res: Response, req: Request): boolean => {
  if (!(error instanceof DomainError)) return false;

  // Les DomainErrors portent leur httpStatus — pas besoin de switch
  const body: ApiError = {
    error: {
      code: error.code,
      // Message public générique pour les 403/401 (ne pas divulguer)
      message: error.httpStatus >= 403 ? getPublicMessage(error.code) : error.message,
      requestId: req.headers['x-request-id'] as string,
    },
  };

  // Ajouter les détails structurés si disponibles
  if (error instanceof WeakPasswordError) {
    body.error.details = error.violations.map((v) => ({ field: 'password', message: v }));
  }

  res.status(error.httpStatus).json(body);
  return true;
};

const publicMessages: Record<string, string> = {
  INSUFFICIENT_PERMISSIONS: 'Access denied',
  USER_NOT_FOUND: 'Resource not found',
  EMAIL_ALREADY_EXISTS: 'This email is already taken',
};

const getPublicMessage = (code: string): string => publicMessages[code] ?? 'Request failed';

// Usage dans un controller
const handleError = (error: unknown, req: Request, res: Response, next: NextFunction): void => {
  if (mapDomainErrorToHttp(error, res, req)) return;
  next(error); // erreur non-domaine → middleware global
};

// Dans chaque controller
findById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await this.getUser.execute({ id: req.params.id });
    respond.ok(res, toUserDto(user));
  } catch (error) {
    handleError(error, req, res, next);
  }
};
```

## Application Error Boundary — Middleware Global

```typescript
// middlewares/globalErrorHandler.ts
export const globalErrorHandler: ErrorRequestHandler = (error, req, res, _next) => {
  // DomainErrors devraient déjà être gérées dans les controllers
  // Ici on reçoit les erreurs inattendues
  const requestId = req.headers['x-request-id'] as string;

  logger.error('Unhandled application error', {
    error: {
      name: error.name,
      message: error.message,
      stack: error.stack,
    },
    request: {
      id: requestId,
      method: req.method,
      path: req.path,
      userId: (req as AuthenticatedRequest).user?.id,
    },
  });

  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred. Please try again.',
      requestId,
    },
  });
};

// Dans app.ts — toujours en dernier
app.use(globalErrorHandler);
```

## Errors in Use Cases — Pas d'Exception pour le Flux Normal

```typescript
// ✅ Use case qui throw des erreurs domaine typées
export class RegisterUser {
  async execute(input: RegisterInput): Promise<UserDTO> {
    // Validation input → WeakPasswordError ou InvalidEmailError (DomainError)
    const email = Email.create(input.email); // throw InvalidEmailError si invalide
    const password = Password.create(input.password); // throw WeakPasswordError si faible

    // Règle métier → EmailAlreadyExistsError (DomainError)
    const existing = await this.userRepo.findByEmail(email.value);
    if (existing) throw new EmailAlreadyExistsError(email.value);

    // Traitement nominal → pas d'exception
    const user = User.register({
      id: UserId.generate(),
      email,
      password: await this.hasher.hash(password),
    });
    await this.userRepo.save(user);
    await this.eventBus.publishAll(user.pullEvents());

    return toUserDTO(user);
  }
}

// ❌ À éviter — Error générique sans type
throw new Error('Email already exists'); // pas typable, pas mappable
```
