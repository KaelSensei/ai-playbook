# Common TypeScript Bugs to Catch in Review

## 1. Null / Undefined not handled

```typescript
// ❌ BLOCKER — accès sans vérification
const user = await repo.findById(id);
console.log(user.email); // TypeError si user est null

// ✅ Vérification explicite
const user = await repo.findById(id);
if (!user) throw new UserNotFoundError(id);
console.log(user.email); // TS sait que user est User, pas null

// ❌ Non-null assertion sans raison — masque les bugs
const user = await repo.findById(id);
console.log(user!.email); // crash silencieux si null

// ✅ Optional chaining pour accès conditionnel
const email = user?.email ?? 'anonymous';
```

## 2. Promesses non await

```typescript
// ❌ BLOCKER — fire and forget silencieux
emailService.sendWelcomeEmail(user.email); // erreur perdue
repo.save(user); // pas certain que c'est sauvé avant la réponse

// ✅ Toujours await les promesses
await emailService.sendWelcomeEmail(user.email);
await repo.save(user);

// ✅ Si intentionnellement fire-and-forget, nommer clairement et gérer l'erreur
void emailService
  .sendWelcomeEmail(user.email)
  .catch((err) => logger.error('Failed to send welcome email', { err, userId: user.id }));
```

## 3. Type any implicite ou explicite

```typescript
// ❌ any perd toute la sécurité TypeScript
function processPayload(data: any): any {
  return data.items.map((x: any) => x.value);
}

// ❌ JSON.parse retourne any — à typer explicitement
const config = JSON.parse(rawConfig); // any implicite
config.database.host; // pas de vérification, crash possible

// ✅ Zod pour parser et typer
const ConfigSchema = z.object({
  database: z.object({ host: z.string(), port: z.number() }),
});
const config = ConfigSchema.parse(JSON.parse(rawConfig));
// config.database.host est string — TypeScript vérifié

// ✅ unknown + type guard quand JSON.parse nécessaire
const parsed: unknown = JSON.parse(rawConfig);
if (!isConfig(parsed)) throw new Error('Invalid config');
config.database.host; // TS vérifié après le type guard
```

## 4. Mutations inattendues

```typescript
// ❌ SHOULD — muter les arguments
function addItemToOrder(order: Order, item: CartItem): void {
  order.items.push(item); // mute l'objet reçu — surprenant
}

// ✅ Retourner un nouvel objet
function addItemToOrder(order: Order, item: CartItem): Order {
  return { ...order, items: [...order.items, item] };
}

// ❌ forEach qui mute un tableau externe
const results: Result[] = [];
items.forEach((item) => results.push(process(item))); // mute results

// ✅ map pour transformer
const results = items.map((item) => process(item));
```

## 5. Switch sans default / exhaustive check

```typescript
// ❌ SHOULD — nouveau statut ajouté → comportement silencieux
function getStatusLabel(status: OrderStatus): string {
  switch (status) {
    case OrderStatus.PENDING:
      return 'En attente';
    case OrderStatus.CONFIRMED:
      return 'Confirmée';
    case OrderStatus.SHIPPED:
      return 'Expédiée';
    // Oubli : DELIVERED, CANCELLED → retourne undefined silencieusement
  }
}

// ✅ Exhaustive check — TypeScript error si cas manquant
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}

function getStatusLabel(status: OrderStatus): string {
  switch (status) {
    case OrderStatus.PENDING:
      return 'En attente';
    case OrderStatus.CONFIRMED:
      return 'Confirmée';
    case OrderStatus.SHIPPED:
      return 'Expédiée';
    case OrderStatus.DELIVERED:
      return 'Livrée';
    case OrderStatus.CANCELLED:
      return 'Annulée';
    default:
      return assertNever(status); // TS error si cas manquant
  }
}
```

## 6. Erreurs dans les Promesses.all

```typescript
// ❌ Si une promesse échoue, les autres continuent mais le résultat est perdu
const [users, orders] = await Promise.all([userRepo.findAll(), orderRepo.findAll()]);
// Si orderRepo.findAll() throw → users est ignoré

// ✅ allSettled quand on veut les deux résultats même si l'un échoue
const [usersResult, ordersResult] = await Promise.allSettled([
  userRepo.findAll(),
  orderRepo.findAll(),
]);
if (usersResult.status === 'rejected') logger.error('Failed to fetch users');
const users = usersResult.status === 'fulfilled' ? usersResult.value : [];
```

## 7. Closures et Boucles

```typescript
// ❌ SHOULD — var dans une boucle
for (var i = 0; i < handlers.length; i++) {
  setTimeout(() => console.log(i), 100);
  // Affiche handlers.length fois la même valeur (bug classique)
}

// ✅ let ou const
for (const handler of handlers) {
  setTimeout(() => handler.process(), 100); // capture correcte
}

// ✅ Avec index si nécessaire
handlers.forEach((handler, index) => {
  setTimeout(() => console.log(index, handler), 100);
});
```

## 8. Reference vs Value Comparison

```typescript
// ❌ Comparaison de Value Objects par référence
const email1 = Email.create('user@test.com')
const email2 = Email.create('user@test.com')
if (email1 === email2) { ... } // false — objets différents

// ✅ Utiliser equals()
if (email1.equals(email2)) { ... } // true — même valeur

// ❌ Comparaison de Date par référence
const date1 = new Date('2024-01-01')
const date2 = new Date('2024-01-01')
date1 === date2 // false!

// ✅ Comparer les timestamps
date1.getTime() === date2.getTime() // true
```
