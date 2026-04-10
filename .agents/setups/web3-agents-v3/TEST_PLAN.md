# Test Plan

<!-- Updated by qa-automation after each run -->
<!-- Set the thresholds and flows at the start of the project -->

## Configured QA Stack

<!-- Configure once -->

- E2E: Playwright / Cypress (pick one)
- Frontend perf: Lighthouse CLI
- Accessibility: axe-core (integrated into Playwright)
- Load testing: k6 / Artillery (pick one)
- Observability: see `.claude/observability.md`

---

## Critical Flows (E2E)

### Smoke Tests (pre-merge, < 2 min)

<!-- The most critical flows — the ones that block everything if they break -->

- [ ] Authentication (login + logout)
- [ ] [Critical flow 2 — e.g. checkout, creating a primary object]
- [ ] [Critical flow 3]

### Full Suite (post-deploy staging)

<!-- All important user flows -->

#### Authentication

- [ ] Login with valid email/password → redirect to dashboard
- [ ] Login with wrong password → error message
- [ ] Login with nonexistent email → error message
- [ ] Logout → back to login page
- [ ] Expired session → redirect to login
- [ ] Password reset → email received + valid link

#### [Module 2 — e.g. Profile]

- [ ] View profile
- [ ] Edit profile → changes saved
- [ ] Upload avatar → visible immediately
- [ ] Invalid fields → errors displayed

#### [Module 3 — added per feature]

<!-- Populated by scribe after each /build -->

---

## Frontend Performance Thresholds

<!-- Core Web Vitals — adapt per page -->

| Page            | LCP max | FCP max | TTI max | CLS max | Min Lighthouse score |
| --------------- | ------- | ------- | ------- | ------- | -------------------- |
| Home / Landing  | 2.5s    | 1.8s    | 3.8s    | 0.1     | 85                   |
| Dashboard       | 3s      | 2s      | 4s      | 0.1     | 80                   |
| [Critical page] | 2.5s    | 1.8s    | 3.8s    | 0.1     | 85                   |

---

## Backend Performance Thresholds

| Endpoint                | p50 max | p95 max | p99 max | Error rate max |
| ----------------------- | ------- | ------- | ------- | -------------- |
| GET /api/v1/users       | 50ms    | 150ms   | 300ms   | 0.1%           |
| POST /api/v1/auth/login | 100ms   | 300ms   | 500ms   | 0.5%           |
| [Critical endpoint]     |         |         |         |                |

---

## Load Scenarios

### Scenario 1 — Nominal load

```javascript
// tests/load/nominal.js
export const options = {
  vus: 50, // concurrent users
  duration: '2m',
  thresholds: {
    http_req_duration: ['p(95)<200', 'p(99)<500'],
    http_req_failed: ['rate<0.01'],
  },
};
```

### Scenario 2 — Peak load

```javascript
export const options = {
  stages: [
    { duration: '1m', target: 50 }, // ramp up
    { duration: '3m', target: 200 }, // peak
    { duration: '1m', target: 0 }, // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.05'],
  },
};
```

### Scenario 3 — Stress (adapt)

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

| Metric                   | SLA           |
| ------------------------ | ------------- |
| Availability             | 99.9% / month |
| Response time p95        | < 200ms       |
| Response time p99        | < 500ms       |
| Error rate               | < 0.1%        |
| Zero-downtime deployment | required      |

---

## Run History

<!-- Updated automatically by qa-automation -->

| Date | Env        | Type    | E2E  | Lighthouse | k6 p95 | Sentry errors | Verdict |
| ---- | ---------- | ------- | ---- | ---------- | ------ | ------------- | ------- | ------- | --- |
| <!-- | 2024-03-15 | staging | full | ✅ 42/42   | 87/100 | 182ms         | 0       | ✅ PASS | --> |

---

## Known Regressions

<!-- Regressions detected but not yet fixed -->

| Regression | Detected on | Ticket | Impact |
| ---------- | ----------- | ------ | ------ |

---

## Playwright Configuration

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
