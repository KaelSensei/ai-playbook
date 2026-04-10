# Data Architecture

<!-- last-verified: YYYY-MM-DD -->

## SUMMARY

[Database]: [PostgreSQL | MySQL | MongoDB | ...] [ORM/Query builder]: [Prisma | Drizzle | TypeORM |
...] [Migrations]: [Prisma migrate | Flyway | ...]

---

## Main Schema

```
<!-- Copy the Prisma schema or main tables here -->
```

---

## Conventions

- Table naming: snake_case plural (users, bookings, ...)
- IDs: UUID v4 (no auto-increment)
- Soft delete: nullable deleted_at column
- Timestamps: created_at, updated_at on every table

---

## Important Indexes

| Table    | Indexed columns | Reason                    |
| -------- | --------------- | ------------------------- |
| users    | email           | Frequent lookup by email  |
| bookings | user_id, status | Frequent combined filters |

---

## Migrations

<!-- Rules for writing zero-downtime migrations -->

- Always backward compatible (add nullable column first)
- Never DROP COLUMN without a two-step migration
- Never rename a column directly
