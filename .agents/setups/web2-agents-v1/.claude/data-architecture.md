# Data Architecture

<!-- last-verified: YYYY-MM-DD -->
<!--
  STALENESS RULE : si today - last-verified > 30 jours → STALE.
  Vérifier contre le schéma réel avant de raisonner depuis ce doc.
-->

## Database Schema

<!--
  Tables principales, colonnes, contraintes, relations.
  Exemple :

  users
  ├── id          UUID PK
  ├── email       VARCHAR(255) UNIQUE NOT NULL
  ├── password    VARCHAR(255) NOT NULL (hashed bcrypt)
  ├── role        ENUM('ADMIN','USER') DEFAULT 'USER'
  ├── created_at  TIMESTAMPTZ DEFAULT now()
  └── deleted_at  TIMESTAMPTZ NULL (soft delete)

  subscriptions
  ├── id          UUID PK
  ├── user_id     UUID FK → users.id
  ├── plan        ENUM('FREE','PRO','ENTERPRISE')
  ├── status      ENUM('ACTIVE','CANCELLED','PAST_DUE')
  ├── starts_at   TIMESTAMPTZ NOT NULL
  └── ends_at     TIMESTAMPTZ NULL
-->

## Relations

<!--
  Diagramme ou liste des relations importantes.
  Exemple :
  users 1──* subscriptions
  users 1──* audit_logs
  users *──* teams (via team_members)
-->

## Indexes

<!--
  Index existants et leur justification.
  Exemple :
  - users(email) UNIQUE — login lookup
  - subscriptions(user_id) — jointure fréquente
  - audit_logs(created_at DESC) — pagination chronologique
-->

## Migrations Strategy

<!--
  Comment les migrations sont gérées.
  Exemple :
  - Prisma Migrate en dev, prisma migrate deploy en prod
  - Zero-downtime : colonnes ajoutées nullable d'abord
  - Jamais de DROP COLUMN sans migration de données au préalable
  - Les migrations sont squashées tous les 3 mois
-->

## Soft Delete Convention

<!--
  Comment les suppressions sont gérées.
  Exemple :
  - Toutes les entités utilisateurs ont deleted_at TIMESTAMPTZ NULL
  - Les queries filtrent WHERE deleted_at IS NULL par défaut
  - Hard delete uniquement sur demande explicite RGPD
-->

## Sensitive Data

<!--
  Quelles données sont sensibles et comment elles sont protégées.
  Exemple :
  - Passwords : bcrypt cost 12, jamais loggés
  - Tokens : hachés en base (SHA-256), valeur brute jamais stockée
  - PII (email, nom) : chiffrés at-rest sur les colonnes marquées
-->

## Caching Strategy

<!--
  Ce qui est mis en cache, durée, invalidation.
  Exemple :
  - Session : Redis, TTL 15min (access) / 7j (refresh)
  - User profile : Redis, TTL 5min, invalidé sur update
  - Plan features : in-memory, rechargé au démarrage
-->

## Query Patterns

<!--
  Requêtes fréquentes ou critiques à documenter.
  Exemple :
  - Dashboard : agrégation sur 30j, index sur created_at obligatoire
  - Search : ILIKE sur name, préférer full-text search si > 100k rows
-->
