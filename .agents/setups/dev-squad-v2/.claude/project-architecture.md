# Project Architecture

<!-- last-verified: YYYY-MM-DD -->

## SUMMARY (fill in — loaded by all agents)

[Application]: [description en 1 ligne] [Domaine]: [domaine métier principal] [Stack]: TypeScript /
Node.js / React [Auth]: [JWT | sessions | OAuth] [Invariant principal]: [règle métier la plus
importante du système] [Point d'attention]: [ce qu'il faut savoir avant de toucher au code]

---

## Architecture

### Couches

```
src/
├── domain/        # Entités, Value Objects, Events, Erreurs domaine
├── application/   # Use Cases, Ports (interfaces)
├── infrastructure/ # Adapters (Prisma, SMTP, S3, etc.)
└── presentation/  # Controllers HTTP, DTOs, Middlewares
```

### Bounded Contexts

<!-- Lister les contextes métier si applicable -->

### API Contracts

<!-- Routes principales et leurs use cases associés -->

### Architecture Rules

1. domain/ ne dépend de rien d'externe
2. application/ ne dépend que de domain/
3. Les use cases reçoivent leurs dépendances en injection
4. Les composants React délèguent la logique aux hooks/use cases
5. Pas de logique métier dans les controllers

---

## Modules / Features

| Module   | Responsabilité   | Statut                       |
| -------- | ---------------- | ---------------------------- |
| [module] | [responsabilité] | [stable / en cours / legacy] |
