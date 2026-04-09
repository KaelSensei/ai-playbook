# Project Architecture

<!-- last-verified: YYYY-MM-DD -->
<!-- STALENESS RULE: si today - last-verified > 30 jours → STALE.
     Explorer le codebase directement. Ne pas faire confiance au doc. -->

## Vue d'ensemble

<!-- Ce que fait l'application, qui l'utilise, quelle valeur elle a.
     Inclure : âge estimé, historique des équipes si connu. -->

## État du Codebase

<!-- Évaluation honnête du codebase actuel.
     Exemple :
     - Coverage : ~12%
     - Dernière refonte majeure : 2019
     - Zones stables : [liste]
     - Zones à éviter : [liste]
     - Dépendances mortes : [liste]
     - Patterns dominants : [e.g. God Classes, Spaghetti, Copier-coller] -->

## Map des Modules

<!-- Modules principaux, leur responsabilité supposée, leur état.
     Exemple :
     src/
     ├── UserManager.php     — auth + profil + billing + emails (GOD CLASS)
     ├── OrderProcessor.php  — commandes + stock + PDF + envoi mail
     ├── utils/              — 847 fonctions utilitaires non triées
     └── legacy/             — ne pas toucher, surtout pas -->

## Points d'Entrée Connus

<!-- Comment les requêtes entrent dans le système.
     Exemple :
     - HTTP : index.php → router.php → controllers/
     - Cron : cron/ → jobs/
     - CLI : bin/ → commands/ -->

## Zones à Risque

<!-- Code qui ne doit pas être touché sans filet complet.
     Exemple :
     - billing/ : logique de facturation, aucun test, 4000 lignes
     - auth/ : sessions custom, fragile
     - imports/ : ETL qui tourne en production la nuit -->

## Dépendances Externes

<!-- Services, APIs, bibliothèques critiques.
     Inclure les versions et l'état de maintenance. -->

## Ce qui Fonctionne

<!-- Ce qui est stable et ne doit pas être touché sans raison. -->

## Ce qui Est Cassé / Contourné

<!-- Workarounds connus, bugs connus non corrigés, comportements "normaux mais faux". -->
