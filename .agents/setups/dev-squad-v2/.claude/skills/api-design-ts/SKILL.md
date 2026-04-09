---
name: api-design-ts
description: >
  Design d'API REST TypeScript/Express production-ready. Conventions REST, format de réponse
  standard, validation Zod middleware, gestion d'erreurs, controllers typés, pagination, versioning.
  Loaded by dev-senior-a/b, tech-lead.
---

# API Design TypeScript — Production

---

## REST Conventions

```typescript
// URLs : ressources en plural, noms — jamais de verbes
GET    /api/v1/users              // liste paginée
GET    /api/v1/users/:id          // détail
POST   /api/v1/users              // créer
PATCH  /api/v1/users/:id          // modifier partiellement
PUT    /api/v1/users/:id          // remplacer entièrement
DELETE /api/v1/users/:id          // supprimer

// Relations imbriquées — max 2 niveaux
GET    /api/v1/users/:id/orders
POST   /api/v1/users/:id/orders

// Actions non-CRUD — sous-ressource verbe
POST   /api/v1/users/:id/activate
POST   /api/v1/bookings/:id/cancel
POST   /api/v1/auth/refresh-token

// Status codes corrects
201 Created          → POST qui crée une ressource
200 OK               → GET, PATCH, PUT réussi
204 No Content       → DELETE réussi
400 Bad Request      → validation échouée
401 Unauthorized     → pas de token ou token invalide
403 Forbidden        → token valide mais permissions insuffisantes
404 Not Found        → ressource inexistante
409 Conflict         → violation de contrainte unique
422 Unprocessable    → données valides mais règle métier violée
500 Internal Error   → erreur inattendue
```

## Standard Response Format

```typescript
// types/api.ts
export type ApiSuccess<T> = {
  data: T;
  meta?: PaginationMeta;
};

export type PaginationMeta = {
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPrevPage: boolean;
};

export type ApiError = {
  error: {
    code: string;
    message: string;
    details?: Array<{ field: string; message: string }>;
    requestId?: string;
  };
};

// Helper centralisé
export const respond = {
  ok: <T>(res: Response, data: T, meta?: PaginationMeta): void => {
    res.status(200).json({ data, ...(meta && { meta }) });
  },
  created: <T>(res: Response, data: T): void => {
    res.status(201).json({ data });
  },
  noContent: (res: Response): void => {
    res.status(204).end();
  },
  error: (
    res: Response,
    status: number,
    code: string,
    message: string,
    details?: unknown[]
  ): void => {
    res.status(status).json({
      error: { code, message, ...(details && { details }) },
    });
  },
};
```

## Controller Complet

```typescript
// presentation/http/controllers/UserController.ts
export class UserController {
  constructor(
    private readonly registerUser: RegisterUser,
    private readonly getUser: GetUser,
    private readonly listUsers: ListUsers
  ) {}

  register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const result = await this.registerUser.execute(req.body as RegisterUserInput);
      respond.created(res, toUserDto(result));
    } catch (error) {
      if (error instanceof EmailAlreadyExistsError) {
        return respond.error(res, 409, 'EMAIL_ALREADY_EXISTS', 'This email is already registered');
      }
      if (error instanceof WeakPasswordError) {
        return respond.error(
          res,
          400,
          'WEAK_PASSWORD',
          'Password requirements not met',
          error.violations.map((v) => ({ field: 'password', message: v }))
        );
      }
      next(error);
    }
  };

  findById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user = await this.getUser.execute({ id: req.params.id });
      respond.ok(res, toUserDto(user));
    } catch (error) {
      if (error instanceof UserNotFoundError) {
        return respond.error(res, 404, 'USER_NOT_FOUND', 'User not found');
      }
      next(error);
    }
  };

  list = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const query = ListUsersQuerySchema.parse(req.query);
      const { users, total } = await this.listUsers.execute(query);
      respond.ok(res, users.map(toUserDto), {
        total,
        page: query.page,
        pageSize: query.pageSize,
        totalPages: Math.ceil(total / query.pageSize),
        hasNextPage: query.page * query.pageSize < total,
        hasPrevPage: query.page > 1,
      });
    } catch (error) {
      next(error);
    }
  };
}
```

## Zod Validation Middleware

```typescript
// middlewares/validate.ts
export const validate = {
  body:
    <T>(schema: z.ZodType<T>) =>
    (req: Request, res: Response, next: NextFunction): void => {
      const result = schema.safeParse(req.body);
      if (!result.success) {
        respond.error(
          res,
          400,
          'VALIDATION_ERROR',
          'Invalid request body',
          result.error.errors.map((e) => ({
            field: e.path.join('.'),
            message: e.message,
          }))
        );
        return;
      }
      req.body = result.data;
      next();
    },

  query:
    <T>(schema: z.ZodType<T>) =>
    (req: Request, res: Response, next: NextFunction): void => {
      const result = schema.safeParse(req.query);
      if (!result.success) {
        respond.error(
          res,
          400,
          'INVALID_QUERY',
          'Invalid query parameters',
          result.error.errors.map((e) => ({ field: e.path.join('.'), message: e.message }))
        );
        return;
      }
      req.query = result.data as ParsedQs;
      next();
    },
};

// Schémas courants
const RegisterUserSchema = z.object({
  email: z
    .string()
    .email()
    .max(255)
    .transform((s) => s.toLowerCase().trim()),
  password: z
    .string()
    .min(8)
    .max(100)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[0-9]/, 'Must contain number')
    .regex(/[^A-Za-z0-9]/, 'Must contain special character'),
  name: z.string().min(1).max(100).trim(),
});

const ListUsersQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
  role: z.nativeEnum(UserRole).optional(),
  search: z.string().max(100).optional(),
});

// Routes typées
router.post('/users', validate.body(RegisterUserSchema), controller.register);
router.get(
  '/users',
  authenticate,
  authorize([UserRole.ADMIN]),
  validate.query(ListUsersQuerySchema),
  controller.list
);
```

## Global Error Handler

```typescript
// middlewares/globalErrorHandler.ts
export const globalErrorHandler: ErrorRequestHandler = (error, req, res, _next) => {
  const requestId = req.headers['x-request-id'] as string;
  const isDev = process.env.NODE_ENV === 'development';

  logger.error('Unhandled error', {
    error: { message: error.message, stack: error.stack },
    request: { id: requestId, method: req.method, path: req.path },
  });

  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
      requestId,
      ...(isDev && { debug: error.message }),
    },
  });
};
// Toujours en dernier dans app.ts
app.use(globalErrorHandler);
```

## Available References

- `references/auth-middleware.md` — JWT, refresh tokens, RBAC par rôle
