# Optional Key Paths

`KeyPathsExtensions` focuses on optionality, composition, and a reexport of `KeyPathMapping`.

## Installation

```swift
.package(
  url: "https://github.com/capturecontext/swift-keypaths-extensions.git",
  .upToNextMajor(from: "0.2.0")
)
```

Target dependency:

```swift
.product(
  name: "KeyPathsExtensions",
  package: "swift-keypaths-extensions"
)
```

Import:

```swift
import KeyPathsExtensions
```

## Key APIs

- `withOptionalRoot()`
- `appending(path:)` for optional-value key paths
- `unwrapped(with:aggressive:)`
- sendable key-path aliases and `unsafeSendable()`
- reexported `KeyPathMapping`

## Typical Pattern

```swift
let p0: KeyPath<Root, Property?> = \.optionalProperty
let p1: KeyPath<Property, Int> = \.intValue

let combined: KeyPath<Root, Int?> = p0.appending(path: p1)
let stable: KeyPath<Root, Int> = combined.unwrapped(with: 0)
```

## Guidance

- Prefer built-in `\.optional?.value` syntax when it is enough.
- Use package helpers when you need to combine arbitrary paths or restore a non-optional projection.
- Be cautious with aggressive unwrapping in nested reference-type graphs.

