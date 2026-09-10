# Domain: Authentication

> Example steering file for an authentication domain.
> Copy to `.ai-flow/steering/auth.md` and customize for your project.

## Nano

- **Session tokens** — httpOnly cookies only, the facade is the only door, and every auth state change goes through the store.
- **Login and guards** — one flow through the facade, and guards read the store rather than the provider.
- **Token refresh** — one leader refreshes; concurrent tabs and interceptor retries are the failure modes.

## Session tokens

- Always use the AuthService facade — never access Firebase/Supabase/Auth0 directly from components
- Session tokens must be stored in httpOnly cookies, never localStorage
- All auth state changes must flow through the state management layer (NgRx/Redux/Zustand)
- Password reset tokens expire after 15 minutes — enforce on both client and server
- Don't check `isAuthenticated` by reading the token directly — use the store selector, which is the single source of truth

## Login and guards

- Login flow: Component → AuthFacade → AuthEffect → AuthProvider → Store update → Route redirect
- Guard pattern: route guards read from a store selector, not from the auth provider directly
- Firebase Auth state listener fires on every tab focus — debounce state updates
- OAuth redirect flow loses in-memory state — persist the return URL before redirecting

## Token refresh

- Interceptor handles 401 → refresh token → retry the original request
- Multiple tabs can trigger a refresh simultaneously — use a lock or a single-leader pattern
