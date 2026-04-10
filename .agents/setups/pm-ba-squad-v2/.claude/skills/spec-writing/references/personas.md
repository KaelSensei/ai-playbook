# Personas — Template and Examples

## Persona Template

```markdown
## [First name] — [Role/Title]

### Context

[2-3 sentences: who this person is, in what context they use the product]

### Primary goals

1. [What they want to accomplish with the product]
2. [Their secondary goal]

### Current frustrations

- [What annoys them in the current process]
- [What wastes their time]

### Digital behaviour

[How they use technology: mobile-first? desktop? frequency?]

### Representative quote

"[What they would say to sum up their need]"

### Features they care most about

- [Feature 1]: [why it is critical for them]
- [Feature 2]: [why]
```

---

## Example — Travel Booking Platform

```markdown
## Marie — Regular Traveller (35, employed)

### Context

Marie takes 4 to 6 personal trips a year. She books from her smartphone while commuting. She has
already had a bad experience with a difficult cancellation on a competitor's platform.

### Primary goals

1. Book quickly without price surprises
2. Be able to cancel easily if her plans change
3. Keep a clear history of her trips and refunds

### Current frustrations

- Does not understand cancellation policies before booking
- Has to call customer service for any change
- Confirmation emails are unreadable on mobile

### Digital behaviour

Mobile-first (80% of actions on smartphone). Mainly uses the app between 7am and 9am and after 8pm.
Expects immediate visual feedback on every action.

### Representative quote

"I just want to know what happens if I cancel, before I pay."

### Features critical for Marie

- Cancellation policy visible BEFORE payment
- Online cancellation without a phone call
- Fast and traceable refund
```

```markdown
## Thomas — Business Travel Manager (42, SMB)

### Context

Thomas organises trips for 15 salespeople in an SMB. He has to justify every expense and handle
expense report reimbursements. He accesses the platform from his office desktop.

### Primary goals

1. Book for several people in one session
2. Get tax-compliant invoices (VAT, legal mentions)
3. Have a centralised view of travel spend

### Current frustrations

- Has to create one account per traveller → impossible to manage
- PDF invoices do not include the intra-community VAT number
- No consolidated view: spend per month, per traveller, per destination

### Digital behaviour

Desktop only. Uses spreadsheets for tracking. Sensitive to reliability: no bugs, no surprises.

### Representative quote

"If I have to call support to get a correct invoice, I switch solutions."

### Features critical for Thomas

- Company account with multiple travellers attached
- Compliant PDF invoices that can be downloaded
- Spend dashboard with CSV export
```

---

## Using Personas in Specs

```markdown
# In a user story

As Marie (regular mobile traveller), I want to see the cancellation policy before I pay, so that I
can decide in full awareness whether to book.

# In the ACs — persona context

Scenario: Marie sees the policy before payment on mobile Given I am on an accommodation page on
mobile When I click "Book" Then before the payment page, I clearly see: "Free cancellation until
[date at 48h]" And I can go back without losing my selection
```
