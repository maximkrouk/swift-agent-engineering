# Foundation Helpers

`FoundationExtensions` is a broad package with both native helpers and compatibility reexports.

## Installation

```swift
.package(
  url: "https://github.com/capturecontext/swift-foundation-extensions.git",
  .upToNextMinor(from: "0.7.0")
)
```

## Reexports / Compatibility Layer

This package currently exposes compatibility access to:

- `Resettable`
- `Equated`
- `AssociatedObjects`
- `AssociatedObjectsMacros` via `FoundationExtensionsMacros`

If the codebase already depends on those narrower packages directly, prefer their dedicated semantics.

## Key Native Areas

### Coding

```swift
init(from decoder: Decoder) throws {
  self = try container.decode(RawCodingKey.self) { container in
    .init(
      someProperty1: container.decode("someProperty1"),
      someProperty2: container.decode("some_property_2")
    )
  }
}
```

### Optional helpers

- `orThrow(_:)`
- `or(_:)`
- `unwrap()`
- assignment helpers

### NSLocking helpers

- `store(_:in:)`
- `mutate(_:with:)`
- `assign(_:to:on:)`
- `execute(_:)`

### Swizzling / associations

Use only in codebases that already embrace those runtime techniques.

