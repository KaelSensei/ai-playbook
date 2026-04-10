# Constants

<!-- last-verified: YYYY-MM-DD -->
<!--
  Update when:
  - A service URL changes
  - Env vars are added / removed
  - Key dependency versions change
-->

## Environments

| Env        | URL                         | Notes       |
| ---------- | --------------------------- | ----------- |
| Local      | `http://localhost:3000`     |             |
| Staging    | `https://staging.myapp.com` | branch main |
| Production | `https://myapp.com`         | tag release |

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
JWT_ACCESS_TTL=900      # 15 min in seconds
JWT_REFRESH_TTL=604800  # 7 days in seconds

# Cache
REDIS_URL=              # redis://localhost:6379

# Email
SENDGRID_API_KEY=
EMAIL_FROM=noreply@myapp.com

# Payments
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
STRIPE_PRICE_PRO=

# Storage
CLOUDINARY_URL=

# Monitoring
SENTRY_DSN=
LOG_LEVEL=              # debug | info | warn | error
```

## Service URLs (internal)

```
API_BASE_URL=/api/v1
AUTH_SERVICE=/api/v1/auth
USERS_SERVICE=/api/v1/users
```

## Toolchain Versions

```
node:       20.x LTS
typescript: 5.x
[framework]: x.x.x  ← to fill in
[orm]:       x.x.x  ← to fill in
[test runner]: x.x.x ← to fill in
docker:     24.x
```

## Rate Limits

| Endpoint                  | Limit    | Window |
| ------------------------- | -------- | ------ |
| POST /auth/login          | 5 req    | 15 min |
| POST /auth/register       | 3 req    | 1h     |
| /api/\*\* (authenticated) | 1000 req | 1h     |
| /api/\*\* (anonymous)     | 100 req  | 1h     |

## Feature Flags

<!--
  Flags active in production.
  Format: FLAG_NAME — description — active in (prod/staging/dev)
-->
