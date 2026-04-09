# Legacy Map

<!-- last-verified: YYYY-MM-DD -->
<!--
  Document vivant. Mis à jour par /understand et /characterize.
  C'est la carte du territoire — elle est toujours incomplète,
  mais elle grandit à chaque exploration.

  RÈGLE : ne jamais supprimer une entrée. Annoter si obsolète.
-->

## Modules Cartographiés

<!--
  Format par module :

  ### [nom du module / fichier]
  - **Localisation** : chemin/vers/fichier
  - **Taille** : ~N lignes
  - **Rôle réel** : ce qu'il fait réellement (basé sur le code, pas les commentaires)
  - **Responsabilités multiples** : liste si god class / god function
  - **Dépendances entrantes** : qui l'appelle
  - **Dépendances sortantes** : ce qu'il appelle
  - **Tests existants** : oui / non / partiels (fichier)
  - **Dernière modification** : date (git blame)
  - **Niveau de risque** : 🟢 faible / 🟡 moyen / 🔴 élevé
  - **Notes** : observations importantes, pièges identifiés
-->

## Seams Identifiés

<!--
  Un "seam" (Michael Feathers) = un endroit où on peut insérer
  un point de contrôle sans modifier le code qui l'entoure.

  Format :
  - **[nom]** : [description] — [comment l'exploiter]

  Exemple :
  - **Interface de paiement** : PaymentGateway.php — peut être mockée via config
  - **Envoi d'emails** : mailer global — peut être remplacé par un fake en test
-->

## Comportements Figés (Tests de Caractérisation)

<!--
  Liste des comportements documentés par des tests de caractérisation.
  Mis à jour par /characterize.

  Format :
  - [ ] [comportement] — [fichier de test] — [date]

  Exemple :
  - [x] billing calcule TVA à 20% sur produits non-exemptés — test_billing_char.php — 2024-03-15
  - [ ] comportement si utilisateur sans email — non documenté
-->

## Zones Non Explorées

<!--
  Ce qu'on sait qu'on ne sait pas.
  Mis à jour au fil des /understand.

  Exemple :
  - cron_sync.php — objectif inconnu, tourne en prod toutes les heures
  - legacy_import/ — dossier de 40 fichiers, aucune référence trouvée depuis 2021
-->

## Couplages Dangereux

<!--
  Dépendances circulaires, état global, variables de session magiques,
  tout ce qui rend les changements imprévisibles.

  Format :
  - [description du couplage] — [impact] — [fichiers impliqués]
-->

## Décisions Héritées

<!--
  Choix techniques passés qu'on a compris (même si on ne serait pas d'accord aujourd'hui).
  Documenter le "pourquoi" quand on le retrouve.

  Exemple :
  - Les prix sont stockés en centimes entiers — décision 2012 pour éviter les floats
  - La session PHP est utilisée comme base de données temporaire — contournement MySQL lent
-->
