# Common TypeScript Bugs to Catch in Review

## 1. Null / Undefined not handled

```typescript
// ❌ BLOCKER — access without a check
const user = await repo.findById(id);
console.log(user.email); // TypeError if user is null

// ✅ Explicit check
const user = await repo.findById(id);
if (!user) throw new UserNotFoundError(id);
console.log(user.email); // TS knows user is User, not null

// ❌ Non-null assertion without reason — hides bugs
const user = await repo.findById(id);
console.log(user!.email); // silent crash if null

// ✅ Optional chaining for conditional access
const email = user?.email ?? 'anonymous';
```

## 2. Unawaited promises

```typescript
// ❌ BLOCKER — silent fire and forget
emailService.sendWelcomeEmail(user.email); // error lost
repo.save(user); // not guaranteed to be saved before the response

// ✅ Always await promises
await emailService.sendWelcomeEmail(user.email);
await repo.save(user);

// ✅ If intentionally fire-and-forget, name it clearly and handle the error
void emailService
  .sendWelcomeEmail(user.email)
  .catch((err) => logger.error('Failed to send welcome email', { err, userId: user.id }));
```

## 3. Implicit or explicit any

```typescript
// ❌ any loses all TypeScript safety
function processPayload(data: any): any {
  return data.items.map((x: any) => x.value);
}

// ❌ JSON.parse returns any — must be typed explicitly
const config = JSON.parse(rawConfig); // implicit any
config.database.host; // no check, possible crash

// ✅ Zod to parse and type
const ConfigSchema = z.object({
  database: z.object({ host: z.string(), port: z.number() }),
});
const config = ConfigSchema.parse(JSON.parse(rawConfig));
// config.database.host is string — TypeScript verified

// ✅ unknown + type guard when JSON.parse is necessary
const parsed: unknown = JSON.parse(rawConfig);
if (!isConfig(parsed)) throw new Error('Invalid config');
config.database.host; // TS verified after the type guard
```

## 4. Unexpected mutations

```typescript
// ❌ SHOULD — mutating arguments
function addItemToOrder(order: Order, item: CartItem): void {
  order.items.push(item); // mutates the received object — surprising
}

// ✅ Return a new object
function addItemToOrder(order: Order, item: CartItem): Order {
  return { ...order, items: [...order.items, item] };
}

// ❌ forEach that mutates an external array
const results: Result[] = [];
items.forEach((item) => results.push(process(item))); // mutates results

// ✅ map to transform
const results = items.map((item) => process(item));
```

## 5. Switch without default / exhaustive check

```typescript
// ❌ SHOULD — new status added → silent behaviour
function getStatusLabel(status: OrderStatus): string {
  switch (status) {
    case OrderStatus.PENDING:
      return 'Pending';
    case OrderStatus.CONFIRMED:
      return 'Confirmed';
    case OrderStatus.SHIPPED:
      return 'Shipped';
    // Missing: DELIVERED, CANCELLED → silently returns undefined
  }
}

// ✅ Exhaustive check — TypeScript error if a case is missing
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}

function getStatusLabel(status: OrderStatus): string {
  switch (status) {
    case OrderStatus.PENDING:
      return 'Pending';
    case OrderStatus.CONFIRMED:
      return 'Confirmed';
    case OrderStatus.SHIPPED:
      return 'Shipped';
    case OrderStatus.DELIVERED:
      return 'Delivered';
    case OrderStatus.CANCELLED:
      return 'Cancelled';
    default:
      return assertNever(status); // TS error if a case is missing
  }
}
```

## 6. Errors in Promise.all

```typescript
// ❌ If one promise fails, the others keep going but the result is lost
const [users, orders] = await Promise.all([userRepo.findAll(), orderRepo.findAll()]);
// If orderRepo.findAll() throws → users is discarded

// ✅ allSettled when you want both results even if one fails
const [usersResult, ordersResult] = await Promise.allSettled([
  userRepo.findAll(),
  orderRepo.findAll(),
]);
if (usersResult.status === 'rejected') logger.error('Failed to fetch users');
const users = usersResult.status === 'fulfilled' ? usersResult.value : [];
```

## 7. Closures and Loops

```typescript
// ❌ SHOULD — var inside a loop
for (var i = 0; i < handlers.length; i++) {
  setTimeout(() => console.log(i), 100);
  // Prints the same value handlers.length times (classic bug)
}

// ✅ let or const
for (const handler of handlers) {
  setTimeout(() => handler.process(), 100); // correct capture
}

// ✅ With index when needed
handlers.forEach((handler, index) => {
  setTimeout(() => console.log(index, handler), 100);
});
```

## 8. Reference vs Value Comparison

```typescript
// ❌ Comparing Value Objects by reference
const email1 = Email.create('user@test.com')
const email2 = Email.create('user@test.com')
if (email1 === email2) { ... } // false — different objects

// ✅ Use equals()
if (email1.equals(email2)) { ... } // true — same value

// ❌ Comparing Date by reference
const date1 = new Date('2024-01-01')
const date2 = new Date('2024-01-01')
date1 === date2 // false!

// ✅ Compare the timestamps
date1.getTime() === date2.getTime() // true
```
