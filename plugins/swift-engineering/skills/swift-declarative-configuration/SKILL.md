---
name: swift-declarative-configuration
description: >-
  Use when configuring Cocoa views and nested Cocoa objects with DeclarativeConfiguration from https://github.com/capturecontext/swift-declarative-configuration, especially for inline UIKit/AppKit setup like SomeView() { $0 ... }, reusable Configurator styles, scoped nested configuration, optional configuration via ifLet, or Builder-based configuration already present in the codebase.
---

# Swift Declarative Configuration

Use `DeclarativeConfiguration` when setting up Cocoa views, layers, controls, or nested Cocoa objects with fluent configuration instead of imperative property assignment.

## Defaults

1. Prefer `Configurator` over `Builder`.
2. Prefer inline configuration at the call site for one-off view setup.
3. Extract repeated setup into reusable `Configurator` values or factory methods.
4. Extract only generic configuration into reusable `Configurator`s. If a view style is domain-specific, prefer a dedicated view type instead of a reusable configuration helper.
5. Label text styles are the main exception: extracting reusable `UILabel` / `NSTextField` styles is usually appropriate even when they reflect product language.
6. Use `scope` for nested objects like `layer`, `titleLabel`, `imageView`, `configuration`, and similar Cocoa subobjects.
7. Use `ifLet`, `ifLet(else:)`, `.property(ifLet:)`, and `ifNil` instead of imperative optional branching when the package already models the configuration declaratively.
8. Keep `Builder` support in mind when reading existing code, but do not introduce it unless the codebase already uses it or instance-bound chaining is clearly a better fit.

## Package Facts

- Remote URL: `https://github.com/capturecontext/swift-declarative-configuration`
- Primary product: `DeclarativeConfiguration`
- `NSObject` subclasses already support inline configuration and `.builder`
- Custom types can opt in with `DefaultConfigurableProtocol`
- Custom types can opt into `.builder` with `BuilderProvider`

## Preferred Shapes

### Inline Cocoa configuration

```swift
let titleLabel = UILabel() { $0
  .text("Title")
  .font(.preferredFont(forTextStyle: .headline))
  .textColor(.label)
  .numberOfLines(0)
}
```

### Reusable configuration

```swift
extension Configurator where Base: UILabel {
  @MainActor
  static var title: Self {
    .init { $0
      .font(.preferredFont(forTextStyle: .headline))
      .textColor(.label)
      .numberOfLines(0)
    }
  }
}

let titleLabel = UILabel().configured(using: .title.text("Welcome"))
```

### Scoped nested configuration

```swift
let view = UIView() { $0
  .backgroundColor(.secondarySystemBackground)
  .layer.scope { $0
    .cornerRadius(12)
    .cornerCurve(.continuous)
    .borderWidth(1)
    .borderColor(.separator)
  }
}
```

### Conditional optional configuration

```swift
let subtitleLabel = UILabel() { $0
  .text(ifLet: subtitle)
  .attributedText(ifLet: attributedSubtitle)
}
```

### Optional nested objects

```swift
let button = UIButton(type: .system) { $0
  .configuration.ifLet.scope { $0
    .title("Continue")
    .image(ifLet: image)
  }
}
```

## Workflow

1. Check whether the target type is a Cocoa object with dynamic properties.
2. If the configuration is local and one-off, use `SomeView() { $0 ... }`.
3. If the same configuration appears multiple times, decide whether it is generic or domain-specific.
4. If it is generic setup, extract a reusable `Configurator`. If it represents a domain view concept, prefer a dedicated `UIView` / `NSView` / control type.
5. Label styles are a valid exception and can be extracted as reusable `Configurator`s.
6. If configuration reaches into nested Cocoa objects, use `scope` instead of imperative `view.layer...` chains.
7. If optional values are involved, prefer package-native optional helpers instead of `if` trees when readability improves.
8. If the existing code already uses `.builder`, preserve the pattern unless converting to `Configurator` is clearly beneficial and safe.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Cocoa Views](references/cocoa-views.md)** | Any UIKit/AppKit/CALayer configuration using this package |

## Common Mistakes

1. Writing imperative `view.property = value` chains when `SomeView() { $0 ... }` is more consistent with the codebase.
2. Introducing `Builder` for new code when a `Configurator` or inline call-site configuration would be simpler.
3. Extracting domain-specific view styling into `Configurator`s when the code should instead introduce a dedicated view type.
4. Repeating long inline chains instead of extracting reusable generic `Configurator` extensions.
5. Reaching into nested objects imperatively instead of using `.scope { $0 ... }`.
6. Using manual optional branching where `.property(ifLet:)`, `.ifLet`, or `.ifLet(else:)` fits naturally.
7. Forgetting that `NSObject` subclasses already support this API directly.
8. Hitting the known Swift `callAsFunction` inference issue by writing `let value: Type = .init() { $0 ... }`.

## Known Issue

Avoid this shape:

```swift
let view: UIView = .init() { $0
  .backgroundColor(.red)
}
```

Prefer:

```swift
let view = UIView() { $0
  .backgroundColor(.red)
}
```

Or:

```swift
let view: UIView = .init().configured(using: .backgroundColor(.red))
```
