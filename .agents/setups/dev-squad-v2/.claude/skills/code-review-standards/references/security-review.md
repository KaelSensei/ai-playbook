# Security Review Checklist — TypeScript

## Injections

```typescript
// ❌ Injection SQL via concaténation
const users = await db.query(`SELECT * FROM users WHERE email = '${req.body.email}'`);

// ✅ Paramètres Prisma (protégés automatiquement)
const user = await prisma.user.findUnique({ where: { email: req.body.email } });

// ❌ Injection NoSQL
db.collection('users').find({ email: req.body.email }); // si email = { $ne: null }

// ✅ Validation du type avant la requête
const email = z.string().email().parse(req.body.email); // throws si invalide
```

## Authentification et Autorisation

```typescript
// ❌ Token généré avec Math.random()
const token = Math.random().toString(36).substring(7);

// ✅ Crypto secure
import { randomBytes } from 'crypto';
const token = randomBytes(32).toString('hex');

// ❌ Vérification d'autorisation côté controller uniquement
router.delete('/users/:id', authenticate, async (req, res) => {
  await userService.delete(req.params.id); // pas de vérification qui peut supprimer qui
});

// ✅ Vérification dans le use case
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
// ❌ Mot de passe dans les logs
console.log('User logging in:', { email, password }); // JAMAIS

// ✅ Logs sans données sensibles
console.log('User logging in:', { email }); // OK

// ❌ Password hash dans la réponse API
res.json({ id: user.id, email: user.email, passwordHash: user.passwordHash });

// ✅ DTO sans données sensibles
const userDto = { id: user.id.value, email: user.email.value, role: user.role };
res.json(userDto);

// ❌ Clé API dans le code
const apiKey = 'sk_live_abc123'; // JAMAIS en dur

// ✅ Variables d'environnement validées au démarrage
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

// Endpoints auth — strict
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  message: { error: { code: 'RATE_LIMIT', message: 'Too many attempts' } },
});

app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', rateLimit({ windowMs: 3600000, max: 3 }));

// API globale
app.use('/api/', rateLimit({ windowMs: 3600000, max: 1000 }));
```
