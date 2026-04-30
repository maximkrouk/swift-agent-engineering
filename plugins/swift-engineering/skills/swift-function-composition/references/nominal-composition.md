# Nominal Composition

`FunctionComposition` centers on nominal wrappers over raw function types.

## Installation

```swift
.package(
	url: "https://github.com/capturecontext/swift-function-composition.git",
	.upToNextMinor(from: "0.0.1"),
	traits: ["NominalTypes", "Operators", "Methods", "Functions", "Currying"]
)
```

Target dependency:

```swift
.product(
	name: "FunctionComposition",
	package: "swift-function-composition"
)
```

Import:

```swift
import FunctionComposition
```

## Core Wrappers

- `SyncFunc<Input, Output>`
- `SyncThrowingFunc<Input, Output, Failure>`
- `AsyncFunc<Input, Output>`
- `AsyncThrowingFunc<Input, Output, Failure>`
- `Sendable...` variants
- `MainActor...` variants

## Composition APIs

- operators like `<<<`
- methods like `.compose(...)`
- functions like `compose(...)` and `pipe(...)`

## Preservation Rules

- sync + async -> async
- non-throwing + throwing -> throwing
- sendable + non-sendable -> non-sendable
- sendable + main-actor -> main-actor
- mismatched throwing failures -> `Either`

## Explicit Upgrades

```swift
let sendable = SyncFunc<Int, Bool> { $0 != 0 }
	.uncheckedSendable()
```

```swift
let mainActor = SendableSyncFunc<Bool, String> { $0 ? "true" : "false" }
	.mainActor()
```

