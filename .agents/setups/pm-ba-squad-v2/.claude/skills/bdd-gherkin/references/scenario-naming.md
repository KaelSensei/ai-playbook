# Gherkin Scenario Naming Conventions

## Principle

Le nom d'un scénario = "[résultat] dans [contexte]" ou "[résultat] quand [condition]" Il doit être
lisible sans lire les steps.

## Pattern: Result + Condition

```gherkin
# ✅ Result → Condition
"Remboursement total si annulation plus de 48h avant le départ"
"Remboursement 50% si annulation entre 24h et 48h"
"Refus d'inscription si email déjà utilisé"
"Redirection vers dashboard après connexion réussie"
"Affichage d'erreur si mot de passe invalide"

# ❌ Too vague — does not describe the result
"Annulation de réservation"
"Test du formulaire de connexion"
"Vérification du mot de passe"

# ❌ Describes steps, not behaviour
"L'utilisateur clique sur annuler et voit un message"
"Saisie email puis clic sur soumettre"
```

## By Scenario Type

### Happy path

```gherkin
"Inscription réussie avec un email valide et mot de passe fort"
"Connexion réussie avec identifiants corrects"
"Remboursement total pour annulation anticipée"
"Calcul correct du prix TTC pour produit standard"
```

### Validation / Rejection

```gherkin
"Refus d'inscription pour email avec format invalide"
"Refus d'inscription pour mot de passe sans chiffre"
"Refus d'annulation pour réservation déjà annulée"
"Message d'erreur explicite pour champ obligatoire manquant"
```

### Boundary case

```gherkin
"Remboursement total pour annulation exactement à 48h (borne incluse)"
"Remboursement partiel pour annulation à 48h moins une seconde"
"Panier vide après suppression du dernier article"
"Pagination : dernière page avec moins d'items que pageSize"
```

### Authorisation

```gherkin
"Refus d'accès à la liste des utilisateurs sans rôle admin"
"Admin peut voir les réservations de tous les voyageurs"
"Voyageur ne peut annuler que ses propres réservations"
```

### Technical error / degradation

```gherkin
"Message d'erreur générique si le service de paiement est indisponible"
"Données du formulaire conservées après erreur serveur"
"Retry automatique si la notification email échoue"
```

## Consistency within a Feature

```gherkin
Feature: Politique de remboursement

# Consistent naming : "[Taux de remboursement] si [condition temporelle]"
Scenario: Remboursement 100% si annulation plus de 48h avant
Scenario: Remboursement 50% si annulation entre 24h et 48h
Scenario: Remboursement 0% si annulation moins de 24h avant
Scenario: Remboursement 100% si annulation exactement à 48h (borne incluse)
Scenario: Remboursement 100% si annulation imputable au prestataire
Scenario: Refus d'annulation si réservation en cours
```
