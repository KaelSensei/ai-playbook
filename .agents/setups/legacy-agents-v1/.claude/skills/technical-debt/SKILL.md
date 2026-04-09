---
name: technical-debt
description: >
  Taxonomie de la dette technique, métriques, priorisation, communication avec le business.
  Auto-chargé par debt-tracker, tech-lead, legacy-analyst. Invoke pour auditer, quantifier ou
  prioriser la dette.
---

# Technical Debt Reference

## Taxonomie (Ward Cunningham + Martin Fowler)

```
                    DÉLIBÉRÉ          ACCIDENTEL
PRUDENT    │ "On sait qu'on fait │ "On comprend       │
           │  un compromis pour  │  maintenant qu'on   │
           │  livrer vite"       │  aurait dû mieux    │
           │                     │  faire"             │
───────────┼─────────────────────┼─────────────────────┤
IMPRUDENT  │ "On n'a pas le      │ "On ne savait même  │
           │  temps de bien      │  pas qu'on faisait  │
           │  faire"             │  mal"               │
```

**Délibéré + Prudent** : acceptable si documenté et prévu de rembourser **Délibéré + Imprudent** :
dangereux, s'accumule sans plan **Accidentel + Prudent** : normal, apprentissage de l'équipe
**Accidentel + Imprudent** : le plus dangereux, invisible

## Métriques Concrètes

### Hotspot Analysis (Adam Tornhill)

```bash
# Fichiers les plus modifiés = dette probable
git log --name-only --format="" | grep -v "^$" | sort | uniq -c | sort -rn | head -20

# Combiné avec complexité = priorité de refactoring
# Fichier souvent modifié ET complexe = rembourser en premier
```

### Complexité Cyclomatique

```bash
# PHP
phploc src/ --log-csv metrics.csv

# Python
radon cc src/ -a

# JavaScript
npx complexity-report src/

# Seuils :
# 1-10   : simple
# 11-20  : modéré (surveiller)
# 21-50  : complexe (tester rigoureusement)
# > 50   : danger (rembourser en priorité)
```

### Duplication

```bash
# PHP
phpcpd src/ --min-lines 5

# Python
pylint --disable=all --enable=duplicate-code src/

# JavaScript
jscpd src/

# > 20% duplication = dette significative
```

## Coût de la Dette

```
Coût principal = Interest (intérêt)
La dette ne coûte pas à l'instant T.
Elle coûte à chaque fois qu'on touche à ce code ensuite.

Principal = effort de remboursement
Interest = effort supplémentaire à chaque feature à cause de la dette

Si interest > 0 pour chaque feature → rembourser maintenant
Si interest ≈ 0 (code rarement touché) → accepter
```

## Priorisation

```
Score = Impact / Effort

Impact (1-5) :
  5 = bloque les déploiements ou cause des bugs prod
  4 = ralentit significativement chaque feature
  3 = source fréquente de confusion et d'erreurs
  2 = irritant mais gérable
  1 = cosmétique

Effort (1-5) :
  1 = < 1h (renommage, extraction simple)
  2 = 1 journée (refactoring module)
  3 = 1 semaine (refactoring composant)
  4 = 1 mois (découpage module)
  5 = > 1 mois (réécriture partielle)

Matrice :
Impact ↑ / Effort ↓ = rembourser maintenant
Impact ↑ / Effort ↑ = planifier (Strangler Fig)
Impact ↓ / Effort ↓ = Boy Scout Rule (au passage)
Impact ↓ / Effort ↑ = accepter et documenter
```

## Communication avec le Business

```
❌ Ne pas dire : "On a de la dette technique à rembourser"
✅ Dire : "Chaque nouvelle feature dans ce module prend 3x plus longtemps
           qu'ailleurs. Si on investit 2 semaines maintenant, les 12
           prochaines features iront 3x plus vite."

❌ Ne pas dire : "Le code est sale"
✅ Dire : "3 bugs en prod ce mois viennent de ce même module.
           Rembourser cette dette réduirait les incidents de ~50%."

Traduire toujours en : temps gagné, bugs évités, features débloquées.
```

## Boy Scout Rule

```
Laisser le code un peu mieux qu'on l'a trouvé.
Pas de grand refactoring non demandé.
Juste : renommer une variable obscure, extraire une fonction de 5 lignes,
supprimer un commentaire obsolète.
Cumulé sur des mois, ça change tout.
```
