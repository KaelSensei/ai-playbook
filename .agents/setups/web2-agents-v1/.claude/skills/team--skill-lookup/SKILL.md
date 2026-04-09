---
name: team--skill-lookup
description: >
  Protocole d'exploration du codebase et de lookup de contexte. Chargé pendant /story, /spec et la
  phase EXPLORE. Définit comment vérifier la fraîcheur des docs, explorer le codebase
  systématiquement, et utiliser la recherche web efficacement.
---

# Team Lookup Protocol

## Vérification de Fraîcheur des Docs

Chaque agent DOIT vérifier `last-verified` avant de raisonner depuis un doc.

```
aujourd'hui - last-verified <= 30 jours → FRESH → faire confiance au doc
aujourd'hui - last-verified >  30 jours → STALE → explorer le codebase
```

Si un doc est stale :

1. Le signaler explicitement : _"project-architecture.md est STALE (last-verified: [date])"_
2. Explorer le codebase directement pour les parties concernées
3. Signaler les divergences entre doc et réalité à l'orchestrateur
4. Ne PAS mettre à jour le doc silencieusement — signaler, ne pas corriger mid-tâche

## Ordre d'Exploration du Codebase

Pour un projet web2 classique, explorer dans cet ordre :

```
1. package.json / pyproject.toml   → stack, dépendances, versions
2. src/ ou app/                    → structure des modules
3. test/ ou __tests__/             → comprendre le comportement attendu depuis les tests
4. .env.example                    → variables d'env requises
5. migrations/ ou prisma/schema    → état du schéma BDD
6. CI config (.github/workflows/)  → pipeline de qualité
7. README.md                       → conventions spécifiques au projet
```

**Règle** : lire les tests avant le code. Les tests expriment l'intention ; l'implémentation exprime
le mécanisme.

## Recherche Web

Utiliser la recherche web pour la connaissance externe non couverte par les skills :

**Bons usages :**

- Documentation de frameworks (Next.js, NestJS, FastAPI, Rails)
- RFC et standards (RFC 7519 JWT, RFC 6749 OAuth2)
- CVE et advisories de sécurité
- Changelogs de dépendances
- Patterns connus pour un problème spécifique

**Patterns de recherche efficaces :**

```
"[framework] [feature] documentation"
"[library] [version] breaking changes"
"[vulnerability] [language] mitigation"
"[pattern] best practices [year]"
```

**Ne PAS utiliser la recherche web pour :**

- Ce qui est couvert par les skills chargés
- Les détails d'implémentation visibles dans le codebase
- Les questions auxquelles les docs frais répondent déjà

## Format de Sortie après Exploration

```markdown
# Exploration : [sujet ou feature]

## Statut des Docs

- project-architecture.md : FRESH (last-verified: YYYY-MM-DD) / STALE
- data-architecture.md : FRESH / STALE
- constants.md : FRESH / STALE

## Findings Codebase

[fichiers clés explorés, patterns observés, conventions identifiées]

## Recherche Externe

[URLs consultées, faits clés extraits — paraphrasés]

## Divergences Trouvées

[ce qui ne correspond pas aux docs, avec fichier + ligne]

## Réponse à la Tâche d'Exploration

[réponse directe et structurée à ce qui était cherché]

## Questions Ouvertes

[ce qui ne peut pas être déterminé — besoin clarification utilisateur]
```

## Règles d'Efficacité

- Lire le fichier de test d'un module avant le module lui-même
- S'arrêter d'explorer dès qu'on a assez pour répondre à la question
- Une recherche web par concept externe distinct — pas de répétition
- Si un doc est frais et répond directement → lui faire confiance, s'arrêter
