---
name: refactoring-patterns
description: >
  Catalogue Martin Fowler, refactorings sécurisés, ordre des opérations. Auto-chargé par
  refactoring-guide, dev-senior-a/b. Invoke pour tout refactoring sur code legacy ou nouveau.
---

# Refactoring Patterns Reference

Source : Martin Fowler — _Refactoring_ (2e édition, 2018)

## Règle Fondamentale

Un refactoring ne change pas le comportement observable. Si le comportement change → c'est un bug ou
une feature, pas un refactoring.

## Catalogue des Refactorings Courants

### Extract Function / Method

Quand : un bloc de code a besoin d'un commentaire pour être compris.

```javascript
// ❌ Avant
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

// ✅ Après
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

Quand : le corps d'une fonction est aussi clair que son nom.

```javascript
// ❌ Indirection inutile
function moreThanFiveLateDeliveries(driver) {
  return driver.numberOfLateDeliveries > 5;
}
// ✅ Inline directement
if (driver.numberOfLateDeliveries > 5) { ... }
```

### Extract Variable

Quand : une expression complexe a besoin d'un nom.

```javascript
// ❌
return (
  order.quantity * order.itemPrice -
  Math.max(0, order.quantity - 500) * order.itemPrice * 0.05 +
  Math.min(order.quantity * order.itemPrice * 0.1, 100)
);

// ✅
const basePrice = order.quantity * order.itemPrice;
const quantityDiscount = Math.max(0, order.quantity - 500) * order.itemPrice * 0.05;
const shipping = Math.min(basePrice * 0.1, 100);
return basePrice - quantityDiscount + shipping;
```

### Move Function

Quand : une fonction utilise plus les données d'une autre classe que les siennes.

```javascript
// ❌ AccountType.isPremium() utilise Account data
class Account {
  get overdraftCharge() {
    if (this.type.isPremium) { ... }  // AccountType décide
  }
}

// ✅ Déplacer overdraftCharge dans AccountType
class AccountType {
  overdraftCharge(account) { ... }  // logique là où elle appartient
}
```

### Replace Conditional with Polymorphism

Quand : un switch/if-else sur un type fait la même chose partout.

```javascript
// ❌ switch sur type partout
switch (bird.type) {
  case 'EuropeanSwallow':
    return 35;
  case 'AfricanSwallow':
    return 40 - 2 * bird.numberOfCoconuts;
}

// ✅ Polymorphisme
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

Quand : plusieurs paramètres sont toujours passés ensemble.

```javascript
// ❌
function amountInvoiced(startDate, endDate) { ... }
function amountReceived(startDate, endDate) { ... }

// ✅
function amountInvoiced(dateRange) { ... }
function amountReceived(dateRange) { ... }
```

### Replace Magic Literal

Quand : une valeur littérale n'a pas de sens sans contexte.

```javascript
// ❌
if (status === 3) { ... }

// ✅
const STATUS_SHIPPED = 3;
if (status === STATUS_SHIPPED) { ... }
```

## Ordre des Refactorings (du plus sûr au plus risqué)

```
1. Renommage                 → IDE le gère, atomique
2. Extract variable          → sans effet de bord
3. Extract function          → sans effet de bord
4. Inline function/variable  → inverse des précédents
5. Move function             → attention aux appelants
6. Extract class             → vérifier toutes les dépendances
7. Changer signature         → le plus risqué — vérifier TOUS les appelants
```

## Checklist Avant Refactoring

```
[ ] Tests en place (caractérisation ou TDD)
[ ] Tous les tests passent (baseline verte)
[ ] Périmètre défini (quoi changer, quoi pas)
[ ] IDE avec support refactoring automatique si possible
[ ] Commit avant de commencer (rollback facile)
```

## Micro-Incréments sur Legacy

```
Règle : chaque étape doit être committable en isolation.
Si une étape prend > 30 min → trop grande → découper.
Si un test casse → git revert immédiat, pas de debug.
Recommencer avec une étape plus petite.
```
