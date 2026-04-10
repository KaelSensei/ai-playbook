# Auth Middleware — JWT + RBAC TypeScript

## Full JWT Middleware

```typescript
// middlewares/authenticate.ts
import jwt from 'jsonwebtoken';

export type AuthenticatedRequest = Request & {
  user: { id: string; email: string; role: UserRole };
};

export const authenticate = (req: Request, res: Response, next: NextFunction): void => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    respond.error(res, 401, 'MISSING_TOKEN', 'Authentication required');
    return;
  }

  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as JwtPayload;
    (req as AuthenticatedRequest).user = {
      id: payload.sub as string,
      email: payload.email as string,
      role: payload.role as UserRole,
    };
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      respond.error(res, 401, 'TOKEN_EXPIRED', 'Token has expired');
    } else {
      respond.error(res, 401, 'INVALID_TOKEN', 'Invalid token');
    }
  }
};

// Optional — does not fail if missing
export const optionalAuthenticate = (req: Request, res: Response, next: NextFunction): void => {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    next();
    return;
  }
  authenticate(req, res, next);
};
```

## RBAC — Role-Based Authorisation

```typescript
// middlewares/authorize.ts
export const authorize =
  (allowedRoles: UserRole[]) =>
  (req: Request, res: Response, next: NextFunction): void => {
    const user = (req as AuthenticatedRequest).user;
    if (!user) {
      respond.error(res, 401, 'UNAUTHENTICATED', 'Authentication required');
      return;
    }
    if (!allowedRoles.includes(user.role)) {
      respond.error(res, 403, 'FORBIDDEN', 'Insufficient permissions');
      return;
    }
    next();
  };

// Ownership middleware — verifies the user accesses THEIR own data
export const authorizeOwnerOrAdmin =
  (getResourceOwnerId: (req: Request) => string) =>
  (req: Request, res: Response, next: NextFunction): void => {
    const user = (req as AuthenticatedRequest).user;
    const resourceOwnerId = getResourceOwnerId(req);

    if (user.role === UserRole.ADMIN || user.id === resourceOwnerId) {
      next();
      return;
    }
    respond.error(res, 403, 'FORBIDDEN', 'You can only access your own resources');
  };

// Routes with auth
router.get('/users', authenticate, authorize([UserRole.ADMIN]), userController.list);

router.patch(
  '/users/:id',
  authenticate,
  authorizeOwnerOrAdmin((req) => req.params.id),
  validate.body(UpdateUserSchema),
  userController.update
);
```

## Token Generation and Refresh

```typescript
// services/TokenService.ts
export class TokenService {
  generateAccessToken(user: User): string {
    return jwt.sign(
      { sub: user.id.value, email: user.email.value, role: user.role },
      process.env.JWT_SECRET!,
      { expiresIn: '15m' }
    );
  }

  generateRefreshToken(userId: UserId): string {
    return jwt.sign({ sub: userId.value, type: 'refresh' }, process.env.JWT_REFRESH_SECRET!, {
      expiresIn: '7d',
    });
  }

  verifyRefreshToken(token: string): { userId: string } {
    const payload = jwt.verify(token, process.env.JWT_REFRESH_SECRET!) as JwtPayload;
    if (payload.type !== 'refresh') throw new InvalidTokenError();
    return { userId: payload.sub as string };
  }
}

// Refresh route
router.post('/auth/refresh', async (req, res, next) => {
  const { refreshToken } = req.body;
  try {
    const { userId } = tokenService.verifyRefreshToken(refreshToken);
    const user = await userRepo.findById(new UserId(userId));
    if (!user) throw new UserNotFoundError(userId);

    const newAccessToken = tokenService.generateAccessToken(user);
    const newRefreshToken = tokenService.generateRefreshToken(user.id);

    res.json({ data: { accessToken: newAccessToken, refreshToken: newRefreshToken } });
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError || error instanceof InvalidTokenError) {
      respond.error(res, 401, 'REFRESH_TOKEN_INVALID', 'Please log in again');
    } else {
      next(error);
    }
  }
});
```
