---
name: legacy-patterns
description: >
  Michael Feathers (Working Effectively with Legacy Code), seams, dependency breaking,
  characterization tests. Auto-loaded by legacy-analyst, archaeologist, characterization-tester,
  refactoring-guide.
---

# Legacy Patterns Reference

Source: Michael Feathers — _Working Effectively with Legacy Code_ (2004)

## Definition

> "Legacy code is code without tests." — Michael Feathers

## Seams

A seam = a place where you can modify behavior without modifying the code.

### Object seam (most common)

```php
// Bad — no seam, direct dependency
class OrderService {
    function process() {
        $mailer = new Mailer();  // impossible to replace in tests
    }
}

// Good — seam via injection
class OrderService {
    function __construct($mailer) {
        $this->mailer = $mailer;  // replaceable by a fake
    }
}
```

### Parameter seam (simplest to create)

```php
// Before: impossible to test
function sendWelcomeEmail($userId) {
    $user = DB::find($userId);
    mail($user->email, 'Welcome', '...');
}

// After: seam via optional parameter
function sendWelcomeEmail($userId, $db = null, $mailer = null) {
    $db = $db ?? DB::getInstance();
    $mailer = $mailer ?? new Mailer();
    $user = $db->find($userId);
    $mailer->send($user->email, 'Welcome', '...');
}
```

## Dependency Breaking

### Extract and Override

```php
// Extract the dependency into an overridable method
class ReportGenerator {
    function generate() {
        $data = $this->fetchData();  // overridable
    }
    protected function fetchData() {
        return DB::query("SELECT ...");
    }
}

// In tests: subclass with fixed data
class TestableReportGenerator extends ReportGenerator {
    protected function fetchData() {
        return [['id' => 1]];
    }
}
```

### Sprout Method (add without touching the existing code)

```php
function processOrder($orderId) {
    // 200 legacy lines — DO NOT TOUCH
    // ...
    $this->applyDiscount($order);  // new, developed with TDD
    // legacy continues...
}
```

### Wrap Method

```php
function save($data) {
    $this->logBefore($data);      // new
    $this->originalSave($data);   // original extracted code
    $this->logAfter($data);       // new
}
```

## Characterization Tests

```
1. Write a test with an intentionally wrong assertion
2. Run it → note what the code ACTUALLY returns
3. Update the test with the real value
4. Comment: "actual behavior documented on [date]"
5. This test becomes the safety net before any change
```

## Algorithm: Touching Legacy Code

```
1. Identify the change
2. Find the available seams
3. Write characterization tests
4. Verify they pass (baseline)
5. Change in micro-increments
6. Verify after each increment
7. If a test is red → immediate git revert
```

## Warning Signals

| Signal                          | Problem                    |
| ------------------------------- | -------------------------- |
| Function > 200 lines            | God function               |
| `global $var` everywhere        | Uncontrollable state       |
| `new Class()` inside a method   | Direct dependency, no seam |
| `$_SESSION` accessed everywhere | Magic global state         |
| `// HACK 2018` comments         | Known unpaid debt          |
