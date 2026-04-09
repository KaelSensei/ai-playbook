---
name: acceptance-criteria
description: >
  Writing rigorous, testable, unambiguous acceptance criteria. Formats, quality levels, common
  mistakes, examples across insurance and travel domains. Loaded by product-owner and
  business-analyst.
---

# Acceptance Criteria — Complete Guide

---

## Core Principle

An acceptance criterion (AC) answers: **"How do we know the story is done?"**

It must be:

- **Testable**: someone can verify it is satisfied or not
- **Unambiguous**: one possible interpretation only
- **Independent**: understandable without additional context
- **Business-language**: written with domain vocabulary, not technical terms

---

## The 3 Formats

### Gherkin Scenario — Recommended for behaviours

```gherkin
Scenario: [Observable result in a context]
  Given [context — state of the world before the action]
  When  [user or system action]
  Then  [observable result — what the user sees/gets]
```

### Checklist — For simple validation rules

```
☐ Email is displayed in lowercase
☐ Date field rejects past dates
☐ Total updates immediately when an item is added
☐ "Confirm" button is disabled while the form is invalid
```

### Rule + Example — For calculations and thresholds

```
Rule: Refund is calculated on the total price excluding service fees
Example: booking €120 incl. tax, fees €5 → maximum refund = €115
Example: booking €50 incl. tax, fees €0 → maximum refund = €50
```

---

## AC Quality Levels

### ❌ Level 0 — Unusable

```
"The user can manage their booking"
"The system displays an appropriate message on error"
"The feature works correctly"
```

### ⚠️ Level 1 — Too vague

```
"The user can cancel their booking"
"An email is sent after cancellation"
"The user sees the refund amount"
```

### ✅ Level 2 — Good

```gherkin
Scenario: Cancellation confirmation with refund amount
  Given I have a confirmed booking of €120 incl. tax (fees €5)
  And my booking starts in 5 days
  When I cancel my booking
  Then I see: "Your booking has been cancelled."
  And I see: "Refund of €115 within 5 to 7 business days to your card."
  And my booking status shows "Cancelled"
```

### ✅✅ Level 3 — Excellent (covers boundaries and errors)

```gherkin
Scenario: Full refund for early cancellation
  Given I have a booking of €120 incl. tax with €5 service fee
  And my booking starts in 72 hours
  When I cancel
  Then the displayed refund is €115 (= 120 - 5, rate 100%)
  And the confirmation email mentions "€115 refunded within 5 to 7 business days"

Scenario: Cancellation between 24h and 48h — partial refund
  Given I have a booking of €120 incl. tax with €5 service fee
  And my booking starts in 36 hours
  When I cancel
  Then the displayed refund is €57.50 (= (120 - 5) × 50%)

Scenario: Attempting to cancel an already-cancelled booking
  Given my booking already has status "Cancelled"
  When I try to access the cancellation page
  Then I see: "This booking has already been cancelled."
  And I do not see a "Cancel" button
```

---

## ACs by Feature Type

### Form feature

```gherkin
Scenario: Real-time email validation
  Given I am on the registration form
  When I type "notvalid" in the email field and leave the field
  Then I see in red: "Invalid email address"
  And the "Register" button remains disabled

Scenario: Successful submission confirmation
  Given all fields are valid
  When I click "Register"
  Then the button shows "Registering..." and is disabled
  And after confirmation: I am redirected to "/onboarding"
  And I see: "Welcome! Check your email to confirm your account."

Scenario: Server error during submission
  Given all fields are valid
  And the server is unavailable
  When I click "Register"
  Then I see: "An error occurred. Please try again."
  And the form remains filled (data is not cleared)
  And the "Register" button is active again
```

### List/Table feature

```gherkin
Scenario: Empty list
  Given I have no bookings
  When I visit "My bookings"
  Then I see: "You don't have any bookings yet."
  And I see a "Make a booking" button

Scenario: Pagination
  Given I have 45 bookings
  When I visit "My bookings"
  Then I see the 20 most recent bookings (newest first)
  And I see "Page 1 of 3"
  And I see an active "Next" button and a disabled "Previous" button
```

---

## Common Mistakes to Fix

### AC testing implementation

```
❌ "The calculateRefund() method returns 115"
✅ "The displayed amount in the confirmation is €115"
```

### AC with ambiguous pronoun

```
❌ "It sends an email when she submits the form"
✅ "The system sends a confirmation email to the user upon successful submission"
```

### AC without concrete value

```
❌ "The refund is calculated correctly"
✅ "For a €100 incl. tax booking cancelled 5 days before: displayed refund = €95 (100 - €5 fee)"
```

### Conditional AC (if/then in one scenario)

```
❌ "If the user is admin they see all buttons, otherwise only View"
✅ Two separate scenarios: one for admin, one for standard user
```
