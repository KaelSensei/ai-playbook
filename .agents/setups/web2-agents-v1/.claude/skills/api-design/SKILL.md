---
name: api-design
description: >
  REST API design, conventions, versioning, error contracts, pagination, validation. Auto-loaded by
  architect and dev-senior-a/b. Invoke for any question about endpoint design, response format,
  error handling, or REST conventions.
---

# API Design Reference

## REST Conventions

### URLs

```
# Resources as plurals, nouns not verbs
✅ GET    /api/v1/users
✅ GET    /api/v1/users/:id
✅ POST   /api/v1/users
✅ PATCH  /api/v1/users/:id    (partial update)
✅ PUT    /api/v1/users/:id    (full replacement)
✅ DELETE /api/v1/users/:id

# Nested relations (max 2 levels)
✅ GET    /api/v1/users/:id/posts
✅ POST   /api/v1/users/:id/posts
❌ GET    /api/v1/users/:id/posts/:postId/comments/:commentId  (too deep)

# Non-CRUD actions → sub-resource or verb in the URL
✅ POST   /api/v1/users/:id/activate
✅ POST   /api/v1/auth/refresh
✅ POST   /api/v1/orders/:id/cancel
```

### Status Codes

```
200 OK           — GET/PATCH/PUT success with body
201 Created      — POST success, return the created resource
204 No Content   — DELETE success, or action with no return body
400 Bad Request  — validation failed, invalid input
401 Unauthorized — not authenticated (token missing or invalid)
403 Forbidden    — authenticated but not authorized
404 Not Found    — resource does not exist
409 Conflict     — conflict (email already taken, incompatible state)
422 Unprocessable — parseable entity but logically invalid
429 Too Many Requests — rate limit hit
500 Internal Server Error — internal error (never expose details in prod)
```

## Response Format

### Success

```json
// List with pagination
{
  "data": [...],
  "meta": {
    "total": 150,
    "page": 1,
    "perPage": 20,
    "totalPages": 8
  }
}

// Single item
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### Errors (uniform format)

```json
// Simple error
{
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with id 'xyz' not found"
  }
}

// Validation errors (multiple fields)
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [
      { "field": "email", "message": "Must be a valid email address" },
      { "field": "password", "message": "Must be at least 8 characters" }
    ]
  }
}
```

### Business error codes (uppercase snake_case)

```typescript
// Centralized in an enum
enum ErrorCode {
  USER_NOT_FOUND = 'USER_NOT_FOUND',
  EMAIL_TAKEN = 'EMAIL_TAKEN',
  INVALID_TOKEN = 'INVALID_TOKEN',
  PLAN_REQUIRED = 'PLAN_REQUIRED',
  RATE_LIMIT = 'RATE_LIMIT',
}
```

## Versioning

```
/api/v1/...   — version in the URL (simple, explicit)

Rule: bump to v2 on a breaking change.
A breaking change = removing/renaming a field, changing a type,
removing an endpoint, changing the semantics of a parameter.
```

## Pagination

```typescript
// Cursor-based (recommended for large datasets)
GET /api/v1/posts?cursor=eyJpZCI6MTAwfQ&limit=20
{
  "data": [...],
  "meta": {
    "nextCursor": "eyJpZCI6MTIwfQ",
    "hasMore": true
  }
}

// Offset-based (simple, for datasets <= 10k)
GET /api/v1/posts?page=2&perPage=20
```

## Input Validation

```typescript
// Always validate server-side, even if validated client-side
// Use a validation schema (Zod, Joi, class-validator)

const createUserSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(8).max(100).regex(/[A-Z]/).regex(/[0-9]/),
  role: z.enum(['USER', 'ADMIN']).default('USER'),
});

// Return 400 with details if validation fails
// Never pass unvalidated data to the service layer
```

## API Security

```
- Authentication: JWT Bearer token in the Authorization header
- Authorization: check permissions in the service layer, not only in the controller
- CORS: explicit allowlist of accepted origins
- Rate limiting: at minimum on sensitive endpoints (see constants.md)
- Sanitization: never return the password hash or internal tokens
- Idempotency key: on critical operations (payment, email dispatch)
```
