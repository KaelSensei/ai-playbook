# Constants

<!-- last-verified: YYYY-MM-DD -->
<!--
  Mettre à jour quand :
  - Une URL de service change
  - Des variables d'env sont ajoutées / retirées
  - Des versions de dépendances clés changent
-->

## Environments

| Env        | URL                          | Notes       |
| ---------- | ---------------------------- | ----------- |
| Local      | `http://localhost:3000`      |             |
| Staging    | `https://staging.monapp.com` | branch main |
| Production | `https://monapp.com`         | tag release |

## Environment Variables

```bash
# App
NODE_ENV=               # development | staging | production
PORT=3000
APP_URL=

# Database
DATABASE_URL=           # postgresql://user:pass@host:5432/db
DATABASE_POOL_MIN=2
DATABASE_POOL_MAX=10

# Auth
JWT_SECRET=             # min 32 chars, random
JWT_ACCESS_TTL=900      # 15 min en secondes
JWT_REFRESH_TTL=604800  # 7 jours en secondes

# Cache
REDIS_URL=              # redis://localhost:6379

# Email
SENDGRID_API_KEY=
EMAIL_FROM=noreply@monapp.com

# Paiements
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_PRO=

# Storage
CLOUDINARY_URL=

# Monitoring
SENTRY_DSN=
LOG_LEVEL=              # debug | info | warn | error
```

## Service URLs (internes)

```
API_BASE_URL=/api/v1
AUTH_SERVICE=/api/v1/auth
USERS_SERVICE=/api/v1/users
```

## Toolchain Versions

```
node:       20.x LTS
typescript: 5.x
[framework]: x.x.x  ← à remplir
[orm]:       x.x.x  ← à remplir
[test runner]: x.x.x ← à remplir
docker:     24.x
```

## Rate Limits

| Endpoint                  | Limite   | Fenêtre |
| ------------------------- | -------- | ------- |
| POST /auth/login          | 5 req    | 15 min  |
| POST /auth/register       | 3 req    | 1h      |
| /api/\*\* (authenticated) | 1000 req | 1h      |
| /api/\*\* (anonymous)     | 100 req  | 1h      |

## Feature Flags

<!--
  Flags actifs en production.
  Format : NOM_FLAG — description — actif en (prod/staging/dev)
-->
