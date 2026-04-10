---
name: react-patterns
description: >
  React 18 + TypeScript patterns for production projects. Typed components, custom hooks, state
  management, forms, errors, tests. Full examples. Loaded by dev-senior-a/b for frontend features.
---

# React Patterns — TypeScript Production

---

## Component Structure

```
src/
├── components/          # Reusable components, no business logic
│   ├── ui/             # Atoms: Button, Input, Modal, Badge
│   └── shared/         # Molecules: UserAvatar, PriceDisplay, StatusBadge
├── features/           # Functional domains
│   └── bookings/
│       ├── components/ # Components specific to this domain
│       │   ├── BookingCard.tsx
│       │   ├── BookingList.tsx
│       │   └── CancelBookingModal.tsx
│       ├── hooks/      # Logic extracted into hooks
│       │   ├── useBookings.ts
│       │   └── useCancelBooking.ts
│       ├── types.ts    # Frontend domain types
│       └── index.ts    # Public exports of the feature
├── hooks/              # Reusable global hooks
├── services/           # API calls (no inline fetch in components)
└── types/              # Shared types
```

---

## Typed Components — Patterns

### Explicit props with an interface

```typescript
// ✅ Named interface — readable, extensible
interface BookingCardProps {
  booking: Booking
  onCancel: (bookingId: string) => void
  onViewDetails: (bookingId: string) => void
  isLoading?: boolean
  className?: string
}

export function BookingCard({
  booking,
  onCancel,
  onViewDetails,
  isLoading = false,
  className,
}: BookingCardProps) {
  return (
    <div className={cn('rounded-lg border p-4', className)}>
      <h3>{booking.reference}</h3>
      <StatusBadge status={booking.status} />
      <PriceDisplay amount={booking.total} currency="EUR" />
      <div className="flex gap-2 mt-4">
        <Button variant="secondary" onClick={() => onViewDetails(booking.id)}>
          View details
        </Button>
        {booking.isCancellable && (
          <Button
            variant="destructive"
            onClick={() => onCancel(booking.id)}
            disabled={isLoading}
          >
            {isLoading ? 'Cancelling...' : 'Cancel'}
          </Button>
        )}
      </div>
    </div>
  )
}
```

### Discriminated Union Props — Polymorphic Components

```typescript
// Props that vary by state
type AlertProps =
  | { variant: 'success'; title: string; description?: string }
  | { variant: 'error'; title: string; error: Error; retry?: () => void }
  | { variant: 'warning'; title: string; description: string; onDismiss: () => void }

export function Alert(props: AlertProps) {
  switch (props.variant) {
    case 'success':
      return <div className="bg-green-50 p-4 rounded">{props.title}</div>

    case 'error':
      return (
        <div className="bg-red-50 p-4 rounded">
          <p>{props.title}: {props.error.message}</p>
          {props.retry && <button onClick={props.retry}>Retry</button>}
        </div>
      )

    case 'warning':
      return (
        <div className="bg-yellow-50 p-4 rounded">
          <p>{props.title}: {props.description}</p>
          <button onClick={props.onDismiss}>×</button>
        </div>
      )
  }
}
```

---

## Custom Hooks — Patterns

### useAsync — Managing async states

```typescript
// hooks/useAsync.ts
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }

function useAsync<T>(
  asyncFn: () => Promise<T>,
  deps: DependencyList = []
): AsyncState<T> & { refetch: () => void } {
  const [state, setState] = useState<AsyncState<T>>({ status: 'idle' })
  const [trigger, setTrigger] = useState(0)

  useEffect(() => {
    let cancelled = false

    setState({ status: 'loading' })
    asyncFn()
      .then(data => {
        if (!cancelled) setState({ status: 'success', data })
      })
      .catch(error => {
        if (!cancelled) setState({ status: 'error', error: error as Error })
      })

    return () => { cancelled = true }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, trigger])

  return {
    ...state,
    refetch: () => setTrigger(t => t + 1),
  }
}

// Usage
function BookingList({ userId }: { userId: string }) {
  const state = useAsync(() => bookingService.getByUser(userId), [userId])

  if (state.status === 'loading') return <Spinner />
  if (state.status === 'error') return <Alert variant="error" title="Error" error={state.error} retry={state.refetch} />
  if (state.status === 'idle' || state.status !== 'success') return null

  return (
    <ul>
      {state.data.map(booking => (
        <BookingCard key={booking.id} booking={booking} />
      ))}
    </ul>
  )
}
```

### useMutation — State-mutating actions

```typescript
// hooks/useMutation.ts
type MutationState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }

function useMutation<TInput, TOutput>(
  mutateFn: (input: TInput) => Promise<TOutput>,
  options?: {
    onSuccess?: (data: TOutput) => void
    onError?: (error: Error) => void
  }
): [
  (input: TInput) => Promise<void>,
  MutationState<TOutput>
] {
  const [state, setState] = useState<MutationState<TOutput>>({ status: 'idle' })

  const mutate = async (input: TInput): Promise<void> => {
    setState({ status: 'loading' })
    try {
      const data = await mutateFn(input)
      setState({ status: 'success', data })
      options?.onSuccess?.(data)
    } catch (error) {
      const err = error as Error
      setState({ status: 'error', error: err })
      options?.onError?.(err)
    }
  }

  return [mutate, state]
}

// Usage in a component
function CancelBookingModal({ bookingId, onClose }: CancelModalProps) {
  const [cancelBooking, cancelState] = useMutation(
    (id: string) => bookingService.cancel(id),
    {
      onSuccess: () => {
        toast.success('Booking cancelled')
        onClose()
      },
      onError: (error) => {
        toast.error(`Error: ${error.message}`)
      },
    }
  )

  return (
    <Modal title="Confirm cancellation">
      <p>Are you sure you want to cancel this booking?</p>
      {cancelState.status === 'error' && (
        <Alert variant="error" title="Cancellation failed" error={cancelState.error} />
      )}
      <div className="flex gap-2 justify-end">
        <Button variant="secondary" onClick={onClose}>Cancel</Button>
        <Button
          variant="destructive"
          onClick={() => cancelBooking(bookingId)}
          disabled={cancelState.status === 'loading'}
        >
          {cancelState.status === 'loading' ? 'Cancelling...' : 'Confirm'}
        </Button>
      </div>
    </Modal>
  )
}
```

---

## Typed Forms with React Hook Form + Zod

```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const RegisterFormSchema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string()
    .min(8, 'Minimum 8 characters')
    .regex(/[A-Z]/, 'One uppercase required')
    .regex(/[0-9]/, 'One digit required'),
  confirmPassword: z.string(),
}).refine(
  data => data.password === data.confirmPassword,
  { message: 'Passwords do not match', path: ['confirmPassword'] }
)

type RegisterFormValues = z.infer<typeof RegisterFormSchema>

function RegisterForm({ onSubmit }: { onSubmit: (values: RegisterFormValues) => Promise<void> }) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    setError,
  } = useForm<RegisterFormValues>({
    resolver: zodResolver(RegisterFormSchema),
  })

  const handleFormSubmit = async (values: RegisterFormValues) => {
    try {
      await onSubmit(values)
    } catch (error) {
      if (error instanceof EmailAlreadyExistsError) {
        setError('email', { message: 'This email is already in use' })
      } else {
        setError('root', { message: 'An error occurred. Please try again.' })
      }
    }
  }

  return (
    <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
      {errors.root && <Alert variant="error" title={errors.root.message!} error={new Error(errors.root.message!)} />}
      <FormField label="Email" error={errors.email?.message}>
        <input type="email" {...register('email')} className="input" />
      </FormField>
      <FormField label="Password" error={errors.password?.message}>
        <input type="password" {...register('password')} className="input" />
      </FormField>
      <FormField label="Confirm" error={errors.confirmPassword?.message}>
        <input type="password" {...register('confirmPassword')} className="input" />
      </FormField>
      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Signing up...' : 'Sign up'}
      </Button>
    </form>
  )
}
```

---

## Error Boundaries

```typescript
// components/ErrorBoundary.tsx
interface ErrorBoundaryState {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends React.Component<
  { children: ReactNode; fallback?: (error: Error, reset: () => void) => ReactNode },
  ErrorBoundaryState
> {
  state: ErrorBoundaryState = { hasError: false, error: null }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    logger.error('React render error', { error, componentStack: info.componentStack })
  }

  reset = () => this.setState({ hasError: false, error: null })

  render() {
    if (this.state.hasError && this.state.error) {
      if (this.props.fallback) {
        return this.props.fallback(this.state.error, this.reset)
      }
      return (
        <div className="p-8 text-center">
          <h2>Something went wrong</h2>
          <button onClick={this.reset}>Retry</button>
        </div>
      )
    }
    return this.props.children
  }
}

// Usage
<ErrorBoundary fallback={(error, reset) => (
  <Alert variant="error" title="Display error" error={error} retry={reset} />
)}>
  <BookingList />
</ErrorBoundary>
```

---

## Available References

- `references/testing-components.md` — React Testing Library, userEvent, async
- `references/performance.md` — memo, useMemo, useCallback, lazy loading
- `references/context-patterns.md` — Context API, Provider pattern
