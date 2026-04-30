# Closure Capture

Use this reference whenever the codebase depends on `Capture` and closure capture style needs to follow the package instead of manual capture lists.

## Installation

```swift
.package(
	url: "https://github.com/capturecontext/swift-capture.git",
	.upToNextMajor(from: "4.0.0")
)
```

Target dependency:

```swift
.product(
	name: "Capture",
	package: "swift-capture"
)
```

Import:

```swift
import Capture
```

## Core Preference

Prefer:

```swift
service.fetch { [weak self] value in
	guard let self else { return }
	self.value = value
}
```

to become:

```swift
service.fetch(completion: self.capture { _self, value in
	_self.value = value
})
```

Use the package to remove weak-capture noise while preserving the semantics of “do nothing if the object is already gone.”

## Basic API

### Closure capture

```swift
completion = self.capture { _self in
	_self.reload()
}
```

### With arguments

```swift
network.perform(request, completion: self.capture { _self, response, data, error in
	_self.handle(response: response, data: data, error: error)
})
```

Variadic generics handle arbitrary closure argument counts.

## Return Values

If the closure returns `Void`, no fallback is needed.

If it returns an optional, the object being gone naturally returns `nil`.

If it returns a non-optional concrete value, use `orReturn`:

```swift
let isEnabled: () -> Bool = self.capture(orReturn: false) { _self in
	_self.isEnabled
}
```

```swift
dataSource.numberOfItems = self.capture(orReturn: 0) { _self in
	_self.items.count
}
```

You can also use the functor form:

```swift
let numberOfItems = self.capture.orReturn(0) { _self in
	_self.items.count
}
```

## Key Paths and Methods

Use `in:` when the capture target is naturally a key path or method reference.

### Key path

```swift
dataSource.numberOfItems = self.capture(orReturn: 0, in: \.items.count)
```

### Method reference

```swift
let redo: () -> Void = self.capture(in: uncurryMethod(Editor.redo))
let undo: () -> Void = self.capture(in: uncurryMethod(Editor.undo))
```

Prefer direct closures if they are clearer than the helper.

## Capture Strategy

### Weak

Default and preferred for most code:

```swift
self.capture { _self in
	_self.update()
}
```

### Strong

Use when the closure must keep the object alive through execution:

```swift
self.capture(as: .strong) { _self in
	_self.performCriticalWork()
}
```

Or:

```swift
self.capture.as(.strong).orReturn(()) { _self in
	_self.performCriticalWork()
}
```

### Unowned

Use only when the object is guaranteed to outlive the closure:

```swift
self.capture(as: .unowned) { _self in
	_self.fastPath()
}
```

If that guarantee is not watertight, do not use `unowned`.

## Async and Throwing Variants

The API supports sync, throwing, async, and async-throwing closures.

```swift
let f0 = self.capture { _self in
	_self.work()
}

let f1 = self.capture { _self throws in
	try _self.throwingWork()
}

let f2 = self.capture { _self async in
	await _self.asyncWork()
}

let f3 = self.capture { _self async throws in
	try await _self.asyncThrowingWork()
}
```

The same applies to `orReturn`.

## Sendability and Main Actor

When a closure must be `@Sendable`, use the sendable APIs.

If the underlying type is not statically sendable but the usage is intentionally safe, `uncheckedSendable` is available as an explicit escape hatch.

```swift
let callback: @Sendable () -> Int = self.capture
	.uncheckedSendable
	.orReturn(0) { _self in
		_self.count
	}
```

Use `onMainActor` when the closure must preserve `@MainActor` isolation:

```swift
let render: @MainActor () -> Void = self.capture
	.uncheckedSendable
	.onMainActor { _self in
		_self.render()
	}
```

There are `onMainActor(orReturn:)` variants as well.

Do not add `uncheckedSendable` unless you actually need a `@Sendable` closure boundary.

## Functor API

The `.capture` property exposes a functor-style interface:

```swift
self.capture.orReturn(0) { _self in
	_self.items.count
}
```

```swift
self.capture.as(.strong)(in: { _self in
	_self.performWork()
})
```

Useful capabilities:

- `.as(.weak | .strong | .unowned)`
- `.orReturn(...)`
- `.uncheckedSendable`
- `.onMainActor`

## Compiler Bug / Workaround

This valid-looking shape does not currently compile:

```swift
self.capture.as(.strong) { _self in
	_self.performWork()
}
```

Prefer one of:

```swift
self.capture.as(.strong)(in: { _self in
	_self.performWork()
})
```

```swift
self.capture.as(.strong).orReturn(()) { _self in
	_self.performWork()
}
```

```swift
self.capture.as(.strong).callAsFunction { _self in
	_self.performWork()
}
```

## Custom Types

`NSObject` subclasses are already supported.

For custom reference types:

```swift
final class Worker: CapturableObjectProtocol {
	var isRunning: Bool = false
}
```

## Low-Level Containers

This package also exposes:

- `Captured`
- `Weak`
- `Strong`
- `Unowned`

Use them only when you need explicit storage/container semantics. For ordinary closure creation, prefer `object.capture...`.
