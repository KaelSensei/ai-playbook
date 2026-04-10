---
name: observability
description: >
  Configurable observability integration templates: Sentry, Prometheus+Grafana, Datadog, New Relic.
  Auto-loaded by qa-automation and devops-engineer. Invoke to configure observability, read metrics,
  or correlate test results with system metrics.
---

# Observability Reference

## Configuration in `.claude/observability.md`

Each project configures its stack in this file. QA Automation reads it to know where to look for
metrics.

```yaml
# .claude/observability.md — fill in for this project

stack:
  errors: sentry # sentry | datadog | newrelic | none
  metrics: prometheus # prometheus | datadog | newrelic | cloudwatch | none
  logs: grafana # grafana | datadog | newrelic | cloudwatch | none
  apm: none # datadog | newrelic | elastic | none

endpoints:
  sentry_dsn: '' # https://xxx@sentry.io/xxx
  sentry_api_token: '' # env: SENTRY_API_TOKEN
  prometheus_url: '' # http://prometheus:9090
  grafana_url: '' # http://grafana:3000
  datadog_api_key: '' # env: DD_API_KEY
  newrelic_api_key: '' # env: NEW_RELIC_API_KEY

slos:
  api_p95_ms: 200
  api_p99_ms: 500
  error_rate_max: 0.01 # 1%
  cpu_max: 80 # %
  memory_max: 85 # %
```

---

## Sentry

### Read errors via the API

```bash
# New errors from the past X hours
curl -H "Authorization: Bearer $SENTRY_API_TOKEN" \
  "https://sentry.io/api/0/projects/[org]/[project]/issues/?query=is:unresolved&statsPeriod=1h"

# Errors during a test window
curl -H "Authorization: Bearer $SENTRY_API_TOKEN" \
  "https://sentry.io/api/0/projects/[org]/[project]/issues/?query=firstSeen:>[timestamp]"
```

### Inside Playwright tests

```typescript
// Capture Sentry errors during a test
test('checkout flow', async ({ page }) => {
  const sentryErrors: string[] = [];

  page.on('console', (msg) => {
    if (msg.text().includes('Sentry')) sentryErrors.push(msg.text());
  });

  await page.goto('/checkout');
  // ... test ...

  expect(sentryErrors).toHaveLength(0); // no Sentry errors during the flow
});
```

---

## Prometheus + Grafana

### Useful queries during load tests

```bash
BASE="http://[prometheus-url]/api/v1/query"

# p95 latency over the last 5 minutes
curl "$BASE?query=histogram_quantile(0.95,rate(http_request_duration_seconds_bucket[5m]))"

# p99 latency
curl "$BASE?query=histogram_quantile(0.99,rate(http_request_duration_seconds_bucket[5m]))"

# Error rate
curl "$BASE?query=rate(http_requests_total{status=~'5..'}[5m])/rate(http_requests_total[5m])"

# CPU
curl "$BASE?query=100-(avg(rate(node_cpu_seconds_total{mode='idle'}[5m]))*100)"

# Memory
curl "$BASE?query=(1-(node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes))*100"

# Active DB connections
curl "$BASE?query=pg_stat_activity_count"

# Slow queries (PostgreSQL)
curl "$BASE?query=pg_stat_statements_mean_exec_time_ms > 100"
```

### Grafana — automatic snapshot

```bash
# Take a dashboard snapshot during the tests
curl -X POST http://[grafana-url]/api/snapshots \
  -H "Content-Type: application/json" \
  -d '{"dashboard": {...}, "expires": 3600}'
```

---

## Datadog

### Read metrics via the API

```bash
# System metrics
curl -X GET "https://api.datadoghq.com/api/v1/query" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -H "DD-APPLICATION-KEY: $DD_APP_KEY" \
  -d "query=avg:system.cpu.user{*}&from=[epoch-5min]&to=[epoch]"

# APM p95 latency
curl -X GET "https://api.datadoghq.com/api/v1/query" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -d "query=p95:trace.web.request{env:staging}&from=[epoch-5min]&to=[epoch]"

# Error rate
curl -X GET "https://api.datadoghq.com/api/v1/query" \
  -H "DD-API-KEY: $DD_API_KEY" \
  -d "query=sum:trace.web.request.errors{env:staging}.as_rate()&from=[epoch-5min]&to=[epoch]"
```

---

## New Relic

### NRQL via the API

```bash
ACCOUNT_ID="[your-account-id]"

# p95 latency, last 5 minutes
curl -X POST "https://api.newrelic.com/graphql" \
  -H "Api-Key: $NEW_RELIC_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ actor { account(id: '$ACCOUNT_ID') { nrql(query: \"SELECT percentile(duration, 95) FROM Transaction WHERE appName = '\''[app]'\'' SINCE 5 minutes ago\") { results } } } }"
  }'

# Error rate
# NRQL: SELECT count(*) FROM TransactionError SINCE 5 minutes ago
```

---

## QA + Observability Correlation Script

```bash
#!/bin/bash
# tests/qa/correlate.sh
# Runs k6 tests and reads metrics in parallel

PROM_URL="${PROMETHEUS_URL:-http://localhost:9090}"
TEST_START=$(date +%s)

echo "🚀 Starting load tests..."
k6 run tests/load/api.js &
K6_PID=$!

echo "📊 Reading metrics every 10s..."
while kill -0 $K6_PID 2>/dev/null; do
  CPU=$(curl -s "$PROM_URL/api/v1/query?query=100-(avg(rate(node_cpu_seconds_total{mode='idle'}[30s]))*100)" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(round(float(d['data']['result'][0]['value'][1]),1))" 2>/dev/null || echo "N/A")

  P95=$(curl -s "$PROM_URL/api/v1/query?query=histogram_quantile(0.95,rate(http_request_duration_seconds_bucket[30s]))" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); r=d['data']['result']; print(round(float(r[0]['value'][1])*1000,0) if r else 'N/A')" 2>/dev/null || echo "N/A")

  echo "  CPU: ${CPU}% | p95: ${P95}ms"
  sleep 10
done

wait $K6_PID
TEST_END=$(date +%s)
echo "✅ Tests finished in $((TEST_END - TEST_START))s"
```

---

## Default Thresholds (override in TEST_PLAN.md)

| Metric         | Good    | Warning   | Critical |
| -------------- | ------- | --------- | -------- |
| LCP            | < 2.5s  | 2.5-4s    | > 4s     |
| FCP            | < 1.8s  | 1.8-3s    | > 3s     |
| TTI            | < 3.8s  | 3.8-7.3s  | > 7.3s   |
| CLS            | < 0.1   | 0.1-0.25  | > 0.25   |
| API p95        | < 200ms | 200-500ms | > 500ms  |
| API p99        | < 500ms | 500ms-1s  | > 1s     |
| Error rate     | < 0.1%  | 0.1-1%    | > 1%     |
| CPU under load | < 70%   | 70-85%    | > 85%    |
| Memory         | < 75%   | 75-90%    | > 90%    |
