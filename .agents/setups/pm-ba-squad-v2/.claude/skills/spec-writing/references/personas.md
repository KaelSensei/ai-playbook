# Personas — Template and Examples

## Persona Template

```markdown
## [First name] — [Role/Title]

### Contexte

[2-3 phrases : qui est cette personne, dans quel contexte elle utilise le produit]

### Objectifs principaux

1. [Ce qu'elle veut accomplir avec le produit]
2. [Son objectif secondaire]

### Frustrations actuelles

- [Ce qui l'énerve dans le processus actuel]
- [Ce qui lui fait perdre du temps]

### Comportement digital

[Comment elle utilise la technologie : mobile-first ? desktop ? fréquence ?]

### Representative quote

"[Ce qu'elle dirait pour résumer son besoin]"

### Features they care most about

- [Feature 1] : [pourquoi c'est critique pour elle]
- [Feature 2] : [pourquoi]
```

---

## Example — Travel Booking Platform

```markdown
## Marie — Regular Traveller (35, employed)

### Contexte

Marie voyage 4 à 6 fois par an pour des voyages personnels. Elle réserve depuis son smartphone dans
les transports. Elle a déjà eu une mauvaise expérience d'annulation difficile avec un concurrent.

### Objectifs principaux

1. Réserver rapidement sans surprises de prix
2. Pouvoir annuler facilement si ses plans changent
3. Avoir un historique clair de ses voyages et remboursements

### Frustrations actuelles

- Ne comprend pas les politiques d'annulation avant d'avoir réservé
- Doit appeler le service client pour toute modification
- Les emails de confirmation sont illisibles sur mobile

### Comportement digital

Mobile-first (80% des actions sur smartphone). Utilise principalement l'app entre 7h et 9h et après
20h. Attend un retour visuel immédiat sur chaque action.

### Representative quote

"Je veux juste savoir ce qui se passe si j'annule, avant de payer."

### Features critiques pour Marie

- Politique d'annulation visible AVANT le paiement
- Annulation en ligne sans appel téléphonique
- Remboursement rapide et tracé
```

```markdown
## Thomas — Gestionnaire de voyages d'affaires (42 ans, PME)

### Contexte

Thomas organise les voyages de 15 commerciaux dans une PME. Il doit justifier chaque dépense et
gérer les remboursements de notes de frais. Il accède à la plateforme depuis son desktop au bureau.

### Objectifs principaux

1. Réserver pour plusieurs personnes en une session
2. Obtenir des justificatifs fiscaux conformes (TVA, mentions légales)
3. Avoir une vision centralisée des dépenses voyages

### Frustrations actuelles

- Doit créer un compte par voyageur → gestion impossible
- Les factures PDF ne contiennent pas le numéro de TVA intracommunautaire
- Pas de vue consolidée : dépenses du mois, par voyageur, par destination

### Comportement digital

Desktop exclusif. Utilise des spreadsheets pour le suivi. Sensible à la fiabilité : pas de bugs, pas
de surprises.

### Representative quote

"Si je dois appeler le support pour avoir une facture correcte, je change de solution."

### Features critiques pour Thomas

- Compte entreprise avec plusieurs voyageurs rattachés
- Factures conformes en PDF téléchargeables
- Dashboard dépenses avec export CSV
```

---

## Using Personas in Specs

```markdown
# Dans une user story

En tant que Marie (voyageuse régulière sur mobile), je veux voir la politique d'annulation avant de
payer, afin de décider en connaissance de cause si je réserve.

# Dans les CAs — contexte du persona

Scenario: Marie voit la politique avant paiement sur mobile Given je suis sur la fiche d'un
hébergement sur mobile When je clique "Réserver" Then avant la page de paiement, je vois clairement
: "Annulation gratuite jusqu'au [date à 48h]" And je peux revenir en arrière sans perdre ma
sélection
```
