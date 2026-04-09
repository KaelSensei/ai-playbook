# Project Architecture

<!-- last-verified: YYYY-MM-DD -->
<!--
  STALENESS RULE : si aujourd'hui - last-verified > 30 jours → STALE.
  Ne pas raisonner depuis un doc stale — explorer le codebase directement.
-->

## System Overview

<!--
  Que fait cette application, qui l'utilise, quelle valeur elle apporte.
  1-2 paragraphes max.
-->

## Architecture Diagram

<!--
  Describe les composants et leurs connexions.
  Exemple :

  Browser / Mobile
      │ HTTP/WS
  Frontend (Next.js)
      │ REST / GraphQL
  API (NestJS / FastAPI)
      │ ORM
  Database (PostgreSQL)
      │
  Background Jobs (Bull / Celery)
      │
  Cache (Redis)
-->

## Module Map

<!--
  Liste des modules/packages principaux et leur responsabilité.
  Exemple :
  src/
  ├── auth/          — authentification, sessions, tokens
  ├── users/         — gestion des comptes utilisateurs
  ├── billing/       — abonnements, paiements (Stripe)
  └── notifications/ — emails, push, webhooks
-->

## API Contracts

<!--
  Les interfaces publiques entre couches (pas l'implémentation).
  Exemple :
  - Frontend → API : REST JSON, versioning via /api/v1/
  - API → DB : Prisma ORM, toujours via repository layer
  - API → Jobs : BullMQ queues, pas d'appel direct
-->

## Authentication / Authorization

<!--
  Comment l'auth fonctionne. Qui peut faire quoi.
  Exemple :
  - JWT stateless, 15min access token, 7j refresh token
  - Rôles : ADMIN, USER, READONLY
  - Toutes les routes /api/** protégées sauf /auth/**
-->

## External Dependencies

<!--
  Service | Rôle | Failure mode
  Stripe  | Paiements | dégradé : bloquer nouveaux abonnements, garder actifs
  SendGrid | Emails | dégradé : queue les emails, retry 3x
  Cloudinary | Media | dégradé : upload bloqué, existants accessibles
-->

## Key Invariants

<!--
  Ce qui doit TOUJOURS être vrai.
  Exemple :
  - Un user ne peut pas avoir deux abonnements actifs simultanément
  - Les données supprimées sont soft-deleted, jamais hard-deleted
  - Toute action d'un admin est loggée dans audit_log
-->

## Known Limitations / Out of Scope

<!--
  Ce que le système ne gère pas intentionnellement.
  Limite le scope creep pendant l'implémentation.
-->
