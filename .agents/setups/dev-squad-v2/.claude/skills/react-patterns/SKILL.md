---
name: react-patterns
description: >
  Patterns React 18 + TypeScript pour projets production. Composants typés, hooks custom, gestion
  d'état, forms, erreurs, tests. Full examples. Loaded by dev-senior-a/b pour les features frontend.
---

# React Patterns — TypeScript Production

---

## Component Structure

```
src/
├── components/          # Composants réutilisables, sans logique métier
│   ├── ui/             # Atoms : Button, Input, Modal, Badge
│   └── shared/         # Molecules : UserAvatar, PriceDisplay, StatusBadge
├── features/           # Domaines fonctionnels
│   └── bookings/
│       ├── components/ # Composants spécifiques à ce domaine
│       │   ├── BookingCard.tsx
│       │   ├── BookingList.tsx
│       │   └── CancelBookingModal.tsx
│       ├── hooks/      # Logique extraite dans des hooks
│       │   ├── useBookings.ts
│       │   └── useCancelBooking.ts
│       ├── types.ts    # Types du domaine frontend
│       └── index.ts    # Exports publics du feature
├── hooks/              # Hooks globaux réutilisables
├── services/           # Appels API (pas de fetch inline dans les composants)
└── types/              # Types partagés
```

---

## Typed Components — Patterns

### Props explicites avec interface

```typescript
// ✅ Interface nommée — lisible, extensible
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
          Voir les détails
        </Button>
        {booking.isCancellable && (
          <Button
            variant="destructive"
            onClick={() => onCancel(booking.id)}
            disabled={isLoading}
          >
            {isLoading ? 'Annulation...' : 'Annuler'}
          </Button>
        )}
      </div>
    </div>
  )
}
```

### Discriminated Union Props — Composants Polymorphes

```typescript
// Props qui varient selon un état
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
          {props.retry && <button onClick={props.retry}>Réessayer</button>}
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
  if (state.status === 'error') return <Alert variant="error" title="Erreur" error={state.error} retry={state.refetch} />
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

// Usage dans un composant
function CancelBookingModal({ bookingId, onClose }: CancelModalProps) {
  const [cancelBooking, cancelState] = useMutation(
    (id: string) => bookingService.cancel(id),
    {
      onSuccess: () => {
        toast.success('Réservation annulée')
        onClose()
      },
      onError: (error) => {
        toast.error(`Erreur : ${error.message}`)
      },
    }
  )

  return (
    <Modal title="Confirmer l'annulation">
      <p>Êtes-vous sûr de vouloir annuler cette réservation ?</p>
      {cancelState.status === 'error' && (
        <Alert variant="error" title="Annulation impossible" error={cancelState.error} />
      )}
      <div className="flex gap-2 justify-end">
        <Button variant="secondary" onClick={onClose}>Annuler</Button>
        <Button
          variant="destructive"
          onClick={() => cancelBooking(bookingId)}
          disabled={cancelState.status === 'loading'}
        >
          {cancelState.status === 'loading' ? 'Annulation...' : 'Confirmer'}
        </Button>
      </div>
    </Modal>
  )
}
```

---

## Typed Forms avec React Hook Form + Zod

```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const RegisterFormSchema = z.object({
  email: z.string().email('Email invalide'),
  password: z.string()
    .min(8, '8 caractères minimum')
    .regex(/[A-Z]/, 'Une majuscule requise')
    .regex(/[0-9]/, 'Un chiffre requis'),
  confirmPassword: z.string(),
}).refine(
  data => data.password === data.confirmPassword,
  { message: 'Les mots de passe ne correspondent pas', path: ['confirmPassword'] }
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
        setError('email', { message: 'Cet email est déjà utilisé' })
      } else {
        setError('root', { message: 'Une erreur est survenue. Réessayez.' })
      }
    }
  }

  return (
    <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
      {errors.root && <Alert variant="error" title={errors.root.message!} error={new Error(errors.root.message!)} />}
      <FormField label="Email" error={errors.email?.message}>
        <input type="email" {...register('email')} className="input" />
      </FormField>
      <FormField label="Mot de passe" error={errors.password?.message}>
        <input type="password" {...register('password')} className="input" />
      </FormField>
      <FormField label="Confirmer" error={errors.confirmPassword?.message}>
        <input type="password" {...register('confirmPassword')} className="input" />
      </FormField>
      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Inscription...' : 'S\'inscrire'}
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
          <h2>Une erreur est survenue</h2>
          <button onClick={this.reset}>Réessayer</button>
        </div>
      )
    }
    return this.props.children
  }
}

// Usage
<ErrorBoundary fallback={(error, reset) => (
  <Alert variant="error" title="Erreur d'affichage" error={error} retry={reset} />
)}>
  <BookingList />
</ErrorBoundary>
```

---

## Available References

- `references/testing-components.md` — React Testing Library, userEvent, async
- `references/performance.md` — memo, useMemo, useCallback, lazy loading
- `references/context-patterns.md` — Context API, Provider pattern
