# Cucumber.js + Jest-Cucumber Configuration — TypeScript

## Option A: Jest-Cucumber (recommended — integrated with Jest/Vitest)

```bash
npm install --save-dev jest-cucumber
```

```typescript
// features/booking-cancellation.feature — Gherkin file
Feature: Booking cancellation

  Scenario: Full refund for early cancellation
    Given I have a confirmed booking of EUR 120 incl. tax with a EUR 5 service fee
    And my booking starts in 72 hours
    When I cancel my booking
    Then the displayed refund is EUR 115
    And I receive a cancellation confirmation email
```

```typescript
// features/steps/booking-cancellation.steps.ts
import { defineFeature, loadFeature } from 'jest-cucumber';
import { CancelBooking } from '../../src/application/use-cases/CancelBooking';
import { InMemoryBookingRepository } from '../../src/infrastructure/InMemoryBookingRepository';
import { aBooking, hoursFromNow } from '../fixtures/bookings';

const feature = loadFeature('./features/booking-cancellation.feature');

defineFeature(feature, (test) => {
  let cancelBooking: CancelBooking;
  let bookingRepo: InMemoryBookingRepository;
  let emailSpy: SpyEmailService;
  let booking: Booking;
  let result: CancellationResult;

  beforeEach(() => {
    bookingRepo = new InMemoryBookingRepository();
    emailSpy = new SpyEmailService();
    cancelBooking = new CancelBooking(bookingRepo, emailSpy, new InMemoryEventBus());
  });

  test('Full refund for early cancellation', ({ given, and, when, then }) => {
    given('I have a confirmed booking of EUR 120 incl. tax with a EUR 5 service fee', async () => {
      booking = aBooking({ totalInclTax: 120, serviceFees: 5, status: 'confirmed' });
      await bookingRepo.save(booking);
    });

    and('my booking starts in 72 hours', () => {
      booking.departureDate = hoursFromNow(72);
      bookingRepo.update(booking);
    });

    when('I cancel my booking', async () => {
      result = await cancelBooking.execute({ bookingId: booking.id, userId: booking.userId });
    });

    then('the displayed refund is EUR 115', () => {
      expect(result.refundAmount).toBe(115);
    });

    and('I receive a cancellation confirmation email', () => {
      expect(emailSpy.sent).toHaveLength(1);
      expect(emailSpy.sent[0]).toMatchObject({
        to: booking.userEmail,
        subject: expect.stringContaining('cancellation'),
        body: expect.stringContaining('115'),
      });
    });
  });
});
```

## Option B: Cucumber.js Standalone

```bash
npm install --save-dev @cucumber/cucumber ts-node
```

```json
// .cucumber.json
{
  "default": {
    "paths": ["features/**/*.feature"],
    "require": ["features/steps/**/*.ts"],
    "requireModule": ["ts-node/register"],
    "format": ["progress", "html:reports/cucumber.html"],
    "publishQuiet": true
  }
}
```

```typescript
// features/steps/booking.steps.ts
import { Given, When, Then, Before } from '@cucumber/cucumber';
import { DataTable } from '@cucumber/cucumber';

let cancelBooking: CancelBooking;
let lastResult: CancellationResult;
let lastError: Error | null;

Before(() => {
  // Reset state between each scenario
  const repo = new InMemoryBookingRepository();
  cancelBooking = new CancelBooking(repo, new SpyEmailService(), new InMemoryEventBus());
  lastError = null;
});

Given(
  'I have a confirmed booking of EUR {int} incl. tax with a EUR {int} service fee',
  async (totalInclTax: number, serviceFees: number) => {
    const booking = aBooking({ totalInclTax, serviceFees, status: 'confirmed' });
    await bookingRepo.save(booking);
  }
);

When('I cancel my booking', async () => {
  try {
    lastResult = await cancelBooking.execute({ bookingId: currentBooking.id });
  } catch (error) {
    lastError = error as Error;
  }
});

Then('the displayed refund is EUR {int}', (expectedAmount: number) => {
  expect(lastResult.refundAmount).toBe(expectedAmount);
});

Then('I see the error {string}', (expectedMessage: string) => {
  expect(lastError).not.toBeNull();
  expect(lastError!.message).toContain(expectedMessage);
});
```

## Scenario Outline — Step Implementation

```typescript
// Feature with a data table
// Scenario Outline: Refund calculation based on timing
//   Given I have a booking of EUR <amount> incl. tax with EUR <fees> in service fees
//   And my booking starts in <hours> hours
//   When I cancel
//   Then the refund is EUR <refund>
//   Examples:
//     | amount | fees | hours | refund |
//     | 120    | 5    | 72    | 115    |
//     | 120    | 5    | 36    | 57.5   |
//     | 120    | 5    | 12    | 0      |

// The {int} and {float} placeholders are resolved automatically from the table columns.
// Cucumber generates a separate test for each row in the Examples table.
```

## File Organisation

```
features/
├── booking/
│   ├── cancellation.feature       # Gherkin scenarios
│   └── steps/
│       └── cancellation.steps.ts  # Step implementations
├── auth/
│   ├── registration.feature
│   └── steps/
│       └── registration.steps.ts
└── fixtures/
    ├── bookings.ts                 # Shared fixture builders
    └── users.ts
```
