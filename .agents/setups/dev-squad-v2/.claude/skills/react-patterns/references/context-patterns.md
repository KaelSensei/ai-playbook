# Context Patterns — React TypeScript

## When Utiliser Context

```
✅ Context adapté pour :
  - Auth (utilisateur connecté, rôle)
  - Thème (dark/light, préférences UI)
  - Langue / i18n
  - Feature flags
  - Toast / notifications globales

❌ Context inadapté pour :
  - État serveur (données fetched) → React Query / SWR
  - État de formulaire → React Hook Form
  - État complexe partagé entre quelques composants → prop drilling OK ou local state
  - Cache de requêtes → React Query
```

## Complete Pattern — Auth Context

```typescript
// contexts/AuthContext.tsx

// 1. Types d'abord
type AuthState =
  | { status: 'loading' }
  | { status: 'unauthenticated' }
  | { status: 'authenticated'; user: AuthUser }

type AuthContextValue = {
  state: AuthState
  login: (credentials: LoginCredentials) => Promise<void>
  logout: () => Promise<void>
  isAuthenticated: () => boolean
}

// 2. Context privé — jamais exporté directement
const AuthContext = createContext<AuthContextValue | null>(null)

// 3. Provider avec logique encapsulée
export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({ status: 'loading' })

  useEffect(() => {
    // Vérifier le token existant au montage
    const token = localStorage.getItem('access_token')
    if (!token) {
      setState({ status: 'unauthenticated' })
      return
    }
    authService.validateToken(token)
      .then(user => setState({ status: 'authenticated', user }))
      .catch(() => {
        localStorage.removeItem('access_token')
        setState({ status: 'unauthenticated' })
      })
  }, [])

  const login = async (credentials: LoginCredentials): Promise<void> => {
    const { user, token } = await authService.login(credentials)
    localStorage.setItem('access_token', token)
    setState({ status: 'authenticated', user })
  }

  const logout = async (): Promise<void> => {
    await authService.logout()
    localStorage.removeItem('access_token')
    setState({ status: 'unauthenticated' })
  }

  const isAuthenticated = (): boolean => state.status === 'authenticated'

  return (
    <AuthContext.Provider value={{ state, login, logout, isAuthenticated }}>
      {children}
    </AuthContext.Provider>
  )
}

// 4. Hook avec guard — le seul export pour consommer le context
export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}

// 5. Hooks dérivés pour éviter la logique dans les composants
export function useCurrentUser(): AuthUser {
  const { state } = useAuth()
  if (state.status !== 'authenticated') {
    throw new Error('useCurrentUser requires authenticated state')
  }
  return state.user
}

export function useIsAdmin(): boolean {
  const { state } = useAuth()
  return state.status === 'authenticated' && state.user.role === 'ADMIN'
}
```

## Separate Contexts to Avoid Re-Renders

```typescript
// ❌ Un seul context qui regroupe tout → tous les consommateurs re-rendent
const AppContext = createContext({
  user: null,
  theme: 'light',
  notifications: [],
  setTheme: () => {},
  addNotification: () => {},
})
// → un toast ajouté = tous les composants qui lisent le user re-rendent

// ✅ Contextes séparés par domaine — re-renders isolés
// AuthContext → user, login, logout
// ThemeContext → theme, setTheme
// NotificationContext → notifications, addNotification, removeNotification

// Composition dans App.tsx
function App() {
  return (
    <AuthProvider>
      <ThemeProvider>
        <NotificationProvider>
          <Router />
        </NotificationProvider>
      </ThemeProvider>
    </AuthProvider>
  )
}
```

## Context + useReducer — Complex State

```typescript
// Pour les états avec plusieurs transitions

type NotificationState = {
  items: Notification[]
  maxVisible: number
}

type NotificationAction =
  | { type: 'ADD'; notification: Notification }
  | { type: 'REMOVE'; id: string }
  | { type: 'CLEAR_ALL' }

function notificationReducer(state: NotificationState, action: NotificationAction): NotificationState {
  switch (action.type) {
    case 'ADD':
      return {
        ...state,
        items: [action.notification, ...state.items].slice(0, state.maxVisible)
      }
    case 'REMOVE':
      return { ...state, items: state.items.filter(n => n.id !== action.id) }
    case 'CLEAR_ALL':
      return { ...state, items: [] }
  }
}

export function NotificationProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(notificationReducer, { items: [], maxVisible: 5 })

  const add = useCallback((notification: Omit<Notification, 'id'>) => {
    dispatch({ type: 'ADD', notification: { ...notification, id: crypto.randomUUID() } })
  }, [])

  const remove = useCallback((id: string) => {
    dispatch({ type: 'REMOVE', id })
  }, [])

  return (
    <NotificationContext.Provider value={{ notifications: state.items, add, remove }}>
      {children}
      <NotificationStack notifications={state.items} onDismiss={remove} />
    </NotificationContext.Provider>
  )
}
```
