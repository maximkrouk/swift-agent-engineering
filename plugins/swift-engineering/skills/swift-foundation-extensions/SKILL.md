---
name: swift-foundation-extensions
description: >-
  Use when working with FoundationExtensions from https://github.com/capturecontext/swift-foundation-extensions, especially for Foundation convenience APIs around coding containers, NSLocking helpers, Optional helpers, undo/resettable patterns, associated-object-based APIs, swizzling, or when the package is used as a compatibility reexport for Resettable, Equated, and AssociatedObjects.
---

# Swift Foundation Extensions

Use this package when the codebase already depends on `FoundationExtensions` and wants its convenience APIs rather than hand-rolled Foundation helpers.

## Defaults

1. Prefer narrower upstream packages when the codebase already imports them directly.
2. Use `FoundationExtensions` as the façade when that is what the project depends on.
3. Remember that it reexports compatibility APIs from `swift-resettable`, `swift-equated`, and `swift-associated-objects`.
4. Keep new usage focused on concrete helpers instead of treating the package as a generic dumping ground.

## Main Areas

- coding helpers and `RawCodingKey`
- `NSLocking` convenience APIs
- `Optional` helpers like `orThrow`, `or`, `unwrap`, assignment helpers
- undo/resettable compatibility exports
- associated objects compatibility exports
- swizzling helpers

## Workflow

1. Check whether the codebase imports `FoundationExtensions` directly or only uses one of its reexported upstream packages.
2. If using coding helpers, prefer the contextual container APIs over repetitive manual keyed-container plumbing.
3. If using locks, prefer the package’s locked mutation helpers over open-coded `lock()` / `unlock()` pairs.
4. If using optional utilities, prefer the provided helpers only when they make intent clearer than standard Swift.
5. If the relevant API truly belongs to `Resettable`, `Equated`, or `AssociatedObjects`, acknowledge that `FoundationExtensions` is mainly reexporting it.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Foundation Helpers](references/foundation-helpers.md)** | Any use of coding helpers, optionals, locking, swizzling, or reexported Foundation-adjacent APIs |

## Common Mistakes

1. Treating this package as a reason to avoid standard Foundation APIs when they are already clear.
2. Forgetting that some APIs are compatibility reexports and may move back to their dedicated packages.
3. Adding custom helper layers that duplicate the package’s lock or coding utilities.
