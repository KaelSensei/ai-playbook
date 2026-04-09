---
name: code-review-standards
description: >
  Standards de code review async pour TypeScript. Checklist par couche, exemples de bons et mauvais
  commentaires, critique constructive. Loaded by dev-senior-b et tech-lead.
---

# Code Review Standards — TypeScript

---

## Review Philosophy

La review a deux objectifs distincts — ne pas les mélanger :

1. **Trouver les bugs** — comportements incorrects, cas non gérés, sécurité
2. **Améliorer la qualité** — lisibilité, maintenabilité, architecture

L'objectif n'est pas de prouver que le code est mauvais. L'objectif est d'améliorer le produit
collectivement.

---

## How to Comment — The Difference Matters

### ❌ Commentaires destructifs ou vagues

```
"Ce code est illisible"
"Mauvaise approche"
"Pourquoi tu fais ça ?"
"Ça ne marche pas"
```

### ✅ Commentaires constructifs avec exemple

```
// Pour un bug
"Ce cas n'est pas géré : si user est null ici,
 on aura un TypeError ligne 47.
 Suggestion : early return avec une vérification ou Optional chaining."

// Pour une amélioration de lisibilité
"Cette fonction fait deux choses : valider et transformer.
 Extraire la validation dans validateUserInput() améliorerait
 la lisibilité et la testabilité séparément.
 Que tu penses de l'approche ?"

// Pour un problème d'architecture
"Ce use case dépend directement de PrismaClient ligne 12.
 Ça couplera tous les tests à une vraie base de données.
 Si on injecte un UserRepository (interface), on peut mocker dans les tests.
 Voir le pattern dans src/application/use-cases/RegisterUser.ts."
```

---

## Severity Levels

Toujours préfixer les commentaires avec le niveau :

```
[BLOCKER]      → doit être corrigé avant merge. Bug, sécurité, violation archi.
[SHOULD]       → devrait être corrigé, pas critique pour cette PR.
[SUGGESTION]   → amélioration possible, pas obligatoire.
[QUESTION]     → besoin de clarification avant de juger.
[PRAISE]       → bonne pratique à noter explicitement.
[NIT]          → détail stylistique mineur.
```

### Examples

```typescript
// [BLOCKER] Injection SQL possible — ne jamais interpoler dans une query
const users = await db.query(`SELECT * FROM users WHERE email = '${email}'`)
// → Utiliser les paramètres Prisma : where: { email }

// [SHOULD] La validation du password devrait être dans le domain
// plutôt que dans le controller — ça duplique la logique métier
if (password.length < 8) { ... }

// [SUGGESTION] `Array.from(map.values()).find()` peut s'écrire
// avec une destructuring : for (const user of map.values())
// mais c'est une question de préférence, pas un problème.

// [QUESTION] Pourquoi on génère un nouveau token même si l'ancien
// est encore valide ? Est-ce intentionnel (security) ou un oubli ?

// [PRAISE] Bon usage des discriminated unions ici — TypeScript
// nous protège contre les états impossibles.

// [NIT] `const x` → `const userId` serait plus expressif.
```

---

## Checklist per Layer

### Domain

```
[ ] Value objects : validation dans le constructeur, pas ailleurs
[ ] Entités : invariants enforced (pas d'état invalide possible)
[ ] Méthodes métier : nommées avec le vocabulaire du domaine
[ ] Zéro import de librairies externes (express, prisma, etc.)
[ ] Events émis aux bons moments (dans les méthodes qui changent l'état)
[ ] Erreurs typées (pas de throw new Error('message générique'))
[ ] Tests unitaires sans mocks de services externes (domain pur)
```

### Application (Use Cases)

```
[ ] Une responsabilité par use case (SRP)
[ ] Tous les ports (interfaces) injectés en dépendances
[ ] Validation déléguée au domain (pas de validation ici)
[ ] Pas de logique métier dans le use case (déléguer aux entités)
[ ] Transactions correctement gérées si multi-opérations
[ ] Events publiés après persistance (pas avant)
[ ] Tests avec fakes/stubs, pas de vrais services
```

### Infrastructure

```
[ ] Implémente exactement l'interface du port (ni plus, ni moins)
[ ] Mapping toDomain() et toPersistence() séparés et testés
[ ] Gestion des erreurs Prisma/DB (unique constraint, not found...)
[ ] Pas de logique métier dans les adapters
[ ] Queries N+1 inexistantes (include/eager loading)
[ ] Index présents sur les colonnes de filtre
```

### Presentation (Controllers)

```
[ ] Validation des inputs avec Zod (avant d'appeler le use case)
[ ] Mapping clair input HTTP → use case input
[ ] Mapping clair use case output → réponse HTTP
[ ] Pas de logique métier dans le controller
[ ] Status codes corrects (201/200/204/400/401/403/404/409)
[ ] Erreurs domaine mappées vers erreurs HTTP
[ ] Pas de données sensibles dans les réponses (password hash, tokens)
```

---

## Patterns to Approve vs Reject

### ✅ Approuver

```typescript
// Early return — lisible, évite l'imbrication
async function getUser(id: UserId): Promise<User> {
  const user = await repo.findById(id);
  if (!user) throw new UserNotFoundError(id);
  if (user.isDeleted()) throw new DeletedUserError(id);
  return user;
}

// Nommage expressif avec le vocabulaire métier
const hasExceededMaxAttempts = failedAttempts >= MAX_LOGIN_ATTEMPTS;
const isPremiumSubscriber = user.plan === Plan.PREMIUM;
const isEligibleForDiscount = order.totalHT > DISCOUNT_THRESHOLD;

// Erreurs typées et informatives
throw new InsufficientStockError({
  productId: item.productId,
  requested: item.quantity,
  available: stock.quantity,
});
```

### ❌ Rejeter

```typescript
// [BLOCKER] Callback hell — rendre async/await
getUser(id, (err, user) => {
  if (err) throw err
  getOrders(user.id, (err, orders) => { ... })
})

// [BLOCKER] Catch silencieux — les erreurs disparaissent
try {
  await riskyOperation()
} catch (e) {
  // silent
}

// [BLOCKER] Type any — perd toute la sécurité TypeScript
function processData(data: any): any {
  return data.items.map((x: any) => x.value)
}

// [SHOULD] Promise non gérée — fire and forget risqué
emailService.send(welcomeEmail) // pas de await, erreur perdue

// [SHOULD] Magic numbers
if (password.length < 8) { ... }     // 8 = ?
if (attempts > 5) { ... }             // 5 = ?
// → constantes nommées : MIN_PASSWORD_LENGTH, MAX_LOGIN_ATTEMPTS

// [SHOULD] Commentaire qui répète le code
// Check if user exists
const user = await repo.findById(id)
// → le commentaire n'apporte rien. Si besoin : expliquer le POURQUOI

// [NIT] Boolean flag en paramètre
sendEmail(user, true) // true = ?
// → objet : sendEmail(user, { sendWelcome: true })
```

---

## PR Review — Response Structure

```markdown
## Review de [Nom de la PR]

### Overview

[Ce que j'ai compris de la PR — 2-3 phrases]

### Verdict

APPROVE / APPROVE_WITH_CHANGES / REQUEST_CHANGES

### [BLOCKER] Points bloquants

[Liste numérotée des problèmes critiques]

### [SHOULD] Suggestions

[Liste des points non critiques]

### [PRAISE] Points positifs

[Ce qui est bien fait — toujours inclure au moins un]

### [QUESTION] Questions ouvertes

[Ce que j'ai besoin de comprendre avant de juger]
```

---

## Qui N'Est PAS du Ressort de la Review

```
✗ Le style de code (guillemets simples vs doubles, etc.)
  → géré par ESLint/Prettier — configurer et oublier

✗ Les préférences personnelles sans justification objective
  → "j'aurais fait autrement" sans explication = bruit

✗ Refactorer tout le fichier existant
  → la PR a un scope. Le reste = dette connue = future PR

✗ Des designs complets alternatifs en review
  → ça se discute en amont, pas en PR
```

---

## Available References

- `references/security-review.md` — OWASP, injections, auth, secrets
- `references/performance-review.md` — N+1, indexes, pagination
- `references/common-bugs-ts.md` — bugs TypeScript courants à détecter
