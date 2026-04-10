---
name: testing-patterns-ts
description: >
  TypeScript testing patterns beyond unit tests: integration, API contracts, React Testing Library
  tests, pyramid strategy. Full examples. Loaded by dev-senior-a/b for features that need
  integration tests.
---

# Testing Patterns TypeScript — Integration and Beyond

---

## The Test Pyramid — Where to Invest

```
           /\
          /E2E\         Few, slow, expensive
         /------\       → Smoke tests, critical happy path
        /  Integ. \     Medium, verify the seams
       /------------\   → Use cases with a real DB (in-memory)
      /  Unit (TDD)  \  Many, fast, precise
     /----------------\ → All of domain, use cases with fakes
```

**Rule of thumb:**

- Domain (entities, VOs, errors) → 100% unit
- Use cases → 100% unit with fakes
- Repositories (PrismaUserRepository) → integration tests with a real DB
- Controllers → integration tests with supertest
- Critical flows (signup → email → login) → 1-2 E2E

---

## Integration Tests — Repository with Real DB

```typescript
// tests/integration/PrismaUserRepository.test.ts
// Use a separate test DB (DATABASE_TEST_URL in .env.test)

describe('PrismaUserRepository — integration', () => {
  let prisma: PrismaClient;
  let sut: PrismaUserRepository;

  beforeAll(async () => {
    prisma = new PrismaClient({
      datasources: { db: { url: process.env.DATABASE_TEST_URL } },
    });
    sut = new PrismaUserRepository(prisma);
  });

  beforeEach(async () => {
    // Clean up in order to respect FKs
    await prisma.order.deleteMany();
    await prisma.user.deleteMany();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should save and retrieve a user by email', async () => {
    const user = User.register({
      id: UserId.generate(),
      email: Email.create('test@test.com'),
      hashedPassword: HashedPassword.fromRaw('$2b$12$hash'),
    });

    await sut.save(user);
    const found = await sut.findByEmail('test@test.com');

    expect(found).not.toBeNull();
    expect(found!.email.value).toBe('test@test.com');
    expect(found!.id.value).toBe(user.id.value);
  });

  it('should return null for non-existent email', async () => {
    const found = await sut.findByEmail('ghost@test.com');
    expect(found).toBeNull();
  });

  it('should handle unique constraint violation', async () => {
    const user1 = aUser({ email: Email.create('dup@test.com') });
    const user2 = aUser({ email: Email.create('dup@test.com') });

    await sut.save(user1);
    await expect(sut.save(user2)).rejects.toThrow(EmailAlreadyExistsError);
  });

  it('should persist deleted user with deletedAt date', async () => {
    const user = aUser();
    user.delete();
    await sut.save(user);

    const found = await sut.findById(user.id);
    expect(found!.isDeleted()).toBe(true);
    expect(found!.deletedAt).not.toBeNull();
  });
});
```

---

## API Tests with Supertest

```typescript
// tests/integration/UserController.test.ts
import request from 'supertest';
import { createApp } from '../../src/app';

describe('POST /api/v1/users', () => {
  let app: Express;

  beforeAll(async () => {
    app = await createApp({ env: 'test' });
  });

  beforeEach(async () => {
    await cleanDatabase();
  });

  // Happy path
  it('should return 201 with user data on valid registration', async () => {
    const res = await request(app)
      .post('/api/v1/users')
      .send({ email: 'new@test.com', password: 'Pass1!xy', name: 'Alice' });

    expect(res.status).toBe(201);
    expect(res.body.data).toMatchObject({
      email: 'new@test.com',
      name: 'Alice',
      role: 'USER',
    });
    // Verify the password hash is not exposed
    expect(res.body.data.passwordHash).toBeUndefined();
    expect(res.body.data.password).toBeUndefined();
  });

  // Validation
  it('should return 400 with field details for invalid email', async () => {
    const res = await request(app)
      .post('/api/v1/users')
      .send({ email: 'not-valid', password: 'Pass1!xy', name: 'Alice' });

    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
    expect(res.body.error.details).toContainEqual(expect.objectContaining({ field: 'email' }));
  });

  // Business rule
  it('should return 409 for duplicate email', async () => {
    await request(app)
      .post('/api/v1/users')
      .send({ email: 'taken@test.com', password: 'Pass1!xy', name: 'Alice' });

    const res = await request(app)
      .post('/api/v1/users')
      .send({ email: 'taken@test.com', password: 'Pass1!xy', name: 'Bob' });

    expect(res.status).toBe(409);
    expect(res.body.error.code).toBe('EMAIL_ALREADY_EXISTS');
    // Do not expose the email in the public error
    expect(res.body.error.message).not.toContain('taken@test.com');
  });

  // Auth
  it('should return 401 without token for protected route', async () => {
    const res = await request(app).get('/api/v1/users'); // protected route
    expect(res.status).toBe(401);
  });

  it('should return 403 when user accesses admin route', async () => {
    const token = await loginAs('standard-user@test.com');
    const res = await request(app)
      .get('/api/v1/admin/users')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(403);
  });
});
```

---

## React Component Tests — Testing Library

```typescript
// features/bookings/components/BookingCard.test.tsx
import { render, screen, userEvent } from '@testing-library/react'

describe('BookingCard', () => {
  const mockBooking = aBooking({
    reference: 'RES-2024-001',
    status: 'confirmed',
    isCancellable: true,
    total: Money.of(120, 'EUR'),
  })

  it('should display booking reference', () => {
    render(<BookingCard booking={mockBooking} onCancel={vi.fn()} onViewDetails={vi.fn()} />)
    expect(screen.getByText('RES-2024-001')).toBeInTheDocument()
  })

  it('should show cancel button for cancellable booking', () => {
    render(<BookingCard booking={mockBooking} onCancel={vi.fn()} onViewDetails={vi.fn()} />)
    expect(screen.getByRole('button', { name: /cancel/i })).toBeInTheDocument()
  })

  it('should not show cancel button for non-cancellable booking', () => {
    const delivered = aBooking({ isCancellable: false })
    render(<BookingCard booking={delivered} onCancel={vi.fn()} onViewDetails={vi.fn()} />)
    expect(screen.queryByRole('button', { name: /cancel/i })).not.toBeInTheDocument()
  })

  it('should call onCancel with booking id when cancel button clicked', async () => {
    const onCancel = vi.fn()
    const user = userEvent.setup()

    render(<BookingCard booking={mockBooking} onCancel={onCancel} onViewDetails={vi.fn()} />)
    await user.click(screen.getByRole('button', { name: /cancel/i }))

    expect(onCancel).toHaveBeenCalledOnce()
    expect(onCancel).toHaveBeenCalledWith(mockBooking.id)
  })

  it('should disable cancel button when isLoading is true', () => {
    render(<BookingCard booking={mockBooking} onCancel={vi.fn()} onViewDetails={vi.fn()} isLoading />)
    expect(screen.getByRole('button', { name: /cancelling/i })).toBeDisabled()
  })
})
```

---

## Testing Custom Hooks

```typescript
// hooks/useCancelBooking.test.ts
import { renderHook, act } from '@testing-library/react';
import { useCancelBooking } from './useCancelBooking';

// Mock the service
vi.mock('../services/bookingService', () => ({
  cancel: vi.fn(),
}));

describe('useCancelBooking', () => {
  it('should be idle initially', () => {
    const { result } = renderHook(() => useCancelBooking());
    expect(result.current.status).toBe('idle');
  });

  it('should set status to loading while cancelling', async () => {
    let resolve: (v: void) => void;
    vi.mocked(bookingService.cancel).mockReturnValue(
      new Promise((r) => {
        resolve = r;
      })
    );

    const { result } = renderHook(() => useCancelBooking());

    act(() => {
      result.current.cancel('booking-1');
    });
    expect(result.current.status).toBe('loading');

    await act(async () => {
      resolve!();
    });
    expect(result.current.status).toBe('success');
  });

  it('should set status to error when cancel fails', async () => {
    vi.mocked(bookingService.cancel).mockRejectedValue(new Error('Server error'));

    const { result } = renderHook(() => useCancelBooking());

    await act(async () => {
      await result.current.cancel('booking-1').catch(() => {});
    });

    expect(result.current.status).toBe('error');
    expect(result.current.error?.message).toBe('Server error');
  });
});
```

---

## Vitest — Recommended Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // 'jsdom' for React tests
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      exclude: ['**/*.test.ts', '**/index.ts', '**/*.d.ts'],
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80,
      },
    },
    // Integration tests kept separate — not run by default
    exclude: ['tests/integration/**', 'tests/e2e/**'],
  },
});

// tests/setup.ts
import '@testing-library/jest-dom'; // for React tests

// Test environment
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret-not-for-production';
```
