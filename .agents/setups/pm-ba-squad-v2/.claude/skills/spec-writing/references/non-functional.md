# Non-Functional Criteria — Templates

## Performance

```markdown
### Performance Criteria — [Feature]

#### Response time

| Operation       | p50     | p95     | p99    |
| --------------- | ------- | ------- | ------ |
| List page load  | < 500ms | < 1s    | < 2s   |
| Form submission | < 300ms | < 800ms | < 1.5s |
| Search          | < 200ms | < 500ms | < 1s   |

Conditions: measured with 100 concurrent users, simulated production data (10,000 bookings).

#### Load

| Scenario    | Concurrent users | Expected behaviour                                  |
| ----------- | ---------------- | --------------------------------------------------- |
| Nominal     | 50               | Response times within the limits above              |
| Peak        | 200              | Acceptable degradation: p95 × 2 max                 |
| Exceptional | 500              | No crash. Queue or graceful degraded error message. |
```

## Accessibility

```markdown
### Accessibility Criteria

Minimum standard: WCAG 2.1 level AA

Mandatory:

- All interactive elements keyboard-accessible (Tab, Shift+Tab, Enter, Space)
- Visible focus on all interactive elements
- Contrast ratio >= 4.5:1 for text (normal), >= 3:1 for large text
- Labels associated with every form field
- Error messages announced to screen readers (aria-live or focus)
- Informative images have alt text. Decorative images use alt=""
- No information conveyed by colour alone
```

## Security

```markdown
### Security Criteria — [Feature]

Authentication and Authorisation:

- [BR-SEC-01] Only the owner can cancel their booking. Exception: admins can cancel any booking.
- [BR-SEC-02] An unauthenticated user is redirected to the login page

Data:

- [BR-SEC-03] No sensitive data in URLs (no tokens, emails, etc.)
- [BR-SEC-04] Cancellation confirmations only include necessary information (no payment card data,
  even partial)

Validation:

- [BR-SEC-05] All user input is validated server-side (even if already validated client-side)
```
