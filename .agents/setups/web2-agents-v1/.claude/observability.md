# Observability Config

<!-- Fill in once for this project -->
<!-- Loaded by qa-automation and devops-engineer -->

## Stack

```yaml
errors: none # sentry | datadog | newrelic | none
metrics: none # prometheus | datadog | newrelic | cloudwatch | none
logs: none # grafana | datadog | newrelic | cloudwatch | none
apm: none # datadog | newrelic | elastic | none
```

## Endpoints

<!-- Do not put sensitive values here — use env vars -->

```yaml
sentry_dsn: '' # or env: SENTRY_DSN
sentry_org: ''
sentry_project: ''
sentry_api_token: '' # env: SENTRY_API_TOKEN

prometheus_url: '' # e.g. http://prometheus:9090
grafana_url: '' # e.g. http://grafana:3000
grafana_api_key: '' # env: GRAFANA_API_KEY

datadog_site: '' # e.g. datadoghq.eu
datadog_api_key: '' # env: DD_API_KEY
datadog_app_key: '' # env: DD_APP_KEY
datadog_app_name: '' # app name in Datadog

newrelic_account: ''
newrelic_api_key: '' # env: NEW_RELIC_API_KEY
newrelic_app_name: ''
```

## SLOs (override the defaults from the observability skill)

```yaml
api_p95_ms: 200
api_p99_ms: 500
error_rate_max: 0.01 # 1%
cpu_max_pct: 80
memory_max_pct: 85
```

## Dashboard URLs (for QA reports)

```yaml
main_dashboard: '' # URL of the main dashboard
load_test_dash: '' # URL of the dashboard dedicated to load tests
```
