# Gherkin Scenario Naming Conventions

## Principle

A scenario name follows "[result] in [context]" or "[result] when [condition]". It must be readable
without reading the steps.

## Pattern: Result + Condition

```gherkin
# Good — Result → Condition
"Full refund if cancellation more than 48h before departure"
"50% refund if cancellation between 24h and 48h"
"Registration rejected if email already used"
"Redirect to dashboard after successful login"
"Error displayed if password is invalid"

# Too vague — does not describe the result
"Booking cancellation"
"Login form test"
"Password check"

# Describes steps, not behaviour
"User clicks cancel and sees a message"
"Enter email then click submit"
```

## By Scenario Type

### Happy path

```gherkin
"Successful registration with a valid email and strong password"
"Successful login with correct credentials"
"Full refund for early cancellation"
"Correct total price calculation for a standard product"
```

### Validation / Rejection

```gherkin
"Registration rejected for invalid email format"
"Registration rejected for password without a digit"
"Cancellation rejected for already-cancelled booking"
"Explicit error message for missing required field"
```

### Boundary case

```gherkin
"Full refund for cancellation exactly at 48h (inclusive boundary)"
"Partial refund for cancellation at 48h minus one second"
"Empty cart after removing the last item"
"Pagination: last page with fewer items than pageSize"
```

### Authorisation

```gherkin
"Access denied to the user list without the admin role"
"Admin can see all travellers' bookings"
"Traveller can only cancel their own bookings"
```

### Technical error / degradation

```gherkin
"Generic error message when the payment service is unavailable"
"Form data preserved after server error"
"Automatic retry when the notification email fails"
```

## Consistency within a Feature

```gherkin
Feature: Refund policy

# Consistent naming: "[Refund rate] if [time condition]"
Scenario: 100% refund if cancellation more than 48h before
Scenario: 50% refund if cancellation between 24h and 48h
Scenario: 0% refund if cancellation less than 24h before
Scenario: 100% refund if cancellation exactly at 48h (inclusive boundary)
Scenario: 100% refund if cancellation caused by the provider
Scenario: Cancellation refused if booking is in progress
```
