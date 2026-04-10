---
name: database-patterns
description: >
  Schema design, zero-downtime migrations, indexes, N+1 queries, soft delete, ORM patterns.
  Auto-loaded by architect and data-engineer. Invoke for any question about DB modeling, migrations,
  query performance, or ORM patterns.
---

# Database Patterns Reference

## Schema Design

### Appropriate Types

```sql
-- IDs: UUID v4 (portable, not guessable)
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- Timestamps: always WITH TIME ZONE
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
deleted_at TIMESTAMPTZ NULL  -- soft delete

-- Enum: as a SQL type or VARCHAR with a CHECK constraint
status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'INACTIVE', 'PENDING'))
-- or
CREATE TYPE user_status AS ENUM ('ACTIVE', 'INACTIVE', 'PENDING');

-- Financial amounts: NUMERIC, never FLOAT
amount NUMERIC(10, 2) NOT NULL  -- not FLOAT or DOUBLE PRECISION
```

### Constraints

```sql
-- Always declare explicitly
email VARCHAR(255) NOT NULL UNIQUE
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE
CHECK (ends_at > starts_at)
```

## Zero-Downtime Migrations

### Safety Rules

```sql
-- ✅ SAFE: add a nullable column
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500) NULL;

-- ✅ SAFE: add a column with default (PostgreSQL 11+)
ALTER TABLE users ADD COLUMN is_verified BOOLEAN NOT NULL DEFAULT false;

-- ✅ SAFE: create an index without locking (PostgreSQL)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- ✅ SAFE: add a table
CREATE TABLE notifications (...);

-- ⚠️  RISKY: add NOT NULL without default on a populated table
-- → 3 steps: add nullable, backfill, add constraint
ALTER TABLE users ADD COLUMN country VARCHAR(2) NULL;
UPDATE users SET country = 'FR' WHERE country IS NULL;
ALTER TABLE users ALTER COLUMN country SET NOT NULL;

-- ⚠️  RISKY: rename a column
-- → 3 steps across 3 deployments: add, sync, drop the old one
ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
-- deployment 1: write to both columns
-- deployment 2: read from full_name
-- deployment 3: drop name
ALTER TABLE users DROP COLUMN name;

-- ❌ DANGEROUS: DROP without backup
-- ❌ DANGEROUS: change the type of a populated column
-- ❌ DANGEROUS: NOT NULL on a large table without default
```

### Migration Structure (Prisma / Flyway / Liquibase)

```sql
-- Always include a context comment
-- Migration: add_stripe_customer_id_to_users
-- Date: 2024-03-15
-- Author: your-name
-- Reason: store Stripe customer ID for billing

ALTER TABLE users ADD COLUMN stripe_customer_id VARCHAR(255) NULL;
CREATE UNIQUE INDEX CONCURRENTLY idx_users_stripe_customer_id
  ON users(stripe_customer_id)
  WHERE stripe_customer_id IS NOT NULL;
```

## Indexes

### When to Index

```sql
-- Join columns: ALWAYS
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Columns frequently used in filters
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- Frequent sorting on large tables
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Composite indexes: order = decreasing selectivity
CREATE INDEX idx_subscriptions_user_status
  ON subscriptions(user_id, status);
-- ↑ user_id first (more selective), then status

-- Partial index: when frequently filtering on a sub-condition
CREATE INDEX idx_users_active
  ON users(email)
  WHERE deleted_at IS NULL;
```

### When NOT to Index

```sql
-- Small tables (< 1000 rows) → full scan is faster
-- Rarely filtered columns
-- Very low-cardinality columns (booleans on a large table)
-- Write-intensive tables → indexes slow down writes
```

## Avoiding N+1

```typescript
// ❌ N+1: 1 query for posts + N queries for authors
const posts = await Post.findAll();
for (const post of posts) {
  post.author = await User.findById(post.userId); // N queries!
}

// ✅ Eager loading
const posts = await Post.findAll({ include: ['author'] });

// ✅ Prisma
const posts = await prisma.post.findMany({
  include: { author: true },
});

// ✅ Dataloader pattern (GraphQL)
const userLoader = new DataLoader(async (ids) => {
  const users = await User.findByIds(ids);
  return ids.map((id) => users.find((u) => u.id === id));
});
```

## Soft Delete Convention

```typescript
// All user-facing entities have deleted_at
model User {
  id        String    @id @default(uuid())
  deletedAt DateTime? @map("deleted_at")
}

// All queries filter automatically
// ✅ Prisma middleware to auto-filter
prisma.$use(async (params, next) => {
  if (params.model && params.action === 'findMany') {
    params.args.where = {
      ...params.args.where,
      deletedAt: null,
    }
  }
  return next(params)
})

// Soft delete
async function softDelete(id: string) {
  await prisma.user.update({
    where: { id },
    data: { deletedAt: new Date() }
  })
}

// Hard delete only on explicit GDPR request
```

## Transactions

```typescript
// Atomic operations are required for multi-table changes
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData })
  await tx.subscription.create({ data: { userId: user.id, plan: 'FREE' } })
  await tx.auditLog.create({ data: { userId: user.id, action: 'REGISTER' } })
  // If one operation fails → everything is rolled back
})

// Timeout on long transactions
await prisma.$transaction(async (tx) => { ... }, {
  timeout: 5000,  // 5 seconds max
})
```

## Query Performance Checklist

```sql
-- Before merging a query change:
EXPLAIN ANALYZE SELECT ...;
-- Check:
-- ✅ Seq Scan on a small table → OK
-- ⚠️  Seq Scan on a large table → needs an index
-- ✅ Index Scan → good
-- ⚠️  Sort without index → ORDER BY + LIMIT without index = slow
-- ⚠️  Hash Join on a very large table → check the stats
```
