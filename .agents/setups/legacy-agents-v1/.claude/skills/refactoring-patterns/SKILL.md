---
name: refactoring-patterns
description: >
  Martin Fowler catalogue, safe refactorings, order of operations. Auto-loaded by refactoring-guide,
  dev-senior-a/b. Invoke for any refactoring on legacy or new code.
---

# Refactoring Patterns Reference

Source: Martin Fowler — _Refactoring_ (2nd edition, 2018)

## Fundamental Rule

A refactoring does not change observable behavior. If behavior changes → it's a bug or a feature,
not a refactoring.

## Catalogue of Common Refactorings

### Extract Function / Method

When: a block of code needs a comment to be understood.

```javascript
// Bad — before
function printOwing(invoice) {
  let outstanding = 0;
  // calculate outstanding
  for (const o of invoice.orders) {
    outstanding += o.amount;
  }
  // print details
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}

// Good — after
function printOwing(invoice) {
  const outstanding = calculateOutstanding(invoice);
  printDetails(invoice, outstanding);
}
function calculateOutstanding(invoice) {
  return invoice.orders.reduce((sum, o) => sum + o.amount, 0);
}
function printDetails(invoice, outstanding) {
  console.log(`name: ${invoice.customer}`);
  console.log(`amount: ${outstanding}`);
}
```

### Inline Function

When: the body of a function is as clear as its name.

```javascript
// Bad — useless indirection
function moreThanFiveLateDeliveries(driver) {
  return driver.numberOfLateDeliveries > 5;
}
// Good — inline directly
if (driver.numberOfLateDeliveries > 5) { ... }
```

### Extract Variable

When: a complex expression needs a name.

```javascript
// Bad
return (
  order.quantity * order.itemPrice -
  Math.max(0, order.quantity - 500) * order.itemPrice * 0.05 +
  Math.min(order.quantity * order.itemPrice * 0.1, 100)
);

// Good
const basePrice = order.quantity * order.itemPrice;
const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.05;
const shipping = Math.min(basePrice * 0.1, 100);
return basePrice - quantityDiscount + shipping;
```

### Move Function

When: a function uses another class's data more than its own.

```javascript
// Bad — AccountType.isPremium() uses Account data
class Account {
  get overdraftCharge() {
    if (this.type.isPremium) { ... }  // AccountType decides
  }
}

// Good — move overdraftCharge into AccountType
class AccountType {
  overdraftCharge(account) { ... }  // logic where it belongs
}
```

### Replace Conditional with Polymorphism

When: a switch/if-else on a type does the same thing everywhere.

```javascript
// Bad — switch on type everywhere
switch (bird.type) {
  case 'EuropeanSwallow':
    return 35;
  case 'AfricanSwallow':
    return 40 - 2 * bird.numberOfCoconuts;
}

// Good — polymorphism
class EuropeanSwallow {
  get speed() {
    return 35;
  }
}
class AfricanSwallow {
  get speed() {
    return 40 - 2 * this.numberOfCoconuts;
  }
}
```

### Introduce Parameter Object

When: several parameters are always passed together.

```javascript
// Bad
function amountInvoiced(startDate, endDate) { ... }
function amountReceived(startDate, endDate) { ... }

// Good
function amountInvoiced(dateRange) { ... }
function amountReceived(dateRange) { ... }
```

### Replace Magic Literal

When: a literal value has no meaning without context.

```javascript
// Bad
if (status === 3) { ... }

// Good
const STATUS_SHIPPED = 3;
if (status === STATUS_SHIPPED) { ... }
```

## Refactoring Order (safest to riskiest)

```
1. Rename                    → IDE handles it, atomic
2. Extract variable          → no side effects
3. Extract function          → no side effects
4. Inline function/variable  → inverse of the above
5. Move function             → watch the callers
6. Extract class             → check all dependencies
7. Change signature          → riskiest — check ALL callers
```

## Checklist Before Refactoring

```
[ ] Tests in place (characterization or TDD)
[ ] All tests pass (green baseline)
[ ] Scope defined (what to change, what not)
[ ] IDE with automatic refactoring support if possible
[ ] Commit before starting (easy rollback)
```

## Micro-Increments on Legacy

```
Rule: each step must be committable in isolation.
If a step takes > 30 min → too big → split it.
If a test breaks → immediate git revert, no debug.
Restart with a smaller step.
```
