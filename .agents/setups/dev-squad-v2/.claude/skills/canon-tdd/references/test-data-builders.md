# Test Data Builders — TypeScript

## The Problem

```typescript
// ❌ Setup verbeux et fragile
const user = new User(
  new UserId('123'),
  new Email('test@test.com'),
  new HashedPassword('$2b$12$...'),
  UserRole.USER,
  new Date('2024-01-01'),
  null,
  false,
  'FR'
);
// → Si User ajoute un paramètre, TOUS les tests cassent
```

## Builder Pattern

```typescript
// UserBuilder — facilite la création d'objets de test
class UserBuilder {
  private props: UserProps = {
    id: new UserId('test-id-1'),
    email: new Email('default@test.com'),
    passwordHash: new HashedPassword('$2b$12$hashedpassword'),
    role: UserRole.USER,
    createdAt: new Date('2024-01-01T00:00:00Z'),
    deletedAt: null,
    emailVerified: false,
    country: 'FR',
  };

  withId(id: string): this {
    this.props.id = new UserId(id);
    return this;
  }

  withEmail(email: string): this {
    this.props.email = new Email(email);
    return this;
  }

  asAdmin(): this {
    this.props.role = UserRole.ADMIN;
    return this;
  }

  withVerifiedEmail(): this {
    this.props.emailVerified = true;
    return this;
  }

  deleted(): this {
    this.props.deletedAt = new Date();
    return this;
  }

  build(): User {
    return new User(this.props);
  }
}

// Factory function (alternative plus concise)
function aUser(overrides: Partial<UserProps> = {}): User {
  return new User({
    id: new UserId('test-id-1'),
    email: new Email('default@test.com'),
    passwordHash: new HashedPassword('$2b$12$hashedpassword'),
    role: UserRole.USER,
    createdAt: new Date('2024-01-01T00:00:00Z'),
    deletedAt: null,
    emailVerified: false,
    country: 'FR',
    ...overrides,
  });
}
```

## Usage in Tests

```typescript
// Builder
it('should allow admin to delete user', async () => {
  const admin = new UserBuilder().withId('admin-1').asAdmin().build();
  const target = new UserBuilder().withId('user-1').build();

  await userService.delete(admin, target.id);

  expect(await repo.findById(target.id)).toBeNull();
});

// Factory function
it('should reject deletion of admin by non-admin', async () => {
  const requester = aUser({ role: UserRole.USER });
  const target = aUser({ role: UserRole.ADMIN });

  await expect(userService.delete(requester, target.id)).rejects.toThrow(UnauthorizedError);
});

// Builders pour des objets complexes
class OrderBuilder {
  private items: CartItem[] = [];
  private userId = 'user-1';
  private status = OrderStatus.PENDING;

  withItem(name: string, price: number, qty = 1): this {
    this.items.push(new CartItem({ name, price, qty }));
    return this;
  }

  withMultipleItems(count: number): this {
    for (let i = 0; i < count; i++) {
      this.items.push(new CartItem({ name: `Item ${i}`, price: 10, qty: 1 }));
    }
    return this;
  }

  confirmed(): this {
    this.status = OrderStatus.CONFIRMED;
    return this;
  }

  build(): Order {
    if (this.items.length === 0) {
      this.items.push(new CartItem({ name: 'Default Item', price: 10, qty: 1 }));
    }
    return new Order({ items: this.items, userId: this.userId, status: this.status });
  }
}

// Usage
it('should calculate correct total for multi-item order', () => {
  const order = new OrderBuilder().withItem('Laptop', 1000).withItem('Mouse', 50, 2).build();

  expect(order.totalHT()).toBe(1100);
  expect(order.totalTTC()).toBe(1320); // 20% VAT
});
```

## Shared Fixtures

```typescript
// fixtures/users.ts — fixtures réutilisables entre tests
export const fixtures = {
  standardUser: () => aUser({ email: new Email('user@test.com') }),
  adminUser: () => aUser({ role: UserRole.ADMIN, email: new Email('admin@test.com') }),
  deletedUser: () => aUser({ deletedAt: new Date('2024-01-15') }),
  unverifiedUser: () => aUser({ emailVerified: false }),
};

// Dans les tests
import { fixtures } from '../fixtures/users';

it('should not allow deleted user to login', async () => {
  const user = fixtures.deletedUser();
  await expect(authService.login(user.email, 'password')).rejects.toThrow(AccountDeletedError);
});
```
