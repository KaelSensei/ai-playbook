---
name: security-web2
description: >
  OWASP Top 10 web2, auth/authz, SQL/NoSQL/XSS injections, secrets management, security headers,
  rate limiting, CORS. Auto-loaded by security-reviewer. Invoke for any application-level web
  security question.
---

# Security Web2 Reference

## OWASP Top 10 — Concrete Patterns

### A01 — Injection

```typescript
// ❌ SQL injection
const query = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ Always parameterized
const user = await prisma.user.findUnique({ where: { email } });

// ❌ NoSQL injection (MongoDB)
db.users.find({ email: req.body.email }); // if email = { $ne: null }

// ✅ Type-validate before the query
const email = z.string().email().parse(req.body.email);
db.users.find({ email });

// ❌ Command injection
exec(`ls ${userInput}`);

// ✅ Never exec with user input — use native APIs
```

### A02 — Broken Authentication

```typescript
// ✅ Password hashing
import bcrypt from 'bcrypt';
const COST = 12;
const hash = await bcrypt.hash(password, COST);
const valid = await bcrypt.compare(input, hash);

// ✅ Secure JWT
const token = jwt.sign(
  { sub: user.id, role: user.role },
  process.env.JWT_SECRET, // min 256 bits random
  { expiresIn: '15m', algorithm: 'HS256' }
);

// ✅ Refresh token rotation
// access token: 15min, in memory (not localStorage)
// refresh token: 7d, httpOnly cookie, rotated on each use

// ✅ Brute force protection
// Rate limit: 5 attempts / 15min per IP on /auth/login

// ✅ Timing-safe comparison (tokens)
import { timingSafeEqual } from 'crypto';
const valid = timingSafeEqual(Buffer.from(providedToken), Buffer.from(storedHash));
```

### A03 — Sensitive Data Exposure

```typescript
// ✅ Never log sensitive data
logger.info('User login', { userId: user.id }); // OK
logger.info('User login', { user }); // ❌ includes the password hash

// ✅ Exclude sensitive fields from API responses
const userResponse = exclude(user, ['password', 'refreshToken']);

// ✅ Env vars for secrets (never in the code)
const secret = process.env.JWT_SECRET; // ✅
const secret = 'hardcoded_secret'; // ❌

// ✅ HTTPS enforced in production
// ✅ Cookies with Secure + HttpOnly + SameSite=Strict
res.cookie('refreshToken', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000,
});
```

### A05 — Broken Access Control

```typescript
// ✅ Check permissions in the service layer, not just the controller
class PostService {
  async deletePost(postId: string, requestingUserId: string) {
    const post = await this.repo.findById(postId)
    if (!post) throw new NotFoundException()

    // IDOR prevention: verify the user is the owner
    if (post.userId !== requestingUserId) {
      throw new ForbiddenException()
    }
    await this.repo.delete(postId)
  }
}

// ✅ RBAC: check the role, not just authentication
@Roles('ADMIN')
@Get('/admin/users')
async getAllUsers() { ... }

// ✅ Restrictive CORS
app.use(cors({
  origin: ['https://myapp.com', 'https://www.myapp.com'],
  credentials: true,
}))
```

### A06 — Security Misconfiguration

```typescript
// ✅ Security headers (Helmet.js)
import helmet from 'helmet';
app.use(helmet());
// Includes: X-Content-Type-Options, X-Frame-Options, HSTS,
//           Content-Security-Policy, X-XSS-Protection

// ✅ Disable version info
app.disable('x-powered-by');

// ✅ No stack trace in production
app.use((err, req, res, next) => {
  const message = process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message;
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message } });
});

// ✅ Env vars validated at startup
const env = z
  .object({
    JWT_SECRET: z.string().min(32),
    DATABASE_URL: z.string().url(),
  })
  .parse(process.env);
```

### A07 — XSS

```typescript
// ✅ Never inject unescaped HTML
// React escapes automatically — dangerouslySetInnerHTML = ❌ unless absolutely necessary

// ✅ Content-Security-Policy
app.use(
  helmet.contentSecurityPolicy({
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  })
);

// ✅ Sanitizer if user HTML is necessary
import DOMPurify from 'dompurify';
const clean = DOMPurify.sanitize(userHtml);
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// Auth endpoints: strict
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 5,
  message: { error: { code: 'RATE_LIMIT', message: 'Too many attempts' } },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', rateLimit({ windowMs: 3600000, max: 3 }));

// Global API
const apiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1h
  max: 1000,
});
app.use('/api/', apiLimiter);
```

## Input Validation

```typescript
// Always validate with a schema before hitting the DB
import { z } from 'zod';

const CreateUserDto = z.object({
  email: z.string().email().max(255).toLowerCase(),
  password: z
    .string()
    .min(8)
    .max(100)
    .regex(/[A-Z]/, 'Must contain uppercase')
    .regex(/[0-9]/, 'Must contain number'),
  name: z.string().min(1).max(100).trim(),
});

// Validation middleware
const validate = (schema: ZodSchema) => (req, res, next) => {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({
      error: {
        code: 'VALIDATION_ERROR',
        details: result.error.errors.map((e) => ({
          field: e.path.join('.'),
          message: e.message,
        })),
      },
    });
  }
  req.body = result.data; // sanitized data
  next();
};
```

## Secure Deployment Checklist

```
[ ] HTTPS enforced, HSTS enabled
[ ] Helmet.js configured
[ ] Explicit CORS allowlist
[ ] Rate limiting on auth endpoints
[ ] Input validation on every endpoint
[ ] No secrets in code (audit: grep -r "password\|secret\|key" src/)
[ ] JWT_SECRET >= 32 chars random
[ ] Cookies httpOnly + Secure + SameSite
[ ] Stack traces disabled in production
[ ] npm audit / pip audit clean
[ ] Logs without sensitive data
[ ] RBAC checked in the service layer
```
