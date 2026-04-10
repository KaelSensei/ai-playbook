# React Performance — Production Patterns

## Fundamental Rule

> Only optimise what is measured as slow. `memo`, `useMemo`, `useCallback` have a cost (comparison
> on every render). A non-memoised component that renders in <2ms does not need memo.

---

## memo — When to Memoize a Component

```typescript
// ❌ memo is useless — the component is lightweight, props change often
const Badge = memo(({ label }: { label: string }) => (
  <span className="badge">{label}</span>
))
// → prop comparison on every parent render = overhead

// ✅ memo is useful — expensive component with stable props
const DataTable = memo(function DataTable({ rows, columns, onSort }: DataTableProps) {
  // Expensive render: hundreds of rows, sort, formatting
  return <table>...</table>
}, (prevProps, nextProps) => {
  // Custom comparison when props are complex
  return prevProps.rows === nextProps.rows &&
    prevProps.columns === nextProps.columns
})

// ✅ memo is necessary — child component whose parent re-renders often
const BookingCard = memo(function BookingCard({ booking, onCancel }: Props) {
  return <div>...</div>
})
// But onCancel must be stable → useCallback in the parent
```

## useMemo — Expensive Computations

```typescript
// ❌ useMemo is useless — trivial computation
const doubled = useMemo(() => count * 2, [count])
// → comparison overhead > computation gain

// ✅ useMemo is useful — expensive computation or referentially stable
function BookingList({ bookings, filter }: Props) {
  // Filtering + sorting a large array — expensive on every render
  const filteredAndSorted = useMemo(
    () => bookings
      .filter(b => filter === 'all' || b.status === filter)
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime()),
    [bookings, filter]
  )

  // Referentially stable for memoised children
  const chartData = useMemo(
    () => transformToChartFormat(bookings),
    [bookings]  // reference only changes when bookings changes
  )

  return <ul>{filteredAndSorted.map(b => <BookingCard key={b.id} booking={b} />)}</ul>
}
```

## useCallback — Stabilising Handlers

```typescript
// Context: BookingCard is memoised with memo()
// Without useCallback → onCancel is a new function on every parent render
// → BookingCard's memo is short-circuited

function BookingList({ bookings }: { bookings: Booking[] }) {
  // ❌ New reference on every render → BookingCard re-renders unnecessarily
  const handleCancel = (id: string) => {
    setBookings(prev => prev.filter(b => b.id !== id))
  }

  // ✅ Stable reference → BookingCard only re-renders when bookings changes
  const handleCancel = useCallback((id: string) => {
    setBookings(prev => prev.filter(b => b.id !== id))
  }, [])  // no dependencies since we use the functional form of setState

  return bookings.map(b =>
    <BookingCard key={b.id} booking={b} onCancel={handleCancel} />
  )
}
```

## Lazy Loading — Code Splitting

```typescript
import { lazy, Suspense } from 'react'

// Load heavy pages only when needed
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

// Prefetch an anticipated page (hover on a link)
const prefetchAdmin = () => import('./pages/AdminDashboard')

<Link
  to="/admin"
  onMouseEnter={prefetchAdmin}  // prefetches on hover, instant load on click
>
  Admin
</Link>
```

## Virtualisation — Long Lists

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

// ❌ Rendering 10,000 rows in the DOM → freeze
function HugeList({ items }: { items: Item[] }) {
  return <ul>{items.map(item => <ListItem key={item.id} item={item} />)}</ul>
}

// ✅ Virtualise — only ~20 items in the DOM at a time
function HugeList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 64,       // estimated height of an item in px
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
[SHOULD] memo() on a lightweight component with non-useCallback handlers
         → either remove memo, or add useCallback in the parent

[SHOULD] Map/list of items without a stable key (key={index})
         → key must be a stable ID, not the array index

[SHOULD] List of > 200 items rendered without virtualisation
         → suggest @tanstack/react-virtual or pagination

[SUGGESTION] useMemo on a trivial computation (< 1ms)
             → overhead > gain, remove the useMemo
```
