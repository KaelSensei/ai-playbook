# Cucumber.js + Jest-Cucumber Configuration — TypeScript

## Option A: Jest-Cucumber (recommended — integrated with Jest/Vitest)

```bash
npm install --save-dev jest-cucumber
```

```typescript
// features/booking-cancellation.feature — fichier Gherkin
Feature: Annulation de réservation

  Scenario: Remboursement total pour annulation anticipée
    Given j'ai une réservation confirmée de 120€ TTC avec frais de 5€
    And ma réservation débute dans 72 heures
    When j'annule ma réservation
    Then le remboursement affiché est 115€
    And je reçois un email de confirmation d'annulation
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

  test('Remboursement total pour annulation anticipée', ({ given, and, when, then }) => {
    given("j'ai une réservation confirmée de 120€ TTC avec frais de 5€", async () => {
      booking = aBooking({ totalTTC: 120, serviceFees: 5, status: 'confirmed' });
      await bookingRepo.save(booking);
    });

    and('ma réservation débute dans 72 heures', () => {
      booking.departureDate = hoursFromNow(72);
      bookingRepo.update(booking);
    });

    when("j'annule ma réservation", async () => {
      result = await cancelBooking.execute({ bookingId: booking.id, userId: booking.userId });
    });

    then('le remboursement affiché est 115€', () => {
      expect(result.refundAmount).toBe(115);
    });

    and("je reçois un email de confirmation d'annulation", () => {
      expect(emailSpy.sent).toHaveLength(1);
      expect(emailSpy.sent[0]).toMatchObject({
        to: booking.userEmail,
        subject: expect.stringContaining('annulation'),
        body: expect.stringContaining('115€'),
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
  // Reset de l'état entre chaque scénario
  const repo = new InMemoryBookingRepository();
  cancelBooking = new CancelBooking(repo, new SpyEmailService(), new InMemoryEventBus());
  lastError = null;
});

Given(
  "j'ai une réservation confirmée de {int}€ TTC avec frais de {int}€",
  async (totalTTC: number, serviceFees: number) => {
    const booking = aBooking({ totalTTC, serviceFees, status: 'confirmed' });
    await bookingRepo.save(booking);
  }
);

When("j'annule ma réservation", async () => {
  try {
    lastResult = await cancelBooking.execute({ bookingId: currentBooking.id });
  } catch (error) {
    lastError = error as Error;
  }
});

Then('le remboursement affiché est {int}€', (expectedAmount: number) => {
  expect(lastResult.refundAmount).toBe(expectedAmount);
});

Then("je vois l'erreur {string}", (expectedMessage: string) => {
  expect(lastError).not.toBeNull();
  expect(lastError!.message).toContain(expectedMessage);
});
```

## Scenario Outline — Step Implementation

```typescript
// Feature avec tableau de données
// Scenario Outline: Calcul du remboursement selon le délai
//   Given j'ai une réservation de <montant>€ TTC avec <frais>€ de frais
//   And ma réservation débute dans <heures> heures
//   When j'annule
//   Then le remboursement est <remboursement>€
//   Examples:
//     | montant | frais | heures | remboursement |
//     | 120     | 5     | 72     | 115           |
//     | 120     | 5     | 36     | 57.5          |
//     | 120     | 5     | 12     | 0             |

// Les {int} et {float} sont résolus automatiquement depuis les colonnes du tableau
// Cucumber génère un test séparé pour chaque ligne du tableau Examples
```

## File Organisation

```
features/
├── booking/
│   ├── cancellation.feature       # Scénarios Gherkin
│   └── steps/
│       └── cancellation.steps.ts  # Implémentation des steps
├── auth/
│   ├── registration.feature
│   └── steps/
│       └── registration.steps.ts
└── fixtures/
    ├── bookings.ts                 # Builders de fixtures partagés
    └── users.ts
```
