---
name: legacy-patterns
description: >
  Michael Feathers (Working Effectively with Legacy Code), seams, dependency breaking,
  characterization tests. Auto-chargé par legacy-analyst, archaeologist, characterization-tester,
  refactoring-guide.
---

# Legacy Patterns Reference

Source : Michael Feathers — _Working Effectively with Legacy Code_ (2004)

## Définition

> "Legacy code is code without tests." — Michael Feathers

## Seams

Un seam = endroit où on peut modifier le comportement sans modifier le code.

### Seam d'objet (le plus courant)

```php
// ❌ Pas de seam — dépendance directe
class OrderService {
    function process() {
        $mailer = new Mailer();  // impossible à remplacer en test
    }
}

// ✅ Seam via injection
class OrderService {
    function __construct($mailer) {
        $this->mailer = $mailer;  // remplaçable par un fake
    }
}
```

### Seam de paramètre (le plus simple à créer)

```php
// Avant : impossible à tester
function sendWelcomeEmail($userId) {
    $user = DB::find($userId);
    mail($user->email, 'Welcome', '...');
}

// Après : seam via paramètre optionnel
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
// Extraire la dépendance dans une méthode overridable
class ReportGenerator {
    function generate() {
        $data = $this->fetchData();  // overridable
    }
    protected function fetchData() {
        return DB::query("SELECT ...");
    }
}

// En test : sous-classe avec données figées
class TestableReportGenerator extends ReportGenerator {
    protected function fetchData() {
        return [['id' => 1]];
    }
}
```

### Sprout Method (ajouter sans toucher l'existant)

```php
function processOrder($orderId) {
    // 200 lignes legacy — NE PAS TOUCHER
    // ...
    $this->applyDiscount($order);  // ← nouveau, développé en TDD
    // suite legacy...
}
```

### Wrap Method

```php
function save($data) {
    $this->logBefore($data);      // nouveau
    $this->originalSave($data);   // code extrait original
    $this->logAfter($data);       // nouveau
}
```

## Tests de Caractérisation

```
1. Écrire un test avec assertion intentionnellement fausse
2. Lancer → noter ce que le code retourne RÉELLEMENT
3. Mettre à jour le test avec la valeur réelle
4. Commenter : "comportement réel documenté le [date]"
5. Ce test devient le filet avant tout changement
```

## Algorithme : Toucher du Code Legacy

```
1. Identifier le changement
2. Trouver les seams disponibles
3. Écrire les tests de caractérisation
4. Vérifier qu'ils passent (baseline)
5. Changer en micro-incréments
6. Vérifier après chaque incrément
7. Si test rouge → git revert immédiat
```

## Signaux d'Alarme

| Signal                      | Problème                        |
| --------------------------- | ------------------------------- |
| Fonction > 200 lignes       | God function                    |
| `global $var` partout       | État non contrôlable            |
| `new Classe()` dans méthode | Dépendance directe, pas de seam |
| `$_SESSION` accédé partout  | État global magique             |
| Commentaires `// HACK 2018` | Dette connue non remboursée     |
