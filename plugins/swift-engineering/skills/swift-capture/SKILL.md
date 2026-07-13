---
name: swift-capture
description: >-
  Use when replacing weak-self closure boilerplate with Capture from https://github.com/capturecontext/swift-capture, especially for callbacks, async handlers, UI actions, delegate/data source closures, key-path capture, default return values via orReturn, strategy overrides (weak/strong/unowned), or sendable/main-actor capture wrappers.
---

# Swift Capture

Use `Capture` when working with reference-type closure captures and the codebase wants `swift-capture` instead of manual `[weak self]` / `guard let self` boilerplate.

## Defaults

1. Prefer `capture { _self, ... in ... }` over handwritten weak-capture boilerplate.
2. Default to `.weak` capture unless lifetime requirements clearly justify `.strong` or `.unowned`.
3. For non-`Void` and non-optional outputs, use `orReturn`.
4. Prefer method APIs like `object.capture(as: .strong) { ... }` for explicit strategy overrides.
5. Use key-path and method capture helpers when they simplify the call site.
6. Treat `uncheckedSendable` and `unsafe` overrides as escape hatches, not defaults.

## Package Facts

- Remote URL: `https://github.com/capturecontext/swift-capture`
- Product: `Capture`
- All `NSObject` subclasses are capturable by default
- Custom reference types opt in with `CapturableObjectProtocol`
- Low-level containers exist: `Weak`, `Strong`, `Unowned`, `Captured`

## Preferred Shapes

### Basic weak capture

```swift
apiClient.loadItems(
  completion: self.capture { _self, items in
    _self.items = items
  }
)
```

### Default return value

```swift
dataSource.numberOfItems = self.capture(orReturn: 0) { _self in
  _self.items.count
}
```

### Key-path capture

```swift
dataSource.numberOfItems = self.capture(orReturn: 0, in: \.items.count)
```

### Explicit capture strategy

```swift
self.capture(as: .strong) { _self in
  _self.performCriticalWork()
}
```

### Functor-style override

```swift
self.capture.as(.strong).orReturn(()) { _self in
  _self.performWork()
}
```

### Main-actor sendable closure

```swift
let updateUI: @MainActor () -> Void = self.capture
  .uncheckedSendable
  .onMainActor { _self in
    _self.render()
  }
```

## Workflow

1. Check whether the captured type is an `NSObject` subclass or another reference type.
2. If the code is currently using `[weak self]` + `guard let self`, replace it with `capture`.
3. If the closure returns a required concrete value when the object may already be gone, use `orReturn`.
4. If the closure can naturally read from a key path or method reference, prefer `in:` forms.
5. If the code needs a stronger lifetime guarantee, pick `.strong` or `.unowned` deliberately and document why if the choice is non-obvious.
6. If the closure must remain `@Sendable` or `@MainActor`, use the sendable/main-actor APIs intentionally.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Closure Capture](references/closure-capture.md)** | Any usage of `capture`, `orReturn`, strategy overrides, sendability, or low-level capture containers |

## Common Mistakes

1. Keeping manual `[weak self]` boilerplate in a codebase that already depends on `swift-capture`.
2. Using `.strong` by default instead of only when a retained lifetime is actually required.
3. Using `.unowned` when the captured object may deallocate before invocation.
4. Forgetting `orReturn` for non-optional, non-`Void` outputs.
5. Using the functor override trailing-closure form `object.capture.as(.strong) { ... }`, which currently hits a Swift compiler issue.
6. Reaching for `uncheckedSendable` without a real sendability constraint.
7. Introducing `Captured`, `Weak`, `Strong`, or `Unowned` when the higher-level `capture` API is sufficient.

## Strategy Guide

- `.weak`: default for most callbacks, UI events, async completions, delegate/data-source closures
- `.strong`: only when the closure must keep the object alive through execution
- `.unowned`: only when lifetime is provably longer than the closure

## Compiler Quirk

Avoid this currently broken trailing-closure shape:

```swift
self.capture.as(.strong) { _self in
  _self.performWork()
}
```

Prefer:

```swift
self.capture.as(.strong)(in: { _self in
  _self.performWork()
})
```

Or:

```swift
self.capture.as(.strong).orReturn(()) { _self in
  _self.performWork()
}
```
