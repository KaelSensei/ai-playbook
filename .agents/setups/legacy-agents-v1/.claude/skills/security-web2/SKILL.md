---
name: security-web2
description: >
  OWASP Top 10 web2, auth/authz, SQL/NoSQL/XSS injection, secrets management, security headers, rate
  limiting, CORS. Auto-loaded by security-reviewer. Invoke for any web application security
  question.
---

# Security Web2 Reference

## OWASP Top 10 — Concrete Patterns

### A01 — Injection

```typescript
// Bad — SQL injection
const query = `SELECT * FROM users WHERE email = '${email}'`;

// Good — always parameterized
const user = await prisma.user.findUnique({ where: { email } });

// Bad — NoSQL injection (MongoDB)
db.users.find({ email: req.body.email }); // if email = { $ne: null }

// Good — type validation before the query
const email = z.string().email().parse(req.body.email);
db.users.find({ email });

// Bad — command injection
exec(`ls ${userInput}`);

// Good — never exec with user input — use native APIs
```

### A02 — Broken Authentication

```typescript
// Good — password hashing
import bcrypt from 'bcrypt';
const COST = 12;
const hash = await bcrypt.hash(password, COST);
const valid = await bcrypt.compare(input, hash);

// Good — secure JWT
const token = jwt.sign(
  { sub: user.id, role: user.role },
  process.env.JWT_SECRET, // min 256 bits random
  { expiresIn: '15m', algorithm: 'HS256' }
);

// Good — refresh token rotation
// access token: 15min, in memory (not localStorage)
// refresh token: 7d, httpOnly cookie, rotate on each use

// Good — brute force protection
// Rate limit: 5 attempts / 15min per IP on /auth/login

// Good — timing-safe comparison (tokens)
import { timingSafeEqual } from 'crypto';
const valid = timingSafeEqual(Buffer.from(providedToken), Buffer.from(storedHash));
```

### A03 — Sensitive Data Exposure

```typescript
// Good — never log sensitive data
logger.info('User login', { userId: user.id }); // OK
logger.info('User login', { user }); // Bad — includes the password hash

// Good — exclude sensitive fields from API responses
const userResponse = exclude(user, ['password', 'refreshToken']);

// Good — env vars for secrets (never in the code)
const secret = process.env.JWT_SECRET; // Good
const secret = 'hardcoded_secret'; // Bad

// Good — HTTPS enforced in production
// Good — cookies with Secure + HttpOnly + SameSite=Strict
res.cookie('refreshToken', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000,
});
```

### A05 — Broken Access Control

```typescript
// Good — check permissions at the service level, not just in the controller
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

// Good — RBAC: check the role, not just authentication
@Roles('ADMIN')
@Get('/admin/users')
async getAllUsers() { ... }

// Good — restrictive CORS
app.use(cors({
  origin: ['https://myapp.com', 'https://www.myapp.com'],
  credentials: true,
}))
```

### A06 — Security Misconfiguration

```typescript
// Good — security headers (Helmet.js)
import helmet from 'helmet';
app.use(helmet());
// Includes: X-Content-Type-Options, X-Frame-Options, HSTS,
//           Content-Security-Policy, X-XSS-Protection

// Good — disable version info
app.disable('x-powered-by');

// Good — no stack trace in production
app.use((err, req, res, next) => {
  const message = process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message;
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message } });
});

// Good — env vars validated at startup
const env = z
  .object({
    JWT_SECRET: z.string().min(32),
    DATABASE_URL: z.string().url(),
  })
  .parse(process.env);
```

### A07 — XSS

```typescript
// Good — never inject unescaped HTML
// React escapes automatically — dangerouslySetInnerHTML = Bad unless absolutely necessary

// Good — Content-Security-Policy
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

// Good — sanitizer if user HTML is required
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
// Always validate with a schema before touching the DB
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
[ ] CORS explicit whitelist
[ ] Rate limiting on auth endpoints
[ ] Input validation on all endpoints
[ ] No secrets in the code (audit: grep -r "password\|secret\|key" src/)
[ ] JWT_SECRET >= 32 chars random
[ ] Cookies httpOnly + Secure + SameSite
[ ] Stack traces disabled in production
[ ] npm audit / pip audit clean
[ ] Logs without sensitive data
[ ] RBAC verified at the service level
```
