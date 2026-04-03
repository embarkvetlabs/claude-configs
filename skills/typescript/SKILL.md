---
name: typescript
description: Use when writing or reviewing TypeScript code. Covers strict typing patterns, error handling, testing with vitest/jest, async patterns, and common pitfalls.
---

# TypeScript Best Practices

## Strict Typing

- Enable `strict: true` in tsconfig. No exceptions.
- Never use `any`. Use `unknown` + type narrowing, or define a proper type.
- Prefer `interface` for object shapes (extendable). Use `type` for unions, intersections, and mapped types.
- Use discriminated unions for state machines and variant types:

```typescript
// Good — exhaustive, self-documenting
type Result<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error }
  | { status: 'loading' }

// The compiler will catch missing cases
function handle<T>(result: Result<T>) {
  switch (result.status) {
    case 'success': return result.data
    case 'error': throw result.error
    case 'loading': return null
    // If you add a new status, TS will error here
  }
}
```

- Use `as const` for literal types and `satisfies` for type-safe object literals:

```typescript
const ROUTES = {
  home: '/',
  profile: '/profile',
} as const satisfies Record<string, string>
```

## Error Handling

- Don't throw strings. Always throw `Error` or a subclass.
- For expected failures (validation, not-found), return a Result type instead of throwing.
- Catch specific errors when possible. Never catch-and-ignore.
- Use `unknown` for catch variables (TS 4.4+):

```typescript
try {
  await fetchData()
} catch (error: unknown) {
  if (error instanceof NetworkError) {
    // handle specifically
  }
  throw error // re-throw what you don't handle
}
```

## Async Patterns

- Always handle promise rejections. Unhandled rejections crash Node.
- Use `Promise.allSettled` when you need all results regardless of failures.
- Use `Promise.all` when any failure should abort the batch.
- Avoid `async` on functions that just return a promise — it adds an unnecessary microtask.
- Use `AbortController` for cancellable operations.

## Testing (Vitest / Jest)

- Test behavior, not implementation. Call the function, check the output.
- Use `describe` blocks to group by scenario, `it` blocks for specific assertions.
- Use `beforeEach` for shared setup. Avoid `beforeAll` unless setup is genuinely expensive.
- Mock external dependencies (APIs, databases), not internal modules.
- Use `vi.fn()` / `jest.fn()` for spies. Assert on calls only when the side effect IS the behavior.
- For async tests, always `await` — don't forget to return promises.

```typescript
describe('createUser', () => {
  it('returns the created user with an id', async () => {
    const user = await createUser({ name: 'Paul', email: 'paul@test.com' })
    expect(user.id).toBeDefined()
    expect(user.name).toBe('Paul')
  })

  it('throws on duplicate email', async () => {
    await createUser({ name: 'Paul', email: 'paul@test.com' })
    await expect(
      createUser({ name: 'Other', email: 'paul@test.com' })
    ).rejects.toThrow('email already exists')
  })
})
```

## Common Pitfalls

- **Optional chaining abuse:** `a?.b?.c?.d` usually means your types are wrong. Fix the types.
- **Type assertions (`as`):** Almost always wrong. Use type guards or narrowing instead.
- **Enums:** Prefer `as const` objects or union types. Enums have runtime overhead and quirky behavior.
- **Index signatures:** `Record<string, T>` doesn't guarantee the key exists. Access returns `T`, not `T | undefined`, unless you enable `noUncheckedIndexedAccess`.
- **Mutable default parameters:** Objects/arrays as defaults are shared across calls in some patterns. Use factory functions.
- **Barrel files (index.ts re-exports):** They break tree-shaking and create circular dependency traps. Use direct imports.
- **Non-null assertion (`!`):** Same risk as `any` — you're lying to the compiler. Use a proper null check.

## Module Organization

- One export per file for major types/classes. Co-locate related helpers.
- Put types in the same file as the code that uses them, not in a separate `types.ts` (unless shared across modules).
- Use path aliases (`@/`) for cross-directory imports. Relative paths for same-directory.
