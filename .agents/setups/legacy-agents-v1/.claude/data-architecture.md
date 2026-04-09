# Data Architecture

<!-- last-verified: YYYY-MM-DD -->

## État de la Base de Données

<!-- Évaluation honnête.
     Exemple :
     - 287 tables, dont ~40 utilisées activement
     - Pas de FK en production (désactivées pour "performance")
     - Colonnes type TEXT pour tout (int, date, json stockés en TEXT)
     - Pas de migrations formelles : ALTER TABLE directs en prod -->

## Tables Principales

<!-- Tables critiques, leur rôle réel, leur état.
     Exemple :
     users        — comptes, mais aussi config, préférences, flags divers
     orders       — commandes + historique + logs + temp data
     settings     — table clé/valeur qui remplace la config (156 entrées)
     temp_*       — tables temporaires jamais supprimées -->

## Conventions Existantes (ou absences de conventions)

<!-- Ce qui a été fait, même si c'est mauvais.
     Connaître les conventions existantes évite de les casser accidentellement.
     Exemple :
     - Pas de soft delete : DELETE direct partout
     - IDs : AUTO_INCREMENT int (pas UUID)
     - Dates : DATETIME sans timezone (tout en UTC supposé)
     - Passwords : MD5 (oui, vraiment) -->

## Migrations

<!-- Comment les changements BDD ont été faits jusqu'ici.
     Exemple :
     - Pas de système de migration
     - Scripts SQL dans /scripts/db/ (pas tous documentés)
     - Certains changements faits directement en prod et jamais documentés -->

## Données Sensibles

<!-- Où sont les données sensibles, comment elles sont (mal) protégées. -->

## Requêtes Critiques / Connues

<!-- Requêtes importantes ou dangereuses à connaître.
     Exemple :
     - La requête du dashboard charge 50k rows sans pagination
     - Le rapport mensuel tourne 45 min et locke des tables -->
