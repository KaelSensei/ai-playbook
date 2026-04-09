# Test Plan

<!-- Mis à jour par qa-automation après chaque exécution -->
<!-- Mettre à jour les seuils et flows au début du projet -->

## Stack QA configuré

<!-- Configurer une seule fois -->

- E2E : Playwright / Cypress (choisir)
- Perf frontend : Lighthouse CLI
- Accessibilité : axe-core (intégré Playwright)
- Tests de charge : k6 / Artillery (choisir)
- Observabilité : voir `.claude/observability.md`

---

## Flows Critiques (E2E)

### Smoke Tests (pré-merge, < 2 min)

<!-- Les flows les plus critiques — ceux qui, s'ils cassent, bloquent tout -->

- [ ] Authentification (login + logout)
- [ ] [Flow critique 2 — ex: checkout, création d'un objet principal]
- [ ] [Flow critique 3]

### Full Suite (post-deploy staging)

<!-- Tous les flows utilisateur importants -->

#### Authentification

- [ ] Login avec email/password valide → redirection dashboard
- [ ] Login avec mauvais password → message d'erreur
- [ ] Login avec email inexistant → message d'erreur
- [ ] Logout → retour page login
- [ ] Session expirée → redirection login
- [ ] Reset password → email reçu + lien valide

#### [Module 2 — ex: Profil]

- [ ] Voir son profil
- [ ] Modifier son profil → changements sauvegardés
- [ ] Upload avatar → visible immédiatement
- [ ] Champs invalides → erreurs affichées

#### [Module 3 — ajouter par feature]

<!-- Alimenté par scribe après chaque /build -->

---

## Seuils de Performance Frontend

<!-- Core Web Vitals — adapter par page -->

| Page            | LCP max | FCP max | TTI max | CLS max | Score Lighthouse min |
| --------------- | ------- | ------- | ------- | ------- | -------------------- |
| Home / Landing  | 2.5s    | 1.8s    | 3.8s    | 0.1     | 85                   |
| Dashboard       | 3s      | 2s      | 4s      | 0.1     | 80                   |
| [Page critique] | 2.5s    | 1.8s    | 3.8s    | 0.1     | 85                   |

---

## Seuils de Performance Backend

| Endpoint                | p50 max | p95 max | p99 max | Error rate max |
| ----------------------- | ------- | ------- | ------- | -------------- |
| GET /api/v1/users       | 50ms    | 150ms   | 300ms   | 0.1%           |
| POST /api/v1/auth/login | 100ms   | 300ms   | 500ms   | 0.5%           |
| [Endpoint critique]     |         |         |         |                |

---

## Scénarios de Charge

### Scénario 1 — Charge nominale

```javascript
// tests/load/nominal.js
export const options = {
  vus: 50, // utilisateurs simultanés
  duration: '2m',
  thresholds: {
    http_req_duration: ['p(95)<200', 'p(99)<500'],
    http_req_failed: ['rate<0.01'],
  },
};
```

### Scénario 2 — Pic de charge

```javascript
export const options = {
  stages: [
    { duration: '1m', target: 50 }, // montée
    { duration: '3m', target: 200 }, // pic
    { duration: '1m', target: 0 }, // descente
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.05'],
  },
};
```

### Scénario 3 — Stress (adapter)

```javascript
export const options = {
  stages: [
    { duration: '2m', target: 500 },
    { duration: '5m', target: 500 },
    { duration: '2m', target: 0 },
  ],
};
```

---

## SLAs

| Métrique                  | SLA          |
| ------------------------- | ------------ |
| Disponibilité             | 99.9% / mois |
| Temps de réponse p95      | < 200ms      |
| Temps de réponse p99      | < 500ms      |
| Error rate                | < 0.1%       |
| Déploiement sans downtime | obligatoire  |

---

## Historique des Exécutions

<!-- Mis à jour automatiquement par qa-automation -->

| Date | Env        | Type    | E2E  | Lighthouse | k6 p95 | Erreurs Sentry | Verdict |
| ---- | ---------- | ------- | ---- | ---------- | ------ | -------------- | ------- | ------- | --- |
| <!-- | 2024-03-15 | staging | full | ✅ 42/42   | 87/100 | 182ms          | 0       | ✅ PASS | --> |

---

## Régressions Connues

<!-- Régressions détectées mais non encore corrigées -->

| Régression | Détectée le | Ticket | Impact |
| ---------- | ----------- | ------ | ------ |

---

## Configuration Playwright

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30_000,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: process.env.TEST_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'mobile', use: { ...devices['iPhone 13'] } },
  ],
});
```
