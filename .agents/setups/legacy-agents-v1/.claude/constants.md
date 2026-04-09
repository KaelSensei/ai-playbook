# Constants

<!-- last-verified: YYYY-MM-DD -->

## Environments

| Env        | URL                     | Notes                   |
| ---------- | ----------------------- | ----------------------- |
| Local      | http://localhost        | Config spéciale requise |
| Staging    | https://staging.app.com | Miroir prod partiel     |
| Production | https://app.com         |                         |

## Variables d'Environnement

<!-- Documenter TOUTES les vars d'env requises.
     Dans un projet legacy elles sont souvent éparpillées dans le code. -->

## Configuration Hardcodée

<!-- Valeurs hardcodées connues dans le code.
     Exemple :
     - DB host dans config.php ligne 42
     - API key Stripe dans PaymentService.php ligne 117
     - Timeout à 30s dans 14 fichiers différents -->

## URLs / Endpoints Tiers

<!-- Services externes utilisés, leurs URLs, leurs états. -->

## Versions Toolchain

<!-- Versions actuelles — souvent contraintes en legacy. -->

## Crons en Production

<!-- Jobs planifiés actifs — souvent non documentés en legacy.
     Exemple :
     - 0 2 * * * php bin/process_orders.php (depuis 2016, personne ne sait ce que ça fait)
     - */5 * * * * scripts/sync_users.sh -->
