# Constants

<!-- last-verified: YYYY-MM-DD -->

## Environnements

| Env        | API URL                          | Notes |
| ---------- | -------------------------------- | ----- |
| Local      | http://localhost:3000            |       |
| Staging    | https://api.staging.[projet].com |       |
| Production | https://api.[projet].com         |       |

---

## Stack Versions

```
node: 20.x LTS
typescript: 5.x
prisma: 5.x
vitest: 1.x  # ou jest: 29.x
react: 18.x
```

---

## Scripts NPM

```bash
# Development
npm run dev          # serveur avec hot reload
npm run dev:db       # démarrer la base de données locale

# Tests (pendant TDD — utiliser en watch)
npm test             # tous les tests
npm run test:watch   # watch mode pour TDD
npm run test:coverage # rapport de couverture

# Quality
npm run lint         # ESLint
npm run type-check   # TypeScript strict
npm run format       # Prettier

# Database
npm run db:migrate   # appliquer les migrations
npm run db:seed      # données de test
npm run db:reset     # reset complet (dev uniquement)
```

---

## Variables d'Environnement Requises

```bash
# .env.example — copier en .env
DATABASE_URL=postgresql://localhost:5432/[projet]
JWT_SECRET=[générer avec: openssl rand -base64 32]
# Ajouter les autres variables ici
```

---

## Seuils de Coverage

| Couche          | Minimum requis |
| --------------- | -------------- |
| domain/         | 100%           |
| application/    | 90%            |
| infrastructure/ | 70%            |
| presentation/   | 60%            |
