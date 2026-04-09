# Data Architecture

<!-- last-verified: YYYY-MM-DD -->

## SUMMARY

[Base de données]: [PostgreSQL | MySQL | MongoDB | ...] [ORM/Query builder]: [Prisma | Drizzle |
TypeORM | ...] [Migrations]: [Prisma migrate | Flyway | ...]

---

## Main Schema

```
<!-- Copier le schéma Prisma ou les tables principales ici -->
```

---

## Conventions

- Nommage tables : snake_case pluriel (users, bookings, ...)
- IDs : UUID v4 (pas auto-increment)
- Soft delete : colonne deleted_at nullable
- Timestamps : created_at, updated_at sur toutes les tables

---

## Index Importants

| Table    | Colonnes indexées | Raison                     |
| -------- | ----------------- | -------------------------- |
| users    | email             | Lookup par email fréquent  |
| bookings | user_id, status   | Filtres combinés fréquents |

---

## Migrations

<!-- Règles pour écrire les migrations sans downtime -->

- Toujours backward compatible (add column nullable first)
- Jamais DROP COLUMN sans migration en 2 étapes
- Jamais renommer une colonne directement
