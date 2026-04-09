---
name: api-design
description: >
  REST API design, conventions, versioning, contrats d'erreurs, pagination, validation. Auto-chargé
  par architect, dev-senior-a/b. Invoke pour toute question de design d'endpoint, format de réponse,
  gestion d'erreurs ou conventions REST.
---

# API Design Reference

## Conventions REST

### URLs

```
# Ressources en plural, noms pas verbes
✅ GET    /api/v1/users
✅ GET    /api/v1/users/:id
✅ POST   /api/v1/users
✅ PATCH  /api/v1/users/:id    (modification partielle)
✅ PUT    /api/v1/users/:id    (remplacement complet)
✅ DELETE /api/v1/users/:id

# Relations imbriquées (max 2 niveaux)
✅ GET    /api/v1/users/:id/posts
✅ POST   /api/v1/users/:id/posts
❌ GET    /api/v1/users/:id/posts/:postId/comments/:commentId  (trop profond)

# Actions non-CRUD → sous-ressource ou verbe dans l'URL
✅ POST   /api/v1/users/:id/activate
✅ POST   /api/v1/auth/refresh
✅ POST   /api/v1/orders/:id/cancel
```

### Status Codes

```
200 OK           — GET/PATCH/PUT succès avec body
201 Created      — POST succès, retourner la ressource créée
204 No Content   — DELETE succès, ou action sans body de retour
400 Bad Request  — validation échouée, input invalide
401 Unauthorized — non authentifié (token manquant ou invalide)
403 Forbidden    — authentifié mais pas autorisé
404 Not Found    — ressource inexistante
409 Conflict     — conflit (email déjà utilisé, état incompatible)
422 Unprocessable — entité compréhensible mais logiquement invalide
429 Too Many Requests — rate limit atteint
500 Internal Server Error — erreur interne (jamais de détails en prod)
```

## Format de Réponse

### Succès

```json
// Liste avec pagination
{
  "data": [...],
  "meta": {
    "total": 150,
    "page": 1,
    "perPage": 20,
    "totalPages": 8
  }
}

// Item unique
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### Erreurs (format uniforme)

```json
// Erreur simple
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with id 'xyz' not found"
  }
}

// Erreurs de validation (multiples champs)
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Must be a valid email address" },
      { "field": "password", "message": "Must be at least 8 characters" }
    ]
  }
}
```

### Codes d'erreur métier (snake_case majuscule)

```typescript
// Centralisés dans un enum
enum ErrorCode {
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  EMAIL_TAKEN = 'EMAIL_TAKEN',
  INVALID_TOKEN = 'INVALID_TOKEN',
  PLAN_REQUIRED = 'PLAN_REQUIRED',
  RATE_LIMIT = 'RATE_LIMIT',
}
```

## Versioning

```
/api/v1/...   — version dans l'URL (simple, explicite)

Règle : v2 quand on fait un breaking change.
Un breaking change = supprimer/renommer un champ, changer un type,
supprimer un endpoint, changer la sémantique d'un paramètre.
```

## Pagination

```typescript
// Cursor-based (recommandé pour grands datasets)
GET /api/v1/posts?cursor=eyJpZCI6MTAwfQ&limit=20
{
  "data": [...],
  "meta": {
    "nextCursor": "eyJpZCI6MTIwfQ",
    "hasMore": true
  }
}

// Offset-based (simple, pour datasets <= 10k)
GET /api/v1/posts?page=2&perPage=20
```

## Validation Inputs

```typescript
// Toujours valider côté serveur, même si validé côté client
// Utiliser un schema de validation (Zod, Joi, class-validator)

const createUserSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(8).max(100).regex(/[A-Z]/).regex(/[0-9]/),
  role: z.enum(['USER', 'ADMIN']).default('USER'),
});

// Retourner 400 avec détails si validation échoue
// Jamais passer des données non validées à la couche service
```

## Sécurité API

```
- Authentification : JWT Bearer token dans Authorization header
- Authorization : vérifier les permissions au niveau service, pas juste controller
- CORS : whitelist explicite des origines autorisées
- Rate limiting : sur les endpoints sensibles minimum (cf. constants.md)
- Sanitization : ne jamais retourner le password hash, les tokens internes
- Idempotency key : sur les opérations critiques (paiement, envoi d'email)
```
