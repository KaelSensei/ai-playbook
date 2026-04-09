# Testing React Components — Testing Library

## Setup

```typescript
// tests/setup.ts
import '@testing-library/jest-dom';
import { cleanup } from '@testing-library/react';
import { afterEach, vi } from 'vitest';

afterEach(() => {
  cleanup();
  vi.clearAllMocks();
});
```

## Queries — Priority Order (Testing Library Philosophy)

```typescript
// Priorité 1 : Accessible (ce que l'utilisateur voit/interagit)
screen.getByRole('button', { name: /annuler/i });
screen.getByRole('heading', { name: /mes réservations/i });
screen.getByLabelText('Email');
screen.getByPlaceholderText('Rechercher...');

// Priorité 2 : Contenu textuel
screen.getByText('Aucune réservation');
screen.getByText(/remboursement de/i); // regex pour contenu partiel

// Priorité 3 : Test ID (dernier recours, couplé à l'implémentation)
screen.getByTestId('booking-total'); // ❌ à éviter sauf nécessité absolue
```

## Patterns Courants

### Tester un formulaire complet

```typescript
it('should submit form with valid values', async () => {
  const onSubmit = vi.fn()
  const user = userEvent.setup()

  render(<RegisterForm onSubmit={onSubmit} />)

  await user.type(screen.getByLabelText('Email'), 'alice@test.com')
  await user.type(screen.getByLabelText('Mot de passe'), 'Pass1!xy')
  await user.type(screen.getByLabelText('Confirmer'), 'Pass1!xy')
  await user.click(screen.getByRole('button', { name: /s'inscrire/i }))

  await waitFor(() => {
    expect(onSubmit).toHaveBeenCalledWith({
      email: 'alice@test.com',
      password: 'Pass1!xy',
      confirmPassword: 'Pass1!xy',
    })
  })
})

it('should show validation error for invalid email', async () => {
  const user = userEvent.setup()
  render(<RegisterForm onSubmit={vi.fn()} />)

  await user.type(screen.getByLabelText('Email'), 'invalid')
  await user.tab() // déclenche la validation onBlur

  expect(await screen.findByText(/email invalide/i)).toBeInTheDocument()
  expect(screen.getByRole('button', { name: /s'inscrire/i })).toBeDisabled()
})
```

### Testing loading and error states

```typescript
it('should show loading state while fetching', async () => {
  // Simuler une réponse lente
  vi.mocked(bookingService.getAll).mockReturnValue(new Promise(() => {}))

  render(<BookingList userId="user-1" />)

  expect(screen.getByRole('status')).toBeInTheDocument() // spinner
  expect(screen.queryByRole('list')).not.toBeInTheDocument()
})

it('should show error state when fetch fails', async () => {
  vi.mocked(bookingService.getAll).mockRejectedValue(new Error('Network error'))

  render(<BookingList userId="user-1" />)

  expect(await screen.findByText(/une erreur est survenue/i)).toBeInTheDocument()
  expect(screen.getByRole('button', { name: /réessayer/i })).toBeInTheDocument()
})

it('should show empty state when no bookings', async () => {
  vi.mocked(bookingService.getAll).mockResolvedValue([])

  render(<BookingList userId="user-1" />)

  expect(await screen.findByText(/vous n'avez pas encore de réservation/i))
    .toBeInTheDocument()
})
```

### Render avec Providers

```typescript
// tests/utils/renderWithProviders.tsx
function renderWithProviders(
  ui: ReactElement,
  { initialAuth, ...options }: RenderOptions & { initialAuth?: AuthState } = {}
) {
  function Wrapper({ children }: { children: ReactNode }) {
    return (
      <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
        <AuthProvider initialState={initialAuth}>
          <ToastProvider>
            {children}
          </ToastProvider>
        </AuthProvider>
      </QueryClientProvider>
    )
  }
  return render(ui, { wrapper: Wrapper, ...options })
}

// Usage
it('should show admin button for admin user', () => {
  renderWithProviders(
    <BookingActions bookingId="booking-1" />,
    { initialAuth: { user: { role: 'ADMIN', id: 'admin-1' } } }
  )
  expect(screen.getByRole('button', { name: /supprimer/i })).toBeInTheDocument()
})
```
