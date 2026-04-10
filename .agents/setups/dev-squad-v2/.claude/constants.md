# Constants

<!-- last-verified: YYYY-MM-DD -->

## Environments

| Env        | API URL                           | Notes |
| ---------- | --------------------------------- | ----- |
| Local      | http://localhost:3000             |       |
| Staging    | https://api.staging.[project].com |       |
| Production | https://api.[project].com         |       |

---

## Stack Versions

```
node: 20.x LTS
typescript: 5.x
prisma: 5.x
vitest: 1.x  # or jest: 29.x
react: 18.x
```

---

## NPM Scripts

```bash
# Development
npm run dev          # server with hot reload
npm run dev:db       # start local database

# Tests (during TDD — use watch mode)
npm test             # all tests
npm run test:watch   # watch mode for TDD
npm run test:coverage # coverage report

# Quality
npm run lint         # ESLint
npm run type-check   # TypeScript strict
npm run format       # Prettier

# Database
npm run db:migrate   # apply migrations
npm run db:seed      # test data
npm run db:reset     # full reset (dev only)
```

---

## Required Environment Variables

```bash
# .env.example — copy to .env
DATABASE_URL=postgresql://localhost:5432/[project]
JWT_SECRET=[generate with: openssl rand -base64 32]
# Add other variables here
```

---

## Coverage Thresholds

| Layer           | Minimum required |
| --------------- | ---------------- |
| domain/         | 100%             |
| application/    | 90%              |
| infrastructure/ | 70%              |
| presentation/   | 60%              |
