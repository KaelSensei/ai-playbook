# Non-Functional Criteria — Templates

## Performance

```markdown
### Performance Criteria — [Feature]

#### Response time

| Opération             | p50     | p95     | p99    |
| --------------------- | ------- | ------- | ------ |
| Chargement page liste | < 500ms | < 1s    | < 2s   |
| Soumission formulaire | < 300ms | < 800ms | < 1.5s |
| Recherche             | < 200ms | < 500ms | < 1s   |

Conditions : mesurées avec 100 utilisateurs simultanés, données de production simulées (10 000
réservations).

#### Charge

| Scénario     | Utilisateurs simultanés | Comportement attendu                                      |
| ------------ | ----------------------- | --------------------------------------------------------- |
| Nominal      | 50                      | Temps de réponse dans les limites ci-dessus               |
| Pic          | 200                     | Dégradation acceptable : p95 × 2 max                      |
| Exceptionnel | 500                     | Pas de crash. File d'attente ou message d'erreur dégradé. |
```

## Accessibility

```markdown
### Accessibility Criteria

Standard minimum : WCAG 2.1 niveau AA

Obligatoire :

- Tous les éléments interactifs accessibles au clavier (Tab, Shift+Tab, Enter, Space)
- Focus visible sur tous les éléments interactifs
- Ratio de contraste ≥ 4.5:1 pour le texte (normal), ≥ 3:1 pour les grands textes
- Labels associés à tous les champs de formulaire
- Messages d'erreur annoncés aux lecteurs d'écran (aria-live ou focus)
- Images informatives ont un alt text. Images décoratives alt=""
- Pas d'information transmise uniquement par la couleur
```

## Security

```markdown
### Security Criteria — [Feature]

Authentification et Autorisation :

- [RG-SEC-01] Seul le propriétaire peut annuler sa réservation Exception : les admins peuvent
  annuler n'importe quelle réservation
- [RG-SEC-02] Un utilisateur non connecté est redirigé vers la page de connexion

Données :

- [RG-SEC-03] Aucune donnée sensible dans les URLs (pas de token, email, etc.)
- [RG-SEC-04] Les confirmations d'annulation ne contiennent que les infos nécessaires (pas de
  données de carte bancaire, même partielles)

Validation :

- [RG-SEC-05] Toutes les entrées utilisateur sont validées côté serveur (même si validées côté
  client)
```
