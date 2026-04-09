---
name: team--skill-review
description: >
  Protocole de review partagé par tous les agents. Définit les niveaux de verdict, le format de
  sortie et les règles de merge. Chargé par tous les agents pendant /review, /spec, /build et
  /check.
---

# Team Review Protocol

## Niveaux de Verdict

| Verdict                | Signification                                      | Bloque ?           |
| ---------------------- | -------------------------------------------------- | ------------------ |
| `APPROVE`              | Aucun problème significatif                        | Non                |
| `APPROVE_WITH_CHANGES` | Problèmes présents mais pas bloquants              | Itération attendue |
| `REQUEST_REDESIGN`     | Problème fondamental — must fix avant de continuer | Oui, hard stop     |

**Règles :**

- Un seul `REQUEST_REDESIGN` de n'importe quel agent = arrêt complet
- Un seul `APPROVE_WITH_CHANGES` = itération avant l'étape suivante
- `APPROVE` unanime = on avance
- Pas de vote majoritaire. Pas d'override par séniorité. Unanime.

## Format de Sortie Obligatoire

Chaque agent DOIT retourner exactement cette structure :

```markdown
## [Discipline] Review

**Verdict**: APPROVE | APPROVE_WITH_CHANGES | REQUEST_REDESIGN

### 🔴 Blockers

<!-- Doit être corrigé avant de continuer.
     Une entrée par problème. Référencer l'emplacement précis. -->

- **[fichier:ligne ou composant]**: [problème] — [pourquoi c'est bloquant] — [correction requise]

### 🟡 Improvements

<!-- Devrait être corrigé, pas bloquant. -->

- **[emplacement]**: [problème] — [correction suggérée]

### 🔵 Nits

<!-- Optionnel. Style, nommage, suggestions mineures. -->

- [note]

### Checklist Discipline

- [x] / [ ] / [N/A] [item 1]
- [x] / [ ] / [N/A] [item 2] ...
```

## Règles de Merge (pour l'orchestrateur)

1. Collecter tous les verdicts
2. Si au moins un `REQUEST_REDESIGN` → verdict global = `REQUEST_REDESIGN`
3. Si au moins un `APPROVE_WITH_CHANGES` (sans redesign) → verdict global = `APPROVE_WITH_CHANGES`
4. Tous `APPROVE` → verdict global = `APPROVE`
5. Dédupliquer les findings cross-agents — une entrée par problème unique, sévérité la plus haute
6. Si plusieurs agents ont flaggé le même problème → noter : _"flaggé par N agents"_
7. Présenter le verdict mergé avec attribution par agent

## Scope par Flow

| Flow                   | Lire | Écrire du code                | Périmètre                               |
| ---------------------- | ---- | ----------------------------- | --------------------------------------- |
| `/review`              | ✅   | ❌                            | Diff complet                            |
| `/spec` review         | ✅   | ❌                            | Design uniquement, pas d'implémentation |
| `/build` pair review   | ✅   | Agent propriétaire uniquement | Diff de l'étape courante                |
| `/build` review finale | ✅   | ❌                            | Diff complet depuis le début            |
| `/check`               | ✅   | ❌                            | Diff complet, focus qualité/sécu/data   |

## Comportements Interdits

- ❌ APPROVE sans avoir coché la checklist
- ❌ Feedback générique non lié à sa discipline
- ❌ APPROVE parce qu'un autre agent a approuvé
- ❌ Critiquer ce qui est hors scope de sa discipline
- ❌ `REQUEST_REDESIGN` sans expliquer le problème
