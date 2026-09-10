# Domain: API Layer

> Example steering file for a REST/GraphQL API domain.
> Copy to `.ai-flow/steering/api.md` and customize for your project.

## Nano

- **Request boundary** — validate at the edge, keep the layer order, and never let an internal ID out.
- **Responses and paging** — one error shape, cursor paging for lists, and a hard ceiling per page.
- **Versioning** — a URL prefix for breaking changes only; additive changes need no new version.
- **Mutations** — idempotent or keyed, and batch or delete-all needs an explicit admin check.

## Request boundary

- All endpoints must validate input at the boundary (DTOs, schemas, or middleware)
- Never expose internal IDs in error messages or logs
- Controller → Service → Repository, never skipping layers
- Rate limiting is per-API-key, not per-user — one user with several keys can bypass the limit

## Responses and paging

- Error responses follow the format `{ error: string, code: string, details?: object }`
- Pagination: cursor-based for lists, offset-based only for admin dashboards
- Default limit of 100 items per page, maximum 500
- N+1 queries: check DataLoader usage whenever a nested relation is resolved

## Versioning

- URL prefix (`/v1/`, `/v2/`) for breaking changes; additive changes do not need a new version

## Mutations

- All mutations must be idempotent or use idempotency keys
- GraphQL: never expose `deleteAll` or batch mutations without an explicit admin role check
