---
name: understand
description: >
  Cartographier un module legacy avant tout changement. legacy-analyst + archaeologist en parallèle.
  Mise à jour de legacy-map.md. Obligatoire avant /characterize, /refactor ou /strangler sur un
  module inconnu.
argument-hint: '[module ou fichier à cartographier]'
---

# /understand

Update `tasks/current_task.md` : status=UNDERSTAND, module=$ARGUMENTS

**Règle d'or** : on ne touche pas ce qu'on n'a pas cartographié.

---

## Phase 1 — Spawner legacy-analyst et archaeologist en parallèle

Les deux agents bossent simultanément sur des angles différents.

**legacy-analyst prompt :**

```
Tu es legacy-analyst.
Charge .claude/agents/legacy-analyst.md.
Charge project-architecture.md, legacy-map.md.
Charge legacy-patterns, technical-debt skills.

Cartographie ce module : $ARGUMENTS

Explorer dans cet ordre :
1. git blame — qui a touché ça, quand, combien de fois
2. Taille et structure du fichier
3. Toutes les dépendances entrantes (qui appelle ce module)
4. Toutes les dépendances sortantes (ce module appelle quoi)
5. Tests existants (oui/non/partiels)
6. Identifier les seams disponibles
7. Estimer le niveau de risque

Produire une fiche module complète au format legacy-map.md.
Identifier les couplages dangereux et les zones à risque.
```

**archaeologist prompt :**

```
Tu es archaeologist.
Charge .claude/agents/archaeologist.md.
Charge project-architecture.md, legacy-map.md.
Charge legacy-patterns, team--skill-lookup skills.

Comprends l'histoire de ce module : $ARGUMENTS

Explorer :
1. git log --follow -p — évolution dans le temps
2. git log --grep="fix\|hotfix\|hack\|quick" — patchs d'urgence
3. Commentaires et TODO dans le code — décisions héritées
4. Règles métier implicites dans le code
5. Contournements identifiables (hacks devenus permanents)
6. Décisions bizarres avec raison probable

Produire le rapport d'archéologie au format archaeologist.
```

---

## Phase 2 — Synthèse

Collecter les deux rapports. Construire une vue unifiée :

```markdown
# Cartographie : $ARGUMENTS

## Résumé Exécutif

[3-5 phrases : ce que fait le module, son état, risque global]

## Fiche Module (pour legacy-map.md)

[fiche complète au format legacy-map.md]

## Histoire (Archéologie)

[findings de l'archaeologist]

## Zones à Risque

🔴 [description] — [pourquoi dangereux] 🟡 [description] — [attention]

## Seams Disponibles

- [seam 1] : [comment l'exploiter]
- [seam 2] : [comment l'exploiter]

## Recommandation

- [ ] Prêt pour /characterize (seams disponibles)
- [ ] Seams à créer d'abord (Sprout/Wrap method)
- [ ] Trop risqué — discuter avec tech-lead avant de toucher
```

---

## Phase 3 — Mise à jour legacy-map.md

Ajouter la fiche module dans `.claude/legacy-map.md`. Mettre à jour la section "Zones Non Explorées"
(retirer ce module). Mettre à jour `last-verified` de `legacy-map.md`.

Update `tasks/current_task.md` : status=IDLE

```
✅ Cartographie terminée : $ARGUMENTS
Niveau de risque : 🟢 / 🟡 / 🔴
Seams disponibles : [N]
Tests existants : oui/non/partiels
Prêt pour : /characterize $ARGUMENTS
```
