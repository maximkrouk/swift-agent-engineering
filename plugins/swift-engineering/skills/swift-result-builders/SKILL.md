---
name: swift-result-builders
description: >-
  Use when working with ArrayBuilder from https://github.com/capturecontext/swift-result-builders, especially when creating collection initializers or APIs that should accept heterogeneous array-like builder blocks and flatten conditionals, nested arrays, and loops into a final array.
---

# Swift Result Builders

Use this package when the codebase wants array-producing builder blocks instead of manually assembling `[Element]`.

## Defaults

1. This package is currently about `ArrayBuilder`.
2. Use it for APIs that naturally collect many elements into an array.
3. Prefer it for DSL-like call sites, collection initializers, and declarative child lists.
4. Do not introduce it where a plain array literal or ordinary function arguments are simpler.

## Preferred Shapes

```swift
extension IdentifiedArray where Element: Identifiable, ID == Element.ID {
	@inlinable
	public init(
		@ArrayBuilder<Element> uniqueElements: () -> [Element]
	) {
		self.init(uniqueElements: uniqueElements())
	}
}
```

```swift
let values: [Int] = Array {
	1
	2
	[3, 4]
	if includeMore {
		5
	}
}
```

## Workflow

1. Check whether the target API is fundamentally “build an array from declarative pieces”.
2. If yes, add an `@ArrayBuilder<Element>` parameter returning `[Element]`.
3. Keep the public API focused on the result, not the builder internals.
4. Let callers mix direct elements, arrays, conditionals, and loops naturally.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Array Builder](references/array-builder.md)** | Any use of `@ArrayBuilder`, collection initializers, or array-building DSL APIs |

## Common Mistakes

1. Adding `ArrayBuilder` to APIs that do not naturally produce arrays.
2. Replacing simple array literals with builder syntax for no readability gain.
3. Leaking builder implementation details into the API instead of exposing a clean `[Element]` result.
