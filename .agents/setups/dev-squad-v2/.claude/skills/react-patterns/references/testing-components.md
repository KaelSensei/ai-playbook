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
// Priority 1: Accessible (what the user sees/interacts with)
screen.getByRole('button', { name: /cancel/i });
screen.getByRole('heading', { name: /my bookings/i });
screen.getByLabelText('Email');
screen.getByPlaceholderText('Search...');

// Priority 2: Textual content
screen.getByText('No bookings');
screen.getByText(/refund of/i); // regex for partial content

// Priority 3: Test ID (last resort, coupled to the implementation)
screen.getByTestId('booking-total'); // ❌ avoid unless absolutely necessary
```

## Common Patterns

### Testing a full form

```typescript
it('should submit form with valid values', async () => {
  const onSubmit = vi.fn()
  const user = userEvent.setup()

  render(<RegisterForm onSubmit={onSubmit} />)

  await user.type(screen.getByLabelText('Email'), 'alice@test.com')
  await user.type(screen.getByLabelText('Password'), 'Pass1!xy')
  await user.type(screen.getByLabelText('Confirm'), 'Pass1!xy')
  await user.click(screen.getByRole('button', { name: /sign up/i }))

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
  await user.tab() // triggers onBlur validation

  expect(await screen.findByText(/invalid email/i)).toBeInTheDocument()
  expect(screen.getByRole('button', { name: /sign up/i })).toBeDisabled()
})
```

### Testing loading and error states

```typescript
it('should show loading state while fetching', async () => {
  // Simulate a slow response
  vi.mocked(bookingService.getAll).mockReturnValue(new Promise(() => {}))

  render(<BookingList userId="user-1" />)

  expect(screen.getByRole('status')).toBeInTheDocument() // spinner
  expect(screen.queryByRole('list')).not.toBeInTheDocument()
})

it('should show error state when fetch fails', async () => {
  vi.mocked(bookingService.getAll).mockRejectedValue(new Error('Network error'))

  render(<BookingList userId="user-1" />)

  expect(await screen.findByText(/something went wrong/i)).toBeInTheDocument()
  expect(screen.getByRole('button', { name: /retry/i })).toBeInTheDocument()
})

it('should show empty state when no bookings', async () => {
  vi.mocked(bookingService.getAll).mockResolvedValue([])

  render(<BookingList userId="user-1" />)

  expect(await screen.findByText(/you don't have any bookings yet/i))
    .toBeInTheDocument()
})
```

### Render with Providers

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
  expect(screen.getByRole('button', { name: /delete/i })).toBeInTheDocument()
})
```
