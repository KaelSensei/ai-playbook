# Security Review Checklist — TypeScript

## Injections

```typescript
// ❌ SQL injection via concatenation
const users = await db.query(`SELECT * FROM users WHERE email = '${req.body.email}'`);

// ✅ Prisma parameters (protected automatically)
const user = await prisma.user.findUnique({ where: { email: req.body.email } });

// ❌ NoSQL injection
db.collection('users').find({ email: req.body.email }); // if email = { $ne: null }

// ✅ Validate the type before the query
const email = z.string().email().parse(req.body.email); // throws if invalid
```

## Authentication and Authorization

```typescript
// ❌ Token generated with Math.random()
const token = Math.random().toString(36).substring(7);

// ✅ Crypto secure
import { randomBytes } from 'crypto';
const token = randomBytes(32).toString('hex');

// ❌ Authorization check only in the controller
router.delete('/users/:id', authenticate, async (req, res) => {
  await userService.delete(req.params.id); // no check for who can delete whom
});

// ✅ Check in the use case
class DeleteUser {
  async execute(requesterId: UserId, targetId: UserId): Promise<void> {
    const requester = await this.userRepo.findById(requesterId);
    if (!requester.isAdmin() && !requesterId.equals(targetId)) {
      throw new UnauthorizedError('delete this user');
    }
    // ...
  }
}
```

## Secrets and Sensitive Data

```typescript
// ❌ Password in the logs
console.log('User logging in:', { email, password }); // NEVER

// ✅ Logs without sensitive data
console.log('User logging in:', { email }); // OK

// ❌ Password hash in the API response
res.json({ id: user.id, email: user.email, passwordHash: user.passwordHash });

// ✅ DTO without sensitive data
const userDto = { id: user.id.value, email: user.email.value, role: user.role };
res.json(userDto);

// ❌ API key in the code
const apiKey = 'sk_live_abc123'; // NEVER hardcoded

// ✅ Environment variables validated at startup
const config = z
  .object({
    API_KEY: z.string().min(20),
    DATABASE_URL: z.string().url(),
  })
  .parse(process.env);
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// Auth endpoints — strict
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  message: { error: { code: 'RATE_LIMIT', message: 'Too many attempts' } },
});

app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', rateLimit({ windowMs: 3600000, max: 3 }));

// Global API
app.use('/api/', rateLimit({ windowMs: 3600000, max: 1000 }));
```
