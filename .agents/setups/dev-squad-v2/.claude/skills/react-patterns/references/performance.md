# React Performance — Production Patterns

## Fundamental Rule

> Optimiser seulement ce qui est mesuré comme lent. `memo`, `useMemo`, `useCallback` ont un coût
> (comparaison à chaque render). Un composant non-mémoïsé qui rend en <2ms n'a pas besoin de memo.

---

## memo — When to Memoize a Component

```typescript
// ❌ memo inutile — le composant est léger, les props changent souvent
const Badge = memo(({ label }: { label: string }) => (
  <span className="badge">{label}</span>
))
// → comparaison des props à chaque render parent = overhead

// ✅ memo utile — composant coûteux avec props stables
const DataTable = memo(function DataTable({ rows, columns, onSort }: DataTableProps) {
  // Rendu coûteux : des centaines de lignes, tri, formatage
  return <table>...</table>
}, (prevProps, nextProps) => {
  // Comparaison custom si props complexes
  return prevProps.rows === nextProps.rows &&
    prevProps.columns === nextProps.columns
})

// ✅ memo nécessaire — composant enfant avec parent qui re-render souvent
const BookingCard = memo(function BookingCard({ booking, onCancel }: Props) {
  return <div>...</div>
})
// Mais onCancel doit être stable → useCallback dans le parent
```

## useMemo — Expensive Computations

```typescript
// ❌ useMemo inutile — calcul trivial
const doubled = useMemo(() => count * 2, [count])
// → overhead de comparaison > gain du calcul

// ✅ useMemo utile — calcul coûteux ou référentiellement stable
function BookingList({ bookings, filter }: Props) {
  // Filtrage + tri d'un grand tableau — coûteux à chaque render
  const filteredAndSorted = useMemo(
    () => bookings
      .filter(b => filter === 'all' || b.status === filter)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime()),
    [bookings, filter]
  )

  // Référentiellement stable pour les enfants mémoïsés
  const chartData = useMemo(
    () => transformToChartFormat(bookings),
    [bookings]  // ne change de référence que si bookings change
  )

  return <ul>{filteredAndSorted.map(b => <BookingCard key={b.id} booking={b} />)}</ul>
}
```

## useCallback — Stabiliser les Handlers

```typescript
// Contexte : BookingCard est mémoïsé avec memo()
// Sans useCallback → onCancel est une nouvelle fonction à chaque render parent
// → memo de BookingCard est court-circuité

function BookingList({ bookings }: { bookings: Booking[] }) {
  // ❌ Nouvelle référence à chaque render → BookingCard re-render inutilement
  const handleCancel = (id: string) => {
    setBookings(prev => prev.filter(b => b.id !== id))
  }

  // ✅ Référence stable → BookingCard ne re-render que si bookings change
  const handleCancel = useCallback((id: string) => {
    setBookings(prev => prev.filter(b => b.id !== id))
  }, [])  // pas de dépendances car on utilise la forme fonctionnelle de setState

  return bookings.map(b =>
    <BookingCard key={b.id} booking={b} onCancel={handleCancel} />
  )
}
```

## Lazy Loading — Code Splitting

```typescript
import { lazy, Suspense } from 'react'

// Charger les pages lourdes seulement quand nécessaire
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'))
const ReportGenerator = lazy(() => import('./pages/ReportGenerator'))

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/admin" element={<AdminDashboard />} />
        <Route path="/reports" element={<ReportGenerator />} />
      </Routes>
    </Suspense>
  )
}

// Précharger une page anticipée (hover sur un lien)
const prefetchAdmin = () => import('./pages/AdminDashboard')

<Link
  to="/admin"
  onMouseEnter={prefetchAdmin}  // précharge au hover, charge instantanée au click
>
  Administration
</Link>
```

## Virtualisation — Long Lists

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

// ❌ Rendre 10 000 lignes dans le DOM → freeze
function HugeList({ items }: { items: Item[] }) {
  return <ul>{items.map(item => <ListItem key={item.id} item={item} />)}</ul>
}

// ✅ Virtualiser — seulement ~20 items dans le DOM à la fois
function HugeList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 64,       // hauteur estimée d'un item en px
  })

  return (
    <div ref={parentRef} style={{ height: '600px', overflowY: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map(virtualItem => (
          <div
            key={virtualItem.key}
            style={{
              position: 'absolute',
              top: `${virtualItem.start}px`,
              width: '100%',
            }}
          >
            <ListItem item={items[virtualItem.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}
```

## Signals to Look For in Review

```
[SHOULD] memo() sur composant léger avec handlers non-useCallback
         → soit retirer memo, soit ajouter useCallback dans le parent

[SHOULD] Carte/liste d'items sans clé stable (key={index})
         → key doit être un ID stable, pas l'index du tableau

[SHOULD] Liste de > 200 items rendue sans virtualisation
         → suggérer @tanstack/react-virtual ou pagination

[SUGGESTION] useMemo sur calcul trivial (< 1ms)
             → overhead > gain, retirer le useMemo
```
