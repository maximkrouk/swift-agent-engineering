---
name: swift-function-composition
description: >-
  Use when working with FunctionComposition from https://github.com/capturecontext/swift-function-composition, especially for nominal function wrappers, composition pipelines that preserve async/throws/sendable/MainActor semantics, trait-based operator/method/function APIs, Either-based failure composition, or currying helpers.
---

# Swift Function Composition

Use this package when closure composition must preserve stronger semantics than raw `(A) -> B` types encode well.

## Defaults

1. Prefer plain closures when composition is simple and no nominal semantics are needed.
2. Use this package when async, throws, sendability, or `MainActor` isolation matter structurally.
3. Choose the smallest wrapper family that matches the effect model.
4. Respect package traits: operators, methods, functions, currying, and nominal types may be conditionally enabled.

## Preferred Shapes

```swift
let isNotZero: SyncFunc<Int, Bool> = .init { $0 != 0 }
let describe: SyncFunc<Bool, String> = .init { $0 ? "true" : "false" }

let pipeline = describe.compose(isNotZero)
```

```swift
let loadFlag: SendableAsyncThrowingFunc<Int, Bool, Never> = .init { $0 != 0 }
let describe: SendableSyncFunc<Bool, String> = .init { $0 ? "true" : "false" }

let pipeline = describe <<< loadFlag
```

## Workflow

1. Identify the strongest effect model needed: sync/async, throwing/non-throwing, sendable/non-sendable, main-actor.
2. Wrap each function in the matching nominal type.
3. Compose using the API surface enabled by package traits.
4. Convert to stronger wrappers explicitly with `.uncheckedSendable()` or `.mainActor()` when justified.
5. Expect failure types to compose through `Either` when throwing wrappers disagree.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Nominal Composition](references/nominal-composition.md)** | Any use of `SyncFunc`, async/throwing variants, operators/methods/functions traits, `Either`, or currying |

## Common Mistakes

1. Using nominal wrappers where plain closures would be clearer.
2. Forgetting that composition APIs depend on enabled SwiftPM traits.
3. Upgrading to sendable or main-actor wrappers without actually satisfying the contract.
4. Assuming free-function composition is as flexible as operators or methods.
