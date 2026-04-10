# Test Naming Patterns — TypeScript

## Main Pattern: [Expected behaviour] in [Context]

```typescript
// Format: should [result] when [condition]
it('should return 100% refund when cancelled more than 48h before departure');
it('should throw EmailAlreadyExistsError when email is already taken');
it('should assign USER role by default when no role is specified');
it('should not allow cancellation of already cancelled booking');

// Format: [entity/use case] [behaviour]
it('CancellationPolicy: applies 50% refund between 24h and 48h');
it('User.register: emits UserRegistered event');
it('RegisterUser: hashes password before saving');
```

## Anti-patterns to avoid

```typescript
// ❌ Too vague
it('should work');
it('test user creation');
it('cancellation test');

// ❌ Tests the implementation
it('should call calculateRefund method');
it('should set status to CANCELLED');
it('should invoke emailService.send');

// ❌ Multiple behaviours in one test
it('should create user, hash password, send email and return result');

// ✅ One behaviour = one test
it('should create user with provided email');
it('should hash password before saving');
it('should send welcome email after creation');
it('should return created user without password hash');
```

## Naming by Test Type

```typescript
// Value Object
it('Email: should normalize to lowercase');
it('Email: should throw InvalidEmailError for missing @ symbol');
it('Email: should consider two emails equal when same value');
it('Price: should throw NegativePriceError for negative amount');

// Entity
it('User.register: should create user with USER role by default');
it('User.changeEmail: should emit UserEmailChanged event');
it('User.delete: should throw AlreadyDeletedError when already deleted');

// Use Case
it('RegisterUser: should register user with valid credentials');
it('RegisterUser: should not store plain text password');
it('RegisterUser: should throw EmailAlreadyExistsError for duplicate email');
it('RegisterUser: should publish UserRegistered event after creation');

// Repository
it('InMemoryUserRepository: should find user by email after save');
it('InMemoryUserRepository: should return null for unknown email');
```
