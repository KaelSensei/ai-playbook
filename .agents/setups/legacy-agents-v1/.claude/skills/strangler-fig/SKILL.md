---
name: strangler-fig
description: >
  Strangler Fig pattern, Anti-Corruption Layer, migration progressive legacy vers nouveau code.
  Auto-chargé par architect. Invoke pour toute décision sur comment introduire du nouveau code
  autour du legacy.
---

# Strangler Fig Pattern Reference

Source : Martin Fowler — _StranglerFigApplication_ (2004) Nom : le figuier étrangleur pousse autour
d'un arbre hôte et finit par le remplacer complètement — sans jamais le couper d'un coup.

## Principe

```
Ne jamais réécrire de zéro (big bang rewrite = désastre).
Envelopper progressivement le legacy avec du nouveau code.
Rediriger le trafic progressivement vers le nouveau code.
Supprimer le legacy une fois complètement remplacé.
```

## Les 3 Phases

### Phase 1 — Coexistence

```
Legacy tourne normalement.
Nouveau code développé en parallèle (TDD strict).
Nouveau code pas encore appelé en production.
Feature flag pour activer sur un % de trafic.
```

### Phase 2 — Redirection Progressive

```
Feature flag : 1% → 10% → 50% → 100%
Monitoring : comparer les résultats legacy vs nouveau code
Si divergence : corriger le nouveau code, pas le legacy
Rollback disponible à tout moment (baisser le %)
```

### Phase 3 — Suppression du Legacy

```
Nouveau code à 100% depuis N jours sans incident
Supprimer le feature flag
Supprimer le code legacy
Supprimer les tests de caractérisation legacy (optionnel)
```

## Anti-Corruption Layer (ACL)

L'ACL traduit entre le monde legacy et le nouveau monde. Il protège le nouveau code des concepts et
structures legacy.

```javascript
// Monde legacy : UserRecord (objet BDD brut des années 2010)
// Nouveau monde : User (domain object propre)

class UserAntiCorruptionLayer {
  // Traduit legacy → nouveau
  fromLegacy(userRecord) {
    return {
      id: userRecord.user_id, // renommage
      email: userRecord.email_addr, // renommage
      fullName: `${userRecord.fname} ${userRecord.lname}`, // transformation
      isActive: userRecord.status === 1, // conversion type
      createdAt: new Date(userRecord.created_ts * 1000), // conversion date
    };
  }

  // Traduit nouveau → legacy (pour écrire)
  toLegacy(user) {
    return {
      user_id: user.id,
      email_addr: user.email,
      // ...
    };
  }
}
```

## Patterns de Redirection

### HTTP Level (le plus propre)

```nginx
# Nginx : router selon feature flag (via header ou cookie)
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
    return newOrderService.process(order); // nouveau code
  }
  return legacyOrderProcessor(order); // ancien code
}
```

### Database Level (strangler sur schéma)

```
Étape 1 : Nouveau code lit depuis l'ancien schéma via ACL
Étape 2 : Nouveau code écrit dans les deux (dual write)
Étape 3 : Vérifier la cohérence des données
Étape 4 : Nouveau code lit depuis le nouveau schéma
Étape 5 : Supprimer l'écriture vers l'ancien schéma
```

## Checklist Strangler Fig

```
[ ] Frontière clairement définie (quoi entre dans le nouveau)
[ ] ACL écrit et testé
[ ] Feature flag en place
[ ] Monitoring comparatif configuré
[ ] Rollback testé (baisser le % fonctionne)
[ ] Nouveau code développé en TDD
[ ] Tests de caractérisation sur le comportement legacy de référence
```

## Erreurs à Éviter

```
❌ Réécrire et migrer en même temps (deux risques simultanés)
❌ Big bang switch (tout ou rien)
❌ Modifier le legacy pendant la migration
❌ Strangler sans monitoring comparatif
❌ Supprimer le legacy avant d'être à 100% depuis plusieurs jours
```
