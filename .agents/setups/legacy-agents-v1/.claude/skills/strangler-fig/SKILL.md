---
name: strangler-fig
description: >
  Strangler Fig pattern, Anti-Corruption Layer, progressive migration from legacy to new code.
  Auto-loaded by architect. Invoke for any decision on how to introduce new code around the legacy.
---

# Strangler Fig Pattern Reference

Source: Martin Fowler — _StranglerFigApplication_ (2004). Name: the strangler fig grows around a
host tree and eventually replaces it entirely — without ever cutting it all at once.

## Principle

```
Never rewrite from scratch (big-bang rewrite = disaster).
Wrap the legacy progressively with new code.
Redirect traffic progressively to the new code.
Remove the legacy once fully replaced.
```

## The 3 Phases

### Phase 1 — Coexistence

```
Legacy runs normally.
New code developed in parallel (strict TDD).
New code not yet called in production.
Feature flag to enable on a % of traffic.
```

### Phase 2 — Progressive Redirection

```
Feature flag: 1% → 10% → 50% → 100%
Monitoring: compare legacy vs new code results
If divergence: fix the new code, not the legacy
Rollback available at any time (lower the %)
```

### Phase 3 — Legacy Removal

```
New code at 100% for N days without incident
Remove the feature flag
Remove the legacy code
Remove the legacy characterization tests (optional)
```

## Anti-Corruption Layer (ACL)

The ACL translates between the legacy world and the new world. It protects the new code from legacy
concepts and structures.

```javascript
// Legacy world: UserRecord (raw DB object from the 2010s)
// New world: User (clean domain object)

class UserAntiCorruptionLayer {
  // Translate legacy → new
  fromLegacy(userRecord) {
    return {
      id: userRecord.user_id, // rename
      email: userRecord.email_addr, // rename
      fullName: `${userRecord.fname} ${userRecord.lname}`, // transform
      isActive: userRecord.status === 1, // type conversion
      createdAt: new Date(userRecord.created_ts * 1000), // date conversion
    };
  }

  // Translate new → legacy (for writing)
  toLegacy(user) {
    return {
      user_id: user.id,
      email_addr: user.email,
      // ...
    };
  }
}
```

## Redirection Patterns

### HTTP Level (cleanest)

```nginx
# Nginx: route according to feature flag (via header or cookie)
location /api/orders {
    if ($http_x_new_orders = "1") {
        proxy_pass http://new-service;
    }
    proxy_pass http://legacy-app;
}
```

### Application Level (feature flag)

```javascript
function processOrder(order) {
  if (featureFlags.isEnabled('new-order-processing', order.userId)) {
    return newOrderService.process(order); // new code
  }
  return legacyOrderProcessor(order); // old code
}
```

### Database Level (strangler on schema)

```
Step 1: New code reads from the old schema via ACL
Step 2: New code writes to both (dual write)
Step 3: Verify data consistency
Step 4: New code reads from the new schema
Step 5: Remove writes to the old schema
```

## Strangler Fig Checklist

```
[ ] Boundary clearly defined (what enters the new world)
[ ] ACL written and tested
[ ] Feature flag in place
[ ] Comparative monitoring configured
[ ] Rollback tested (lowering the % works)
[ ] New code developed in TDD
[ ] Characterization tests on the reference legacy behavior
```

## Mistakes to Avoid

```
Bad — rewrite and migrate at the same time (two simultaneous risks)
Bad — big-bang switch (all or nothing)
Bad — modify the legacy during the migration
Bad — strangler without comparative monitoring
Bad — remove the legacy before being at 100% for several days
```
