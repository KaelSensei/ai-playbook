---
name: qa
description: >
  Lance les tests QA selon le mode choisi. Smoke (pré-merge rapide), full E2E, performance
  Lighthouse, load testing k6/Artillery, ou tout. Lit l'observabilité pendant les tests de charge.
  Résultats dans TEST_PLAN.md.
argument-hint: '[smoke | e2e | perf | load | full — défaut: smoke]'
---

# /qa

Update `tasks/current_task.md` : status=QA

Charger `TEST_PLAN.md` et `.claude/observability.md` avant tout.

---

## Modes disponibles

| Mode    | Durée     | Contenu                        | Quand                              |
| ------- | --------- | ------------------------------ | ---------------------------------- |
| `smoke` | < 2 min   | Flows critiques uniquement     | Avant chaque merge (auto dans /pr) |
| `e2e`   | 5-15 min  | Tous les flows + accessibilité | Après deploy staging               |
| `perf`  | 5-10 min  | Lighthouse sur pages critiques | Après feature frontend             |
| `load`  | 10-30 min | k6/Artillery + observabilité   | Avant release prod                 |
| `full`  | 30-60 min | Tout                           | Release majeure                    |

---

## Mode SMOKE (défaut si pas d'argument)

```
Tu es qa-automation.
Charge .claude/agents/qa-automation.md.
Charge TEST_PLAN.md → section "Smoke Tests"
Charge .claude/observability.md

Lance UNIQUEMENT les flows smoke :
```

```bash
# Playwright smoke
npx playwright test --grep "@smoke"
# ou si pas de tag smoke : lancer les fichiers smoke uniquement
npx playwright test tests/e2e/smoke/
```

Résultat :

```
Smoke tests : [N/N] ✅ / [N] ❌
Durée : [Xs]
Verdict : PASS ✅ / FAIL ❌
```

Si FAIL → arrêter et lister les tests en échec avec les erreurs.

---

## Mode E2E

```
Tu es qa-automation.
Charge TEST_PLAN.md → section "Full Suite"
Charge .claude/observability.md

Lancer tous les flows :
```

```bash
# Tous les tests Playwright
npx playwright test

# Avec accessibilité axe
npx playwright test --project=chromium

# Rapport HTML
npx playwright show-report
```

Vérifier aussi Sentry pendant l'exécution si configuré :

```bash
# Lire les nouvelles erreurs depuis le début des tests
curl -H "Authorization: Bearer $SENTRY_API_TOKEN" \
  "https://sentry.io/api/0/projects/[org]/[project]/issues/?query=firstSeen:>[test-start-timestamp]"
```

---

## Mode PERF (Lighthouse)

```bash
# Pour chaque page critique dans TEST_PLAN.md

# Lancer Lighthouse
npx lighthouse [URL]/[page] \
  --output=json \
  --output-path=./qa-results/lighthouse-[page]-$(date +%Y%m%d).json \
  --chrome-flags="--headless"

# Extraire les métriques clés
node -e "
const r = require('./qa-results/lighthouse-[page]-latest.json');
const a = r.categories.performance.score * 100;
const lcp = r.audits['largest-contentful-paint'].displayValue;
const fcp = r.audits['first-contentful-paint'].displayValue;
const tti = r.audits['interactive'].displayValue;
const cls = r.audits['cumulative-layout-shift'].displayValue;
console.log({score: a, lcp, fcp, tti, cls});
"
```

Comparer avec les seuils de `TEST_PLAN.md`.

---

## Mode LOAD (k6 + observabilité)

```bash
# Lancer le script k6 du scénario choisi
k6 run tests/load/[scenario].js \
  --out json=qa-results/k6-$(date +%Y%m%d-%H%M).json

# En parallèle : lire les métriques toutes les 10s
bash tests/qa/correlate.sh &
```

Pendant les tests, lire depuis le stack configuré :

- Prometheus : CPU, mémoire, latence DB
- Sentry : nouvelles erreurs générées
- Datadog/New Relic si configuré

Comparer p95, p99, error_rate avec les seuils de `TEST_PLAN.md`.

---

## Mode FULL

Enchaîner dans l'ordre :

1. Smoke → si FAIL, arrêter ici
2. E2E complet
3. Perf Lighthouse sur toutes les pages critiques
4. Load test scénario nominal
5. Load test scénario pic de charge

---

## Mise à jour TEST_PLAN.md

Après chaque exécution, ajouter une ligne dans la section "Historique" :

```markdown
| [date] | [env] | [mode] | [E2E résultat] | [Lighthouse score] | [k6 p95] | [Sentry errors] |
[verdict] |
```

---

## Intégration avec /pr

La commande `/pr` lance automatiquement le mode `smoke` avant le merge. Si smoke FAIL → merge
bloqué.

Update `tasks/current_task.md` : status=IDLE
