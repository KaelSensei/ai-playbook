# Domain Glossary — Template

## How to Use This File

Ce fichier est la **source de vérité du vocabulaire** du projet. Tout terme utilisé dans une spec
doit être défini ici ou référencer ce glossaire.

Règles :

- Ajouter tout nouveau terme métier lors de la rédaction d'une spec
- Signaler les ambiguïtés et les faux synonymes
- Valider les définitions avec les experts métier, pas seulement les devs

---

## Entry Template

```markdown
### [Terme canonique]

**Définition** : [Description précise dans le contexte du projet] **Exemples** :

- [Exemple 1]
- [Exemple 2] **Ne pas confondre avec** : [Terme proche mais différent] **Termes rejetés** : [Ce
  qu'on n'utilisera PAS — et pourquoi] **Contexte d'utilisation** : [Features ou domaines où ce
  terme apparaît]
```

---

## Glossary Template — E-commerce / Booking Domain

> Copier-coller ce bloc comme point de départ, puis adapter au projet réel

### Commande

**Définition** : Achat formalisé d'un ou plusieurs produits par un client, donnant lieu à un
paiement et une livraison. **Exemples** :

- Commande de 3 articles passée le 15 mars, livrée le 18 mars **Ne pas confondre avec** :
  Réservation (prestation future), Devis (non-engageant) **Termes rejetés** : "order" (anglicisme),
  "achat" (trop générique)

### Utilisateur

**Définition** : Personne ayant un compte sur la plateforme. Recouvre plusieurs rôles : client,
administrateur, support. **Ne pas confondre avec** :

- "Client" : sous-ensemble des utilisateurs ayant passé au moins une commande
- "Visiteur" : personne non-connectée, sans compte **Termes rejetés** : "user" (anglicisme),
  "membre" (connotation club/abonnement)

### Panier

**Définition** : Sélection temporaire d'articles par un utilisateur, non encore confirmée. Le panier
est lié à la session et peut expirer. **Ne pas confondre avec** : Commande (engagement finalisé)
**Termes rejetés** : "cart" (anglicisme), "sélection" (trop vague)

### Remboursement

**Définition** : Restitution de tout ou partie du montant payé par le client, suite à une annulation
ou un litige. **Ne pas confondre avec** :

- "Avoir" : crédit sur le compte, utilisable en futur achat
- "Compensation" : geste commercial unilatéral **Termes rejetés** : "refund" (anglicisme)

---

## Empty Entries — To Be Filled by the Team

> Remplacer ce bloc par les termes du domaine réel du projet

### [Terme 1]

**Définition** : À définir **Statut** : 🔴 Non validé

### [Terme 2]

**Définition** : À définir **Statut** : 🔴 Non validé

---

## False Friends — Terms That Must Always Be Defined

Liste de termes qui semblent clairs mais sont systématiquement ambigus dans les projets. Les définir
dès le début :

```
"Valider"     → Valider par qui ? Le système ? Un humain ? Quelle action déclenche ?
"Actif"       → Actif = non-supprimé ? ou actif = abonnement en cours ?
"Modifier"    → Modifier = un seul champ ? Tout le profil ? Déclenche-t-il une notification ?
"Envoyer"     → Email ? Push notification ? SMS ? Les trois ?
"Archiver"    → Soft delete ? Changer de statut ? Visible côté admin seulement ?
"Confirmer"   → Par l'utilisateur ? Par le prestataire ? Par le système ?
"Statut"      → Quel enum exact ? Les valeurs sont-elles dans ce glossaire ?
```
