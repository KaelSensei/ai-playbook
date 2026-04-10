---
name: qa
description: >
  Run the QA tests for the chosen mode. Smoke (fast pre-merge), full E2E, Lighthouse performance,
  k6/Artillery load testing, or everything. Reads observability during load tests. Results in
  TEST_PLAN.md.
argument-hint: '[smoke | e2e | perf | load | full — default: smoke]'
---

# /qa

Update `tasks/current_task.md`: status=QA

Load `TEST_PLAN.md` and `.claude/observability.md` before anything else.

---

## Available Modes

| Mode    | Duration  | Contents                     | When                            |
| ------- | --------- | ---------------------------- | ------------------------------- |
| `smoke` | < 2 min   | Critical flows only          | Before each merge (auto in /pr) |
| `e2e`   | 5-15 min  | All flows + accessibility    | After staging deploy            |
| `perf`  | 5-10 min  | Lighthouse on critical pages | After a frontend feature        |
| `load`  | 10-30 min | k6/Artillery + observability | Before a prod release           |
| `full`  | 30-60 min | Everything                   | Major release                   |

---

## SMOKE Mode (default if no argument)

```
You are qa-automation.
Load .claude/agents/qa-automation.md.
Load TEST_PLAN.md → "Smoke Tests" section
Load .claude/observability.md

Run ONLY the smoke flows:
```

```bash
# Playwright smoke
npx playwright test --grep "@smoke"
# or if no smoke tag: run the smoke files only
npx playwright test tests/e2e/smoke/
```

Result:

```
Smoke tests: [N/N] pass / [N] fail
Duration: [Xs]
Verdict: PASS / FAIL
```

If FAIL → stop and list the failing tests with errors.

---

## E2E Mode

```
You are qa-automation.
Load TEST_PLAN.md → "Full Suite" section
Load .claude/observability.md

Run all flows:
```

```bash
# All Playwright tests
npx playwright test

# With axe accessibility
npx playwright test --project=chromium

# HTML report
npx playwright show-report
```

Also check Sentry during execution if configured:

```bash
# Read new errors since test start
curl -H "Authorization: Bearer $SENTRY_API_TOKEN" \
  "https://sentry.io/api/0/projects/[org]/[project]/issues/?query=firstSeen:>[test-start-timestamp]"
```

---

## PERF Mode (Lighthouse)

```bash
# For each critical page in TEST_PLAN.md

# Run Lighthouse
npx lighthouse [URL]/[page] \
  --output=json \
  --output-path=./qa-results/lighthouse-[page]-$(date +%Y%m%d).json \
  --chrome-flags="--headless"

# Extract key metrics
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

Compare with the thresholds in `TEST_PLAN.md`.

---

## LOAD Mode (k6 + observability)

```bash
# Run the k6 script for the chosen scenario
k6 run tests/load/[scenario].js \
  --out json=qa-results/k6-$(date +%Y%m%d-%H%M).json

# In parallel: read metrics every 10s
bash tests/qa/correlate.sh &
```

During the tests, read from the configured stack:

- Prometheus: CPU, memory, DB latency
- Sentry: new errors generated
- Datadog/New Relic if configured

Compare p95, p99, error_rate with the thresholds in `TEST_PLAN.md`.

---

## FULL Mode

Chain in this order:

1. Smoke → if FAIL, stop here
2. Full E2E
3. Lighthouse perf on all critical pages
4. Nominal load test scenario
5. Peak-load test scenario

---

## Update TEST_PLAN.md

After each run, add a line in the "History" section:

```markdown
| [date] | [env] | [mode] | [E2E result] | [Lighthouse score] | [k6 p95] | [Sentry errors] |
[verdict] |
```

---

## Integration with /pr

The `/pr` command automatically runs `smoke` mode before merging. If smoke FAILS → merge blocked.

Update `tasks/current_task.md`: status=IDLE
