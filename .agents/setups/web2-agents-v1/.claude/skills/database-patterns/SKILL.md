---
name: database-patterns
description: >
  Schema design, migrations zero-downtime, indexes, requêtes N+1, soft delete, patterns ORM.
  Auto-chargé par architect, data-engineer. Invoke pour toute question de modélisation BDD,
  migration, performance de requête ou pattern ORM.
---

# Database Patterns Reference

## Schema Design

### Types appropriés

```sql
-- IDs : UUID v4 (portable, pas prédictible)
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- Timestamps : toujours WITH TIME ZONE
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
deleted_at TIMESTAMPTZ NULL  -- soft delete

-- Enum : comme type SQL ou VARCHAR avec contrainte CHECK
status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE', 'INACTIVE', 'PENDING'))
-- ou
CREATE TYPE user_status AS ENUM ('ACTIVE', 'INACTIVE', 'PENDING');

-- Montants financiers : NUMERIC, jamais FLOAT
amount NUMERIC(10, 2) NOT NULL  -- pas FLOAT ou DOUBLE PRECISION
```

### Contraintes

```sql
-- Toujours déclarer explicitement
email VARCHAR(255) NOT NULL UNIQUE
user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE
CHECK (ends_at > starts_at)
```

## Migrations Zero-Downtime

### Règles de sécurité

```sql
-- ✅ SAFE : ajouter une colonne nullable
ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500) NULL;

-- ✅ SAFE : ajouter une colonne avec défaut (PostgreSQL 11+)
ALTER TABLE users ADD COLUMN is_verified BOOLEAN NOT NULL DEFAULT false;

-- ✅ SAFE : créer un index sans bloquer (PostgreSQL)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- ✅ SAFE : ajouter une table
CREATE TABLE notifications (...);

-- ⚠️  RISQUÉ : ajouter NOT NULL sans défaut sur table peuplée
-- → 3 étapes : ajouter nullable, backfill, ajouter contrainte
ALTER TABLE users ADD COLUMN country VARCHAR(2) NULL;
UPDATE users SET country = 'FR' WHERE country IS NULL;
ALTER TABLE users ALTER COLUMN country SET NOT NULL;

-- ⚠️  RISQUÉ : renommer une colonne
-- → 3 étapes sur 3 déploiements : ajouter, synchro, supprimer l'ancien
ALTER TABLE users ADD COLUMN full_name VARCHAR(255);
-- déploiement 1 : écrire dans les deux colonnes
-- déploiement 2 : lire depuis full_name
-- déploiement 3 : supprimer name
ALTER TABLE users DROP COLUMN name;

-- ❌ DANGEREUX : DROP sans backup
-- ❌ DANGEREUX : changer le type d'une colonne peuplée
-- ❌ DANGEREUX : NOT NULL sur grande table sans défaut
```

### Structure de migration (Prisma / Flyway / Liquibase)

```sql
-- Toujours inclure un commentaire de contexte
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

### Quand indexer

```sql
-- Colonnes de jointure : TOUJOURS
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- Colonnes de filtre fréquent
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- Tri fréquent sur grandes tables
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Index composites : ordre = sélectivité décroissante
CREATE INDEX idx_subscriptions_user_status
  ON subscriptions(user_id, status);
-- ↑ user_id d'abord (plus sélectif), puis status

-- Index partiel : si on filtre souvent sur une sous-condition
CREATE INDEX idx_users_active
  ON users(email)
  WHERE deleted_at IS NULL;
```

### Quand NE PAS indexer

```sql
-- Petites tables (< 1000 rows) → full scan plus rapide
-- Colonnes rarement filtrées
-- Colonnes à cardinalité très faible (booléens sur grande table)
-- Tables en écriture intensive → indexes ralentissent les writes
```

## Éviter le N+1

```typescript
// ❌ N+1 : 1 query pour les posts + N queries pour les auteurs
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
// Toutes les entités utilisateur ont deleted_at
model User {
  id        String    @id @default(uuid())
  deletedAt DateTime? @map("deleted_at")
}

// Toutes les queries filtrent automatiquement
// ✅ Prisma middleware pour auto-filter
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

// Hard delete uniquement sur demande RGPD explicite
```

## Transactions

```typescript
// Opérations atomiques obligatoires pour les changements multi-tables
await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData })
  await tx.subscription.create({ data: { userId: user.id, plan: 'FREE' } })
  await tx.auditLog.create({ data: { userId: user.id, action: 'REGISTER' } })
  // Si une opération échoue → tout est rollbacké
})

// Timeout sur les transactions longues
await prisma.$transaction(async (tx) => { ... }, {
  timeout: 5000,  // 5 secondes max
})
```

## Query Performance Checklist

```sql
-- Avant de merger un changement de query :
EXPLAIN ANALYZE SELECT ...;
-- Vérifier :
-- ✅ Seq Scan sur petite table → OK
-- ⚠️  Seq Scan sur grande table → besoin d'index
-- ✅ Index Scan → bon
-- ⚠️  Sort sans index → ORDER BY + LIMIT sans index = lent
-- ⚠️  Hash Join sur très grande table → vérifier les stats
```
