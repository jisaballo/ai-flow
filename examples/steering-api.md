# Domain: API Layer

> Example steering file for a REST/GraphQL API domain.
> Copy to `.ai-flow/steering/api.md` and customize for your project.

## Rules
- All endpoints must validate input at the boundary (DTOs, schemas, or middleware)
- Error responses follow the format: `{ error: string, code: string, details?: object }`
- Never expose internal IDs in error messages or logs
- All mutations must be idempotent or use idempotency keys

## Patterns
- Controller → Service → Repository (never skip layers)
- Pagination: cursor-based for lists, offset-based only for admin dashboards
- Versioning: URL prefix (`/v1/`, `/v2/`) for breaking changes, additive changes don't need new versions

## Pitfalls
- N+1 queries: Always check DataLoader usage when resolving nested relations
- Large payloads: Default limit of 100 items per page, maximum 500
- Rate limiting is per-API-key, not per-user — a single user with multiple keys can bypass limits
- GraphQL: Don't expose `deleteAll` or batch mutations without explicit admin role check
