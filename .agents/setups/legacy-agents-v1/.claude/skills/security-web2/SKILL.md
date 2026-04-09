---
name: security-web2
description: >
  OWASP Top 10 web2, auth/authz, injections SQL/NoSQL/XSS, secrets management, headers de sécurité,
  rate limiting, CORS. Auto-chargé par security-reviewer. Invoke pour toute question de sécurité
  applicative web.
---

# Security Web2 Reference

## OWASP Top 10 — Patterns Concrets

### A01 — Injection

```typescript
// ❌ SQL injection
const query = `SELECT * FROM users WHERE email = '${email}'`;

// ✅ Paramétré toujours
const user = await prisma.user.findUnique({ where: { email } });

// ❌ NoSQL injection (MongoDB)
db.users.find({ email: req.body.email }); // si email = { $ne: null }

// ✅ Validation de type avant requête
const email = z.string().email().parse(req.body.email);
db.users.find({ email });

// ❌ Command injection
exec(`ls ${userInput}`);

// ✅ Jamais exec avec input utilisateur — utiliser des APIs natives
```

### A02 — Broken Authentication

```typescript
// ✅ Hachage des mots de passe
import bcrypt from 'bcrypt';
const COST = 12;
const hash = await bcrypt.hash(password, COST);
const valid = await bcrypt.compare(input, hash);

// ✅ JWT sécurisé
const token = jwt.sign(
  { sub: user.id, role: user.role },
  process.env.JWT_SECRET, // min 256 bits random
  { expiresIn: '15m', algorithm: 'HS256' }
);

// ✅ Refresh token rotation
// access token : 15min, en mémoire (pas localStorage)
// refresh token : 7j, httpOnly cookie, rotation à chaque use

// ✅ Brute force protection
// Rate limit : 5 tentatives / 15min par IP sur /auth/login

// ✅ Timing-safe comparison (tokens)
import { timingSafeEqual } from 'crypto';
const valid = timingSafeEqual(Buffer.from(providedToken), Buffer.from(storedHash));
```

### A03 — Sensitive Data Exposure

```typescript
// ✅ Jamais logguer de données sensibles
logger.info('User login', { userId: user.id }); // OK
logger.info('User login', { user }); // ❌ inclut le password hash

// ✅ Exclure les champs sensibles des réponses API
const userResponse = exclude(user, ['password', 'refreshToken']);

// ✅ Variables d'env pour les secrets (jamais dans le code)
const secret = process.env.JWT_SECRET; // ✅
const secret = 'hardcoded_secret'; // ❌

// ✅ HTTPS forcé en production
// ✅ Cookies avec Secure + HttpOnly + SameSite=Strict
res.cookie('refreshToken', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000,
});
```

### A05 — Broken Access Control

```typescript
// ✅ Vérifier les permissions au niveau service, pas juste controller
class PostService {
  async deletePost(postId: string, requestingUserId: string) {
    const post = await this.repo.findById(postId)
    if (!post) throw new NotFoundException()

    // IDOR prevention : vérifier que l'user est propriétaire
    if (post.userId !== requestingUserId) {
      throw new ForbiddenException()
    }
    await this.repo.delete(postId)
  }
}

// ✅ RBAC : vérifier le rôle, pas juste l'authentification
@Roles('ADMIN')
@Get('/admin/users')
async getAllUsers() { ... }

// ✅ CORS restrictif
app.use(cors({
  origin: ['https://monapp.com', 'https://www.monapp.com'],
  credentials: true,
}))
```

### A06 — Security Misconfiguration

```typescript
// ✅ Headers de sécurité (Helmet.js)
import helmet from 'helmet';
app.use(helmet());
// Inclut : X-Content-Type-Options, X-Frame-Options, HSTS,
//          Content-Security-Policy, X-XSS-Protection

// ✅ Désactiver les infos de version
app.disable('x-powered-by');

// ✅ Pas de stack trace en production
app.use((err, req, res, next) => {
  const message = process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message;
  res.status(500).json({ error: { code: 'INTERNAL_ERROR', message } });
});

// ✅ Variables d'env validées au démarrage
const env = z
  .object({
    JWT_SECRET: z.string().min(32),
    DATABASE_URL: z.string().url(),
  })
  .parse(process.env);
```

### A07 — XSS

```typescript
// ✅ Jamais injecter du HTML non-échappé
// React échappe automatiquement — dangerouslySetInnerHTML = ❌ sauf nécessité absolue

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

// ✅ Sanitizer si HTML utilisateur nécessaire
import DOMPurify from 'dompurify';
const clean = DOMPurify.sanitize(userHtml);
```

## Rate Limiting

```typescript
import rateLimit from 'express-rate-limit';

// Auth endpoints : strict
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 5,
  message: { error: { code: 'RATE_LIMIT', message: 'Too many attempts' } },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', rateLimit({ windowMs: 3600000, max: 3 }));

// API globale
const apiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1h
  max: 1000,
});
app.use('/api/', apiLimiter);
```

## Input Validation

```typescript
// Toujours valider avec un schema avant de toucher la BDD
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

// Middleware de validation
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
  req.body = result.data; // données sanitisées
  next();
};
```

## Checklist Déploiement Sécurisé

```
[ ] HTTPS forcé, HSTS activé
[ ] Helmet.js configuré
[ ] CORS whitelist explicite
[ ] Rate limiting sur auth endpoints
[ ] Validation input sur tous les endpoints
[ ] Pas de secrets dans le code (audit : grep -r "password\|secret\|key" src/)
[ ] JWT_SECRET >= 32 chars random
[ ] Cookies httpOnly + Secure + SameSite
[ ] Stack traces désactivées en production
[ ] npm audit / pip audit propre
[ ] Logs sans données sensibles
[ ] RBAC vérifié au niveau service
```
