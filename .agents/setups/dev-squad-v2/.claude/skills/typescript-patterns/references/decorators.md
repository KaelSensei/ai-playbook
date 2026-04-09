# TypeScript Decorators — Production Patterns

> Decorators nécessitent `"experimentalDecorators": true` et `"emitDecoratorMetadata": true` dans
> tsconfig. En 2024 : TC39 Stage 3, syntaxe stable mais API peut évoluer.

---

## Decorators de Validation (Class Validator)

```typescript
import { IsEmail, IsString, MinLength, MaxLength, IsEnum, IsOptional } from 'class-validator';
import { plainToInstance, Transform } from 'class-transformer';
import { validate } from 'class-validator';

// DTO avec decorators de validation
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

// Validation dans le middleware
async function validateDto<T extends object>(cls: new () => T, plain: unknown): Promise<T> {
  const instance = plainToInstance(cls, plain);
  const errors = await validate(instance as object);
  if (errors.length > 0) {
    throw new ValidationError(errors.flatMap((e) => Object.values(e.constraints ?? {})));
  }
  return instance;
}

// Usage dans le controller
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

## Decorators de Logging (DIY simple)

```typescript
// Decorator de méthode — log automatique des appels
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
    // logué automatiquement
  }
}
```

## Dependency Injection Decorators (tsyringe)

```typescript
import { injectable, inject, container } from 'tsyringe'

// Tokens pour l'injection
const TOKENS = {
  UserRepository: Symbol('UserRepository'),
  PasswordHasher: Symbol('PasswordHasher'),
  EmailService: Symbol('EmailService'),
  EventBus: Symbol('EventBus'),
} as const

// Marquer les classes comme injectables
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

// Composition root — enregistrer les implémentations
container.register(TOKENS.UserRepository, { useClass: PrismaUserRepository })
container.register(TOKENS.PasswordHasher, { useClass: BcryptPasswordHasher })
container.register(TOKENS.EmailService,   { useClass: SendgridEmailService })
container.register(TOKENS.EventBus,       { useClass: InMemoryEventBus })

// Résolution
const registerUser = container.resolve(RegisterUser)

// Override pour les tests — sans tsyringe (injection manuelle préférable)
const registerUser = new RegisterUser(
  new InMemoryUserRepository(),
  new FakePasswordHasher(),
  new SpyEmailService(),
  new InMemoryEventBus(),
)
```

## When NE PAS Utiliser les Decorators

```typescript
// ❌ Decorators pour la logique métier → couplage fort, difficile à tester
@RequiresRole('ADMIN')
@ValidateInput(DeleteUserSchema)
async deleteUser(id: string): Promise<void> { ... }
// → la logique d'autorisation et de validation disparaît dans les decorators
// → difficile à comprendre l'ordre d'exécution, difficile à déboguer

// ✅ Logique explicite dans le code — lisible et testable
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
