# Domain: Authentication

> Example steering file for an authentication domain.
> Copy to `.ai-flow/steering/auth.md` and customize for your project.

## Rules
- Always use the AuthService facade — never access Firebase/Supabase/Auth0 directly from components
- Session tokens must be stored in httpOnly cookies, never localStorage
- All auth state changes must flow through the state management layer (NgRx/Redux/Zustand)
- Password reset tokens expire after 15 minutes — enforce on both client and server

## Patterns
- Login flow: Component → AuthFacade → AuthEffect → AuthProvider → Store update → Route redirect
- Guard pattern: Route guards read from store selector, not from auth provider directly
- Token refresh: Interceptor handles 401 → refresh token → retry original request

## Pitfalls
- Firebase Auth state listener fires on every tab focus — debounce state updates
- Don't check `isAuthenticated` by reading the token directly — use the store selector (single source of truth)
- OAuth redirect flow loses in-memory state — persist return URL before redirect
- Race condition: multiple tabs can trigger token refresh simultaneously — use a lock or single-leader pattern
