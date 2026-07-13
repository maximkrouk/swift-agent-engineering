# Array Builder

Use `ArrayBuilder` for declarative array construction.

## Installation

```swift
.package(
  url: "https://github.com/capturecontext/swift-result-builders.git",
  .upToNextMinor(from: "0.0.2")
)
```

Target dependency:

```swift
.product(
  name: "ArrayBuilder",
  package: "swift-result-builders"
)
```

Import:

```swift
import ArrayBuilder
```

## Core Pattern

```swift
public init(
  @ArrayBuilder<Element> elements: () -> [Element]
) {
  self.init(elements())
}
```

Callers can then write:

```swift
let values: [String] = Array {
  "one"
  "two"
  if includeMore {
    "three"
  }
  ["four", "five"]
}
```

## Good Fits

- collection initializers
- declarative child lists
- test fixtures
- lightweight DSLs that flatten many elements into one array

## Poor Fits

- APIs producing a single value
- cases where a plain array literal is already clearer

