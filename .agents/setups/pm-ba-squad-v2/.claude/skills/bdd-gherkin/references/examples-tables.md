# Gherkin Examples Tables — Best Practices

## When to Use Scenario Outline + Examples

```gherkin
# ✅ Good usage — same behaviour, different data
Scenario Outline: Calcul du taux de remboursement selon le délai d'annulation
  Given j'annule ma réservation de <montant_ttc>€ TTC avec <frais_service>€ de frais
  And le départ est dans <heures_restantes> heures
  When le calcul de remboursement est effectué
  Then le montant remboursé est <montant_remboursement>€

  Examples:
    | montant_ttc | frais_service | heures_restantes | montant_remboursement |
    | 120         | 5             | 72               | 115                   |
    | 120         | 5             | 36               | 57.50                 |
    | 120         | 5             | 12               | 0                     |
    | 200         | 5             | 72               | 195                   |
    | 50          | 0             | 72               | 50                    |

# ❌ Bad usage — different behaviours → separate scenarios
Scenario Outline: Gestion de la réservation
  Given <situation>
  When <action>
  Then <résultat>

  Examples:
    | situation             | action   | résultat                  |
    | réservation confirmée | annuler  | remboursement effectué    |
    | réservation annulée   | consulter | afficher le remboursement |
    | réservation en cours  | annuler  | refus de l'annulation     |
# → 3 different behaviours = 3 separate scenarios
```

## Column Structure

```gherkin
# ✅ Columns named in snake_case — readable, no spaces
Examples:
  | email_utilisateur    | mot_de_passe | code_erreur_attendu |
  | invalid              | Pass1!       | INVALID_EMAIL       |
  | user@test.com        | abc          | WEAK_PASSWORD       |
  | taken@test.com       | Pass1!       | EMAIL_ALREADY_EXISTS|

# ✅ Plusieurs groupes d'exemples avec labels
Scenario Outline: Validation du mot de passe
  Given je tente de m'inscrire avec le mot de passe "<mot_de_passe>"
  Then je vois l'erreur "<message_erreur>"

  # Cas trop courts
  Examples: Longueur insuffisante
    | mot_de_passe | message_erreur                          |
    | abc          | 8 caractères minimum requis             |
    | 1234567      | 8 caractères minimum requis             |

  # Cas sans caractères requis
  Examples: Complexité insuffisante
    | mot_de_passe | message_erreur                          |
    | alllowercase | Une majuscule est requise               |
    | ALLUPPERCASE | Un chiffre est requis                   |
    | NoSpecial1   | Un caractère spécial est requis         |

  # Cas valides
  Examples: Mots de passe acceptés
    | mot_de_passe | message_erreur |
    | Pass1!xy     |                |
    | Str0ng#Pass  |                |
```

## Complex Data — Doc String and DataTable

```gherkin
# DataTable pour des listes de valeurs multiples
Scenario: Commande avec plusieurs articles
  Given mon panier contient les articles suivants :
    | article          | prix_unitaire | quantité |
    | Laptop           | 999.99        | 1        |
    | Souris sans fil  | 49.99         | 2        |
    | Tapis de souris  | 19.99         | 1        |
  When je valide ma commande
  Then le total HT est 1089.96€
  And le total TTC est 1307.95€

# Doc String pour du contenu textuel long
Scenario: Email de confirmation d'annulation
  Given j'ai annulé ma réservation RES-2024-042
  When l'email de confirmation est envoyé
  Then l'email contient le texte suivant :
    """
    Votre réservation RES-2024-042 a été annulée.
    Montant remboursé : 115,00€
    Délai de remboursement : 5 à 7 jours ouvrés
    """
```

## Anti-Patterns with Tables

```gherkin
# ❌ Too many columns — scenario unreadable
Examples:
  | id | email | pwd | role | country | verified | deleted | plan | trial |
  | 1  | a@b   | P1! | USER | FR      | true     | false   | FREE | false |

# ✅ Limit to 3-5 columns max — others are defaults

# ❌ Production data in examples
Examples:
  | email              | carte              |
  | jean.dupont@xxx.fr | 4111111111111111   |
  # → données réelles = risque, utiliser des données fictives explicitement fausses

# ✅ Clearly fictional test data
Examples:
  | email                | carte_test         |
  | testuser@example.com | 4242424242424242   |
  # 4242... = numéro de test Stripe officiel
```
