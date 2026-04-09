# Performance Review — TypeScript / Node.js

## N+1 Problems — The Most Common

```typescript
// ❌ [BLOCKER] N+1 : une query par item dans la boucle
async function getUsersWithOrders(): Promise<UserWithOrders[]> {
  const users = await userRepo.findAll(); // 1 query
  return Promise.all(
    users.map(async (user) => ({
      ...user,
      orders: await orderRepo.findByUserId(user.id), // N queries !
    }))
  );
}
// Avec 1000 users → 1001 queries. Timeout garanti en production.

// ✅ Eager loading avec Prisma (1 query)
const users = await prisma.user.findMany({
  include: { orders: true },
});

// ✅ Batch loading si include n'est pas possible (2 queries)
const users = await userRepo.findAll();
const userIds = users.map((u) => u.id);
const orders = await orderRepo.findByUserIds(userIds); // IN clause
const ordersByUser = groupBy(orders, (o) => o.userId);
return users.map((u) => ({ ...u, orders: ordersByUser[u.id] ?? [] }));
```

## Missing Indexes — Silencieusement Catastrophique

```typescript
// ❌ [BLOCKER] Colonne filtrée sans index → full table scan
const user = await prisma.user.findFirst({
  where: { email: input.email }    // email sans index = O(n)
})

// ✅ Prisma schema avec index
model User {
  id        String   @id
  email     String   @unique        // @unique crée automatiquement un index
  role      UserRole
  createdAt DateTime

  @@index([role, createdAt])        // index composite pour filtre + tri
}

// Détecter les queries lentes en review :
// Chercher les findFirst/findMany sur des colonnes non indexées
// Email, slug, code de référence → toujours @unique ou @@index
// Colonnes de filtre fréquent (status, role, userId) → @@index
```

## Pagination — Offset vs Cursor

```typescript
// ❌ [SHOULD] Offset pagination sur large dataset — O(offset) à la DB
const users = await prisma.user.findMany({
  skip: page * pageSize, // page 1000 → DB parcourt 1M de lignes
  take: pageSize,
  orderBy: { createdAt: 'desc' },
});

// ✅ Cursor pagination — O(1) sur les pages suivantes
async function getUsersPage(cursor?: string, pageSize = 20) {
  const users = await prisma.user.findMany({
    take: pageSize + 1, // +1 pour savoir s'il y a une page suivante
    ...(cursor && {
      cursor: { id: cursor },
      skip: 1, // skip le cursor lui-même
    }),
    orderBy: { createdAt: 'desc' },
  });

  const hasNextPage = users.length > pageSize;
  return {
    data: users.slice(0, pageSize),
    nextCursor: hasNextPage ? users[pageSize - 1].id : null,
  };
}
// Exception : offset OK si dataset < 10k lignes et pas de croissance prévue
```

## Parallel vs Sequential Promises

```typescript
// ❌ [SHOULD] Séquentiel quand le parallèle est possible
const user = await userRepo.findById(userId); // attend
const orders = await orderRepo.findByUser(userId); // attend inutilement
const stats = await statsRepo.forUser(userId); // attend inutilement
// Durée totale : t(user) + t(orders) + t(stats)

// ✅ Parallèle avec Promise.all
const [user, orders, stats] = await Promise.all([
  userRepo.findById(userId),
  orderRepo.findByUser(userId),
  statsRepo.forUser(userId),
]);
// Durée totale : max(t(user), t(orders), t(stats))

// ⚠️ Attention : parallèle seulement si les appels sont indépendants
// Si orders dépend de user → séquentiel obligatoire
const user = await userRepo.findById(userId);
const orders = await orderRepo.findByUser(user.preferredAccountId); // dépend de user
```

## Large Objects — Don't Select Everything

```typescript
// ❌ [SHOULD] SELECT * sur une table avec colonnes larges (content, blob, json)
const articles = await prisma.article.findMany();
// Si article a un champ 'content' de 50KB → 20 articles = 1MB en mémoire

// ✅ Sélectionner uniquement ce dont on a besoin pour la liste
const articles = await prisma.article.findMany({
  select: {
    id: true,
    title: true,
    summary: true,
    authorId: true,
    publishedAt: true,
    // content: false  ← pas sélectionné pour la liste
  },
});
// Charger le contenu complet seulement sur la page de détail
```

## Memoization — Repeated Expensive Computations

```typescript
// ❌ Recalculé à chaque render (React) ou à chaque appel (Node)
function ExpensiveList({ items }: { items: Item[] }) {
  const sorted = items
    .filter(i => i.active)
    .sort((a, b) => b.score - a.score)      // recalculé à chaque render
  return <ul>{sorted.map(renderItem)}</ul>
}

// ✅ useMemo pour les calculs coûteux
function ExpensiveList({ items }: { items: Item[] }) {
  const sorted = useMemo(
    () => items.filter(i => i.active).sort((a, b) => b.score - a.score),
    [items]                                 // recalculé seulement si items change
  )
  return <ul>{sorted.map(renderItem)}</ul>
}

// ✅ Cache en mémoire côté Node pour les données stables
const memoizedVatRates = new Map<string, number>()
async function getVatRate(countryCode: string): Promise<number> {
  if (memoizedVatRates.has(countryCode)) return memoizedVatRates.get(countryCode)!
  const rate = await vatRateRepo.findByCountry(countryCode)
  memoizedVatRates.set(countryCode, rate)
  return rate
}
```

## Signals to Look For in Review

```
[BLOCKER] boucle avec await à l'intérieur → suspect N+1
[BLOCKER] findFirst/findMany sur colonne sans @unique ni @@index
[BLOCKER] serialize(object) sans select → toujours vérifier les champs retournés

[SHOULD] skip: page * pageSize sur dataset potentiellement grand
[SHOULD] awaits séquentiels sur opérations indépendantes
[SHOULD] calcul réutilisé dans une boucle sans cache
[SHOULD] response body non paginé sur une collection (manque ?page=)
```
