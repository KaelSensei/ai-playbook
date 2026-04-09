---
name: bdd-gherkin
description: >
  Complete BDD Gherkin guide — writing rich scenarios, Given/When/Then, Scenario Outline,
  Background, Rules. Anti-patterns and real examples. Loaded by product-owner, business-analyst,
  spec-reviewer.
---

# BDD Gherkin — Complete Guide

Source: Dan North, _Introducing BDD_ (2006) + Gáspár Nagy & Seb Rose, _The BDD Books_ (2018-2021)

---

## Core Principle

> A BDD scenario is a **captured conversation**, not a technical specification. It must be readable
> and verifiable by someone who doesn't code. If the scenario contains a class name, a URL, or a
> database attribute → it is too technical.

---

## Given / When / Then Structure

```
Given  → state of the world BEFORE the action (context, preconditions)
When   → the action that triggers the tested behaviour
Then   → observable result AFTER the action (postconditions)
And    → continuation of a Given, When or Then
But    → negative continuation
```

### Critical rules

- **One When per scenario** — one action = one behaviour
- **Then describes an observable result**, not an internal state
- **Given describes a state**, not a past action (not "Given the user clicked")
- **No technical details** in the steps

---

## Real Examples — Good vs Bad

### Feature: User registration

```gherkin
Feature: New user registration
  As a visitor
  I want to create an account
  So that I can access the application features

  # ✅ GOOD — business language, observable behaviour
  Scenario: Successful registration with valid data
    Given I am on the registration page
    When I fill in the form with email "alice@example.com" and a valid password
    Then my account is created
    And I am redirected to the dashboard
    And I receive a welcome email

  # ❌ BAD — too technical, cannot be validated by business
  Scenario: POST /api/users returns 201
    Given a POST request to /api/users
    When the request body contains {"email": "alice@example.com", "password": "Pass1!"}
    Then the response status is 201
    And the database contains a user with email "alice@example.com"

  # ✅ GOOD — error case with user-visible message
  Scenario: Rejection when email address is already taken
    Given an account exists with email "alice@example.com"
    When I attempt to register with email "alice@example.com"
    Then I see the message "This email address is already in use"
    And no new account is created

  # ✅ GOOD — explicit business rule with boundary
  Scenario: Rejection when password is too weak
    Given I am on the registration page
    When I fill in the form with password "abc"
    Then I see an error stating the password must contain at least 8 characters
    And my account is not created
```

### Scenario Outline — Parametrised Rules

```gherkin
Feature: Travel insurance rate calculation

  Rule: Insurance rate depends on duration and traveller profile

    Scenario Outline: Rate calculation by profile
      Given I am a traveller of type "<profile>"
      And my booking is <duration> nights
      When I request an insurance quote
      Then the proposed rate is <rate>

      Examples:
        | profile       | duration | rate  |
        | Standard      | 7        | 3.5%  |
        | Standard      | 14       | 3.0%  |
        | Premium       | 7        | 2.0%  |
        | Premium       | 14       | 1.5%  |
        | Senior (65+)  | 7        | 5.0%  |
        | Senior (65+)  | 14       | 4.5%  |
```

### Background — Shared Context

```gherkin
Feature: Booking management

  Background:
    Given I am logged in as "Marie Dupont"
    And I have a confirmed booking with reference "RES-2024-0042"

  Scenario: Cancellation within 48h
    Given my booking starts in 72 hours
    When I cancel my booking
    Then I am refunded 100%
    And I receive a cancellation confirmation email

  Scenario: Late cancellation
    Given my booking starts in 24 hours
    When I cancel my booking
    Then I am refunded 50%
    And the 50% cancellation fee is clearly displayed
```

### Rule — Documenting Business Rules

```gherkin
Feature: Cancellation policy

  Rule: Free cancellations are possible up to 48h before departure

    Scenario: Cancellation 3 days before — free
      Given I have a booking starting in 3 days
      When I cancel
      Then the refund is 100%

    Scenario: Cancellation exactly 48h before — free (inclusive boundary)
      Given I have a booking starting in exactly 48 hours
      When I cancel
      Then the refund is 100%

  Rule: Beyond 48h, cancellation fees apply progressively

    Scenario: Cancellation between 24h and 48h — 50% refund
      Given I have a booking starting in 36 hours
      When I cancel
      Then the refund is 50%

    Scenario: Cancellation less than 24h before — no refund
      Given I have a booking starting in 12 hours
      When I cancel
      Then the refund is 0%
      And a message explains that the free cancellation window has passed
```

---

## Anti-Patterns to Avoid

### Scenarios that are too technical

```gherkin
# ❌ Business cannot validate this
Scenario: API returns correct JWT
  Given a valid user exists in the database with id "abc123"
  When POST /api/auth/login is called with email and password
  Then the response contains a JWT with sub claim "abc123"
```

### Steps that are too long and complex

```gherkin
# ❌ One When doing 3 actions
When I click "Register", fill the form with "alice@test.com"
     and "MyPassword1!" and tick the ToS and submit

# ✅ Clear and separate
Given I am on the registration page
When I register with email "alice@test.com" and a valid password
Then my account is created
```

### Scenarios without business value

```gherkin
# ❌ Tests implementation, not behaviour
Scenario: User model has correct properties
  Given a user object
  Then it has an email property
  And it has a createdAt property
```

---

## Golden Rules for a Good Scenario

```
1. One scenario = one behaviour = one reason to fail
2. Named as "Result in Context"
   e.g. "Full refund if cancellation before 48h"
3. Readable by the product owner without explanation
4. Concrete examples (real values, not placeholders)
5. Boundary cases documented (exactly 48h)
6. Independent of other scenarios
7. No conditional logic (no "if X then Y")
```

---

## Available References

- `references/step-definitions.md` — TypeScript step implementations
- `references/cucumber-setup.md` — Cucumber.js/Jest-Cucumber configuration
- `references/scenario-naming.md` — naming conventions by type
- `references/examples-tables.md` — best practices for data tables
