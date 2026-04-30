---
name: swift-keypaths-extensions
description: >-
  Use when working with KeyPathsExtensions from https://github.com/capturecontext/swift-keypaths-extensions, especially for optional key path composition, unwrapping optional paths with defaults, optional-root lifting, sendable key path helpers, or when code relies on the package's reexport of swift-keypath-mapping.
---

# Swift KeyPaths Extensions

Use `KeyPathsExtensions` when standard Swift key paths become awkward because of optionality, composition, derived writable paths, or sendability.

## Defaults

1. Prefer ordinary Swift key paths when they already express the target access cleanly.
2. Reach for this package when optionality blocks composition or writable behavior.
3. Remember that this package reexports `KeyPathMapping`.
4. Prefer `KeyPathsExtensions` imports in codebases that rely on both mapping and optionality helpers.

## Preferred Shapes

```swift
let rootToProperty: KeyPath<Root, Property?> = \.optionalProperty
let propertyToValue: KeyPath<Property, Int> = \.intValue

let combined: KeyPath<Root, Int?> = rootToProperty.appending(path: propertyToValue)
let value: KeyPath<Root, Int> = combined.unwrapped(with: 0)
```

```swift
let kp: KeyPath<Root?, Int?> = \Root.optionalProperty?.intValue
let lifted = \Root.optionalProperty.withOptionalRoot()
```

## Workflow

1. Check whether plain key-path syntax already solves the access pattern.
2. If optional composition is blocked, use `appending(path:)`.
3. If a non-optional consumer needs a defaulted path, use `unwrapped(with:)`.
4. If the root itself must become optional, use `withOptionalRoot()`.
5. If the codebase also needs mapping helpers, treat this package as a façade over `swift-keypath-mapping`.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Optional Key Paths](references/optional-key-paths.md)** | Any usage of optional key paths, `unwrapped(with:)`, `withOptionalRoot()`, or reexported key-path mapping |

## Common Mistakes

1. Replacing ordinary key paths with package helpers unnecessarily.
2. Forgetting that `KeyPathsExtensions` reexports `KeyPathMapping`.
3. Assuming aggressive unwrapping is always safe for nested reference types.
4. Reaching for ad-hoc closure-based access where a stable key path would preserve identity better.
