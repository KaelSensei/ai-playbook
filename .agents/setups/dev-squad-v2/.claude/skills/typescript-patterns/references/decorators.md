# TypeScript Decorators — Production Patterns

> Decorators require `"experimentalDecorators": true` and `"emitDecoratorMetadata": true` in
> tsconfig. As of 2024: TC39 Stage 3, stable syntax but the API may still evolve.

---

## Validation Decorators (Class Validator)

```typescript
import { IsEmail, IsString, MinLength, MaxLength, IsEnum, IsOptional } from 'class-validator';
import { plainToInstance, Transform } from 'class-transformer';
import { validate } from 'class-validator';

// DTO with validation decorators
class RegisterUserDto {
  @IsEmail({}, { message: 'Invalid email format' })
  @Transform(({ value }) => (value as string).toLowerCase().trim())
  email: string;

  @IsString()
  @MinLength(8, { message: 'Password must be at least 8 characters' })
  @MaxLength(100)
  password: string;

  @IsString()
  @MinLength(1)
  @MaxLength(100)
  @Transform(({ value }) => (value as string).trim())
  name: string;

  @IsEnum(UserRole)
  @IsOptional()
  role?: UserRole = UserRole.USER;
}

// Validation in the middleware
async function validateDto<T extends object>(cls: new () => T, plain: unknown): Promise<T> {
  const instance = plainToInstance(cls, plain);
  const errors = await validate(instance as object);
  if (errors.length > 0) {
    throw new ValidationError(errors.flatMap((e) => Object.values(e.constraints ?? {})));
  }
  return instance;
}

// Usage in the controller
router.post('/users', async (req, res, next) => {
  try {
    const dto = await validateDto(RegisterUserDto, req.body);
    const result = await registerUser.execute(dto);
    respond.created(res, toUserDto(result));
  } catch (error) {
    next(error);
  }
});
```

## Logging Decorators (simple DIY)

```typescript
// Method decorator — automatic call logging
function LogMethod(target: unknown, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value as (...args: unknown[]) => unknown;

  descriptor.value = async function (...args: unknown[]) {
    const start = Date.now();
    logger.debug(`${propertyKey} called`, { args: args.map((a) => typeof a) });
    try {
      const result = await originalMethod.apply(this, args);
      logger.debug(`${propertyKey} completed`, { duration: Date.now() - start });
      return result;
    } catch (error) {
      logger.error(`${propertyKey} failed`, { error, duration: Date.now() - start });
      throw error;
    }
  };

  return descriptor;
}

// Usage
class UserService {
  @LogMethod
  async register(input: RegisterInput): Promise<User> {
    // logged automatically
  }
}
```

## Dependency Injection Decorators (tsyringe)

```typescript
import { injectable, inject, container } from 'tsyringe'

// Tokens for injection
const TOKENS = {
  UserRepository: Symbol('UserRepository'),
  PasswordHasher: Symbol('PasswordHasher'),
  EmailService: Symbol('EmailService'),
  EventBus: Symbol('EventBus'),
} as const

// Mark the classes as injectable
@injectable()
class RegisterUser {
  constructor(
    @inject(TOKENS.UserRepository) private readonly userRepo: UserRepository,
    @inject(TOKENS.PasswordHasher) private readonly hasher: PasswordHasher,
    @inject(TOKENS.EmailService)   private readonly emailer: EmailService,
    @inject(TOKENS.EventBus)       private readonly eventBus: EventBus,
  ) {}

  async execute(input: RegisterInput): Promise<UserDTO> { ... }
}

// Composition root — register the implementations
container.register(TOKENS.UserRepository, { useClass: PrismaUserRepository })
container.register(TOKENS.PasswordHasher, { useClass: BcryptPasswordHasher })
container.register(TOKENS.EmailService,   { useClass: SendgridEmailService })
container.register(TOKENS.EventBus,       { useClass: InMemoryEventBus })

// Resolution
const registerUser = container.resolve(RegisterUser)

// Override for tests — without tsyringe (manual injection preferred)
const registerUser = new RegisterUser(
  new InMemoryUserRepository(),
  new FakePasswordHasher(),
  new SpyEmailService(),
  new InMemoryEventBus(),
)
```

## When NOT to Use Decorators

```typescript
// ❌ Decorators for business logic → tight coupling, hard to test
@RequiresRole('ADMIN')
@ValidateInput(DeleteUserSchema)
async deleteUser(id: string): Promise<void> { ... }
// → authorization and validation logic disappears inside decorators
// → hard to understand execution order, hard to debug

// ✅ Explicit logic in the code — readable and testable
async deleteUser(requesterId: string, targetId: string): Promise<void> {
  const requester = await this.userRepo.findById(requesterId)
  if (!requester || requester.role !== UserRole.ADMIN) {
    throw new InsufficientPermissionsError(requesterId, 'deleteUser')
  }
  const target = await this.userRepo.findById(targetId)
  if (!target) throw new UserNotFoundError(targetId)
  target.delete()
  await this.userRepo.save(target)
}
```
