# Performance Review — TypeScript / Node.js

## N+1 Problems — The Most Common

```typescript
// ❌ [BLOCKER] N+1: one query per item in the loop
async function getUsersWithOrders(): Promise<UserWithOrders[]> {
  const users = await userRepo.findAll(); // 1 query
  return Promise.all(
    users.map(async (user) => ({
      ...user,
      orders: await orderRepo.findByUserId(user.id), // N queries!
    }))
  );
}
// With 1000 users → 1001 queries. Guaranteed timeout in production.

// ✅ Eager loading with Prisma (1 query)
const users = await prisma.user.findMany({
  include: { orders: true },
});

// ✅ Batch loading when include is not possible (2 queries)
const users = await userRepo.findAll();
const userIds = users.map((u) => u.id);
const orders = await orderRepo.findByUserIds(userIds); // IN clause
const ordersByUser = groupBy(orders, (o) => o.userId);
return users.map((u) => ({ ...u, orders: ordersByUser[u.id] ?? [] }));
```

## Missing Indexes — Silently Catastrophic

```typescript
// ❌ [BLOCKER] Filtered column without an index → full table scan
const user = await prisma.user.findFirst({
  where: { email: input.email }    // email without index = O(n)
})

// ✅ Prisma schema with index
model User {
  id        String   @id
  email     String   @unique        // @unique automatically creates an index
  role      UserRole
  createdAt DateTime

  @@index([role, createdAt])        // composite index for filter + sort
}

// How to spot slow queries in review:
// Look for findFirst/findMany on non-indexed columns.
// Email, slug, reference code → always @unique or @@index.
// Frequently-filtered columns (status, role, userId) → @@index.
```

## Pagination — Offset vs Cursor

```typescript
// ❌ [SHOULD] Offset pagination on a large dataset — O(offset) at the DB
const users = await prisma.user.findMany({
  skip: page * pageSize, // page 1000 → DB scans 1M rows
  take: pageSize,
  orderBy: { createdAt: 'desc' },
});

// ✅ Cursor pagination — O(1) for subsequent pages
async function getUsersPage(cursor?: string, pageSize = 20) {
  const users = await prisma.user.findMany({
    take: pageSize + 1, // +1 to know if there is a next page
    ...(cursor && {
      cursor: { id: cursor },
      skip: 1, // skip the cursor itself
    }),
    orderBy: { createdAt: 'desc' },
  });

  const hasNextPage = users.length > pageSize;
  return {
    data: users.slice(0, pageSize),
    nextCursor: hasNextPage ? users[pageSize - 1].id : null,
  };
}
// Exception: offset is fine if dataset < 10k rows and no expected growth
```

## Parallel vs Sequential Promises

```typescript
// ❌ [SHOULD] Sequential when parallel is possible
const user = await userRepo.findById(userId); // waits
const orders = await orderRepo.findByUser(userId); // waits unnecessarily
const stats = await statsRepo.forUser(userId); // waits unnecessarily
// Total duration: t(user) + t(orders) + t(stats)

// ✅ Parallel with Promise.all
const [user, orders, stats] = await Promise.all([
  userRepo.findById(userId),
  orderRepo.findByUser(userId),
  statsRepo.forUser(userId),
]);
// Total duration: max(t(user), t(orders), t(stats))

// ⚠️ Warning: parallel only when the calls are independent
// If orders depends on user → sequential is mandatory
const user = await userRepo.findById(userId);
const orders = await orderRepo.findByUser(user.preferredAccountId); // depends on user
```

## Large Objects — Don't Select Everything

```typescript
// ❌ [SHOULD] SELECT * on a table with wide columns (content, blob, json)
const articles = await prisma.article.findMany();
// If article has a 'content' field of 50KB → 20 articles = 1MB in memory

// ✅ Select only what is needed for the list
const articles = await prisma.article.findMany({
  select: {
    id: true,
    title: true,
    summary: true,
    authorId: true,
    publishedAt: true,
    // content: false  ← not selected for the list
  },
});
// Load the full content only on the detail page
```

## Memoization — Repeated Expensive Computations

```typescript
// ❌ Recomputed on every render (React) or every call (Node)
function ExpensiveList({ items }: { items: Item[] }) {
  const sorted = items
    .filter(i => i.active)
    .sort((a, b) => b.score - a.score)      // recomputed on every render
  return <ul>{sorted.map(renderItem)}</ul>
}

// ✅ useMemo for expensive computations
function ExpensiveList({ items }: { items: Item[] }) {
  const sorted = useMemo(
    () => items.filter(i => i.active).sort((a, b) => b.score - a.score),
    [items]                                 // recomputed only when items changes
  )
  return <ul>{sorted.map(renderItem)}</ul>
}

// ✅ In-memory cache on the Node side for stable data
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
[BLOCKER] loop with an await inside → suspected N+1
[BLOCKER] findFirst/findMany on a column without @unique or @@index
[BLOCKER] serialize(object) without select → always check the returned fields

[SHOULD] skip: page * pageSize on a potentially large dataset
[SHOULD] sequential awaits on independent operations
[SHOULD] reused computation inside a loop without caching
[SHOULD] unpaginated response body on a collection (missing ?page=)
```
