---
name: clean-code
description: >
  Principes SOLID, clean code, design patterns, nommage, couplage, cohésion. Auto-chargé par
  tech-lead, architect, dev-senior-a/b. Invoke directement pour toute question de design OOP,
  refactoring, ou choix de pattern.
---

# Clean Code Reference

## SOLID

### S — Single Responsibility

Une classe/fonction = une raison de changer.

```typescript
// ❌ fait trop de choses
class UserService {
  createUser(data) {
    /* validation + save + email + log */
  }
}
// ✅ responsabilités séparées
class UserService {
  createUser(dto) {
    /* orchestrate */
  }
}
class UserValidator {
  validate(dto) {
    /* validation only */
  }
}
class UserRepository {
  save(user) {
    /* persistence only */
  }
}
class EmailService {
  sendWelcome(user) {
    /* email only */
  }
}
```

### O — Open/Closed

Ouvert à l'extension, fermé à la modification.

```typescript
// ❌ modifier la classe pour chaque nouveau type
class PaymentProcessor {
  process(type: string) {
    if (type === 'stripe') { ... }
    if (type === 'paypal') { ... } // modifier à chaque nouveau provider
  }
}
// ✅ étendre sans modifier
interface PaymentProvider { charge(amount: number): Promise<void> }
class StripeProvider implements PaymentProvider { ... }
class PayPalProvider implements PaymentProvider { ... }
class PaymentProcessor { process(provider: PaymentProvider) { ... } }
```

### L — Liskov Substitution

Un sous-type peut remplacer son parent sans casser le programme.

### I — Interface Segregation

Préférer plusieurs interfaces spécifiques à une interface générale.

```typescript
// ❌ oblige à implémenter des méthodes non nécessaires
interface Repository {
  findAll();
  findById();
  save();
  delete();
  bulkImport();
}
// ✅
interface Reader {
  findAll();
  findById();
}
interface Writer {
  save();
  delete();
}
```

### D — Dependency Inversion

Dépendre des abstractions, pas des implémentations.

```typescript
// ❌ couplage fort à l'implémentation
class OrderService {
  private db = new PostgresDB();
}
// ✅ injection de dépendance
class OrderService {
  constructor(private db: DatabasePort) {}
}
```

## Nommage

```typescript
// Variables : nom + contexte
❌ const d = new Date()
✅ const createdAt = new Date()

// Fonctions : verbe + objet
❌ function user(id) {}
✅ function getUserById(id: string): Promise<User> {}

// Booléens : is/has/can
❌ const active = user.subscription !== null
✅ const hasActiveSubscription = user.subscription !== null

// Classes : nom (pas de Manager, Handler, Processor génériques)
❌ class UserManager {}
✅ class UserRegistration {}
```

## Fonctions

```typescript
// Max 3 paramètres → au-delà, utiliser un objet
❌ function createUser(name, email, password, role, plan) {}
✅ function createUser(dto: CreateUserDto) {}

// Pas d'effets de bord cachés
❌ function getUser(id) { logAccess(id); return user; } // side effect surprenant
✅ function getUser(id) { return user; } // logAccess appelé séparément

// Retour anticipé plutôt que else imbriqués
❌ if (user) { if (user.active) { if (user.plan) { ... } } }
✅ if (!user) return null
   if (!user.active) return null
   if (!user.plan) return null
   // happy path ici
```

## Anti-Patterns à Éviter

| Anti-pattern             | Problème                                        | Alternative                           |
| ------------------------ | ----------------------------------------------- | ------------------------------------- |
| God Class                | Une classe fait tout                            | Découper en responsabilités           |
| Magic Numbers            | `if (status === 3)`                             | `if (status === OrderStatus.SHIPPED)` |
| Shotgun Surgery          | Un changement = 10 fichiers                     | Regrouper la logique liée             |
| Feature Envy             | Classe qui utilise plus les données d'une autre | Déplacer la méthode                   |
| Primitive Obsession      | `string` pour email, phone, etc.                | Value Objects                         |
| Long Method              | > 20 lignes                                     | Extraire des fonctions nommées        |
| Comments instead of code | `// check if user is premium`                   | `if (user.isPremium())`               |

## Règle des Scouts

Laisser le code un peu plus propre qu'on l'a trouvé. Pas de refactoring complet non demandé — juste
un petit nettoyage en passant.
