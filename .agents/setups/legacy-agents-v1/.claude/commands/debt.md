---
name: debt
description: >
  Auditer et prioriser la dette technique. debt-tracker + legacy-analyst en parallèle. Produit un
  inventaire priorisé et un plan de remboursement.
argument-hint: '[module spécifique ou vide pour audit global]'
---

# /debt

Update `tasks/current_task.md` : status=DEBT

---

## Phase 1 — Collecte des métriques

```bash
# Hotspots (fichiers les plus modifiés = dette probable)
git log --name-only --format="" | grep -v "^$" | sort | uniq -c | sort -rn | head -20

# Taille des fichiers (gros fichiers = red flag)
find . -name "*.[extension]" | xargs wc -l 2>/dev/null | sort -rn | head -20

# Complexité (si outil disponible)
# PHP : phploc src/
# Python : radon cc src/ -a
# JS : npx complexity-report src/

# Duplication
# PHP : phpcpd src/ --min-lines 5
# JS : npx jscpd src/
```

---

## Phase 2 — Spawner debt-tracker et legacy-analyst en parallèle

**debt-tracker prompt :**

```
Tu es debt-tracker.
Charge .claude/agents/debt-tracker.md.
Charge project-architecture.md, legacy-map.md.
Charge technical-debt skill.

Périmètre : $ARGUMENTS (ou global si vide)
Métriques collectées : [output Phase 1]
Legacy map existante : [contenu legacy-map.md]

Produis :
1. Inventaire de la dette par catégorie (critique/significatif/mineur)
2. Score Impact/Effort pour chaque item
3. Top 5 items à rembourser en priorité
4. Dette délibérée acceptée (documenter les raisons)
```

**legacy-analyst prompt :**

```
Tu es legacy-analyst.
Charge .claude/agents/legacy-analyst.md.
Charge project-architecture.md, legacy-map.md.
Charge legacy-patterns, technical-debt skills.

Périmètre : $ARGUMENTS
Métriques : [output Phase 1]

Enrichir l'inventaire avec :
1. Zones non encore cartographiées (risque inconnu)
2. Couplages dangereux identifiés
3. Modules qui bloquent les features actuellement
4. Estimation du "interest" pour chaque item (coût par feature future)
```

---

## Phase 3 — Synthèse et plan

Merger les outputs et produire :

```markdown
# Audit de Dette Technique

Date : [aujourd'hui] Périmètre : $ARGUMENTS

## Résumé Exécutif

[3-5 phrases : état général, top problèmes, recommandation principale]

## Inventaire Priorisé

### 🔴 Critique (score > 3)

| Item | Type | Fichier(s) | Impact | Effort | Score | Action |
| ---- | ---- | ---------- | ------ | ------ | ----- | ------ |

### 🟡 Significatif (score 1.5-3)

| Item | Type | Fichier(s) | Impact | Effort | Score | Action |
| ---- | ---- | ---------- | ------ | ------ | ----- | ------ |

### 🟢 Mineur (score < 1.5)

| Item | Type | Fichier(s) | Impact | Effort | Score | Action |
| ---- | ---- | ---------- | ------ | ------ | ----- | ------ |

### Dette Délibérée Acceptée

| Item | Raison | Depuis | Remboursement prévu |
| ---- | ------ | ------ | ------------------- |

## Plan de Remboursement Recommandé

### Cette semaine (Quick wins — effort 1)

- [items]

### Ce sprint (effort 2-3)

- [items]

### Prochain trimestre (effort 4-5, Strangler Fig)

- [items]

### Accepté indéfiniment

- [items avec justification]

## Zones Non Cartographiées (risque inconnu)

- [modules jamais explorés]
```

---

## Phase 4 — Présenter et décider

Présenter à l'utilisateur. **Gate** : _"Ce plan correspond-il aux priorités business ?"_

Mettre à jour `legacy-map.md` avec les nouvelles découvertes. Sauvegarder le rapport dans
`.claude/specs/debt-audit-[date].md`.

Update `tasks/current_task.md` : status=IDLE

```
✅ Audit terminé
Items critiques : [N]
Quick wins identifiés : [N]
Rapport : .claude/specs/debt-audit-[date].md
```
