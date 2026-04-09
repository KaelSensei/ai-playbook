# Step Definitions TypeScript — Cucumber.js / Jest-Cucumber

## Setup Jest-Cucumber

```typescript
// jest.config.js
module.exports = {
  testMatch: ['**/*.steps.ts'],
  transform: { '^.+\.ts$': 'ts-jest' },
};
```

## Structure d'un Step File

```typescript
// features/cancellation/cancellation.steps.ts
import { defineFeature, loadFeature } from 'jest-cucumber'
import { aBooking, daysFromNow } from '../helpers/builders'
import { InMemoryBookingRepository } from '../../src/infrastructure'
import { CancelBooking } from '../../src/application/use-cases'

const feature = loadFeature('./features/cancellation/cancellation.feature')

defineFeature(feature, test => {

  let bookingRepo: InMemoryBookingRepository
  let cancelBooking: CancelBooking
  let result: { refundPercentage: number } | undefined
  let thrownError: Error | undefined

  beforeEach(() => {
    bookingRepo = new InMemoryBookingRepository()
    cancelBooking = new CancelBooking(bookingRepo)
    result = undefined
    thrownError = undefined
  })

  test('Annulation avec remboursement total (plus de 48h avant)', ({ given, when, then, and }) => {

    given(/^j'ai une réservation confirmée qui débute dans (\d+) jours$/, async (days: string) => {
      const booking = aBooking({ departureDate: daysFromNow(parseInt(days)) })
      await bookingRepo.save(booking)
    })

    when(/^j'annule la réservation$/, async () => {
      try {
        const booking = await bookingRepo.findFirst()
        result = await cancelBooking.execute(booking!.id, new Date())
      } catch (e) {
        thrownError = e as Error
      }
    })

    then(/^le remboursement est de (\d+)%$/, (percentage: string) => {
      expect(result!.refundPercentage).toBe(parseInt(percentage))
    })

    and('la réservation est marquée comme annulée', async () => {
      const booking = await bookingRepo.findFirst()
      expect(booking!.status).toBe('CANCELLED')
    })
  })

  test('Tentative d'annulation d'une réservation déjà annulée', ({ given, when, then }) => {

    given('j'ai une réservation déjà annulée', async () => {
      const booking = aBooking({ status: 'CANCELLED' })
      await bookingRepo.save(booking)
    })

    when('j'annule la réservation', async () => {
      try {
        const booking = await bookingRepo.findFirst()
        await cancelBooking.execute(booking!.id, new Date())
      } catch (e) {
        thrownError = e as Error
      }
    })

    then('je reçois une erreur indiquant que la réservation est déjà annulée', () => {
      expect(thrownError).toBeInstanceOf(AlreadyCancelledError)
    })
  })
})
```

## Helpers de Build pour les Tests

```typescript
// features/helpers/builders.ts
export function aBooking(overrides: Partial<BookingProps> = {}): Booking {
  return new Booking({
    id: new BookingId('booking-test-1'),
    userId: new UserId('user-test-1'),
    departureDate: daysFromNow(7),
    status: BookingStatus.CONFIRMED,
    totalPrice: Money.of(120, 'EUR'),
    ...overrides,
  });
}

export function daysFromNow(days: number): Date {
  const date = new Date();
  date.setDate(date.getDate() + days);
  return date;
}

export function hoursFromNow(hours: number): Date {
  return new Date(Date.now() + hours * 60 * 60 * 1000);
}
```
