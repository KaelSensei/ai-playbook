# Observability Config

<!-- Remplir une seule fois pour ce projet -->
<!-- Chargé par qa-automation et devops-engineer -->

## Stack

```yaml
errors: none # sentry | datadog | newrelic | none
metrics: none # prometheus | datadog | newrelic | cloudwatch | none
logs: none # grafana | datadog | newrelic | cloudwatch | none
apm: none # datadog | newrelic | elastic | none
```

## Endpoints

<!-- Ne pas mettre les valeurs sensibles ici — utiliser les env vars -->

```yaml
sentry_dsn: '' # ou env: SENTRY_DSN
sentry_org: ''
sentry_project: ''
sentry_api_token: '' # env: SENTRY_API_TOKEN

prometheus_url: '' # ex: http://prometheus:9090
grafana_url: '' # ex: http://grafana:3000
grafana_api_key: '' # env: GRAFANA_API_KEY

datadog_site: '' # ex: datadoghq.eu
datadog_api_key: '' # env: DD_API_KEY
datadog_app_key: '' # env: DD_APP_KEY
datadog_app_name: '' # nom de l'app dans Datadog

newrelic_account: ''
newrelic_api_key: '' # env: NEW_RELIC_API_KEY
newrelic_app_name: ''
```

## SLOs (surcharge les défauts de observability skill)

```yaml
api_p95_ms: 200
api_p99_ms: 500
error_rate_max: 0.01 # 1%
cpu_max_pct: 80
memory_max_pct: 85
```

## Dashboard URLs (pour les rapports QA)

```yaml
main_dashboard: '' # URL du dashboard principal
load_test_dash: '' # URL du dashboard dédié aux tests de charge
```
