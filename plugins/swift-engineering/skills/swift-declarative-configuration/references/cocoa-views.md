# Cocoa Views

Use this reference whenever `DeclarativeConfiguration` is being applied to UIKit, AppKit, `CALayer`, or other Cocoa objects.

## Installation

```swift
.package(
	url: "https://github.com/capturecontext/swift-declarative-configuration",
	.upToNextMinor(from: "0.6.0")
)
```

Import:

```swift
import DeclarativeConfiguration
```

## Core Preference

`Configurator` is the primary API.

Prefer these shapes:

```swift
let imageView = UIImageView() { $0
	.image(image)
	.contentMode(.scaleAspectFill)
	.clipsToBounds(true)
}
```

```swift
let cardView = UIView().configured(using: .borderedRounded(radius: 16))
```

Use `Builder` mainly when the file already uses `.builder`, when the object already exists and instance-bound chaining is clearer, or when `.commit()` / `.apply()` semantics are specifically useful.

## Extraction Boundary

Do not use `DeclarativeConfiguration` as a substitute for domain-specific Cocoa view types.

Prefer reusable `Configurator`s for:

- generic visual treatment
- nested `CALayer` setup
- typography helpers
- common control defaults
- cross-screen technical consistency

Prefer dedicated view types for:

- product/domain concepts like cards, banners, pills, hero blocks, paywalls, or feature-specific panels
- views whose identity is defined by composition, layout, behavior, or domain semantics rather than a small set of generic property updates

Label styles are the main acceptable domain-shaped exception, because text styling often benefits from reuse without forcing a new view type.

## Inline Configuration

Use inline configuration for local setup near the call site.

```swift
let button = UIButton(type: .system) { $0
	.tintColor(.white)
	.backgroundColor(.systemBlue)
	.contentEdgeInsets(.init(top: 10, left: 16, bottom: 10, right: 16))
}
```

For methods that do not map cleanly to property-style configuration, use `peek`, `modify`, or `transform`.

```swift
let button = UIButton(type: .system) { $0
	.peek { $0.setTitle("Continue", for: .normal) }
}
```

## Reusable Configurators

Extract repeated styling into `Configurator` extensions.

```swift
extension Configurator where Base: UILabel {
	@MainActor
	static var title: Self {
		.init { $0
			.font(.preferredFont(forTextStyle: .title2))
			.textColor(.label)
			.numberOfLines(0)
		}
	}

	@MainActor
	static func emphasized(color: UIColor = .systemBlue) -> Self {
		.title.textColor(color)
	}
}
```

Prefer:

```swift
let label = UILabel().configured(using: .title.text("Hello"))
```

Or:

```swift
let label = UILabel() { $0
	.combined(with: .title)
	.text("Hello")
}
```

## Composition

Use `combined(with:)` when building larger styles from smaller ones.

```swift
extension Configurator where Base: UIView {
	@MainActor
	static var bordered: Self {
		.init { $0
			.layer.scope { $0
				.borderWidth(1)
				.borderColor(.separator)
			}
		}
	}

	@MainActor
	static func rounded(radius: CGFloat = 16) -> Self {
		.empty.layer.scope { $0
			.cornerRadius(radius)
			.cornerCurve(.continuous)
		}
	}

	@MainActor
	static func borderedRounded(radius: CGFloat = 16) -> Self {
		.bordered.combined(with: .rounded(radius: radius))
	}
}
```

## Scoped Configuration

Use `scope` for nested Cocoa objects instead of imperative access.

```swift
extension Configurator where Base: UIView {
	@MainActor
	static func rounded(
		radius: CGFloat,
		curve: UICornerCurve = .continuous
	) -> Self {
		.empty.layer.scope { $0
			.cornerRadius(radius)
			.cornerCurve(curve)
		}
	}
}
```

This pattern is especially useful for:

- `view.layer`
- `button.configuration`
- `cell.backgroundConfiguration`
- `stackView.layoutMargins`
- `textField.defaultTextAttributes`
- nested custom configuration structs/classes

This pattern is not a reason by itself to extract a domain-specific view style. If the extracted helper starts reading like a product component name, reconsider whether that should be a dedicated view type instead.

## Optional Configuration

### Conditional values

```swift
let label = UILabel() { $0
	.text(ifLet: title)
	.attributedText(ifLet: attributedTitle)
}
```

### Optional nested property

```swift
let button = UIButton(type: .system) { $0
	.configuration.ifLet.scope { $0
		.title(ifLet: title)
		.subtitle(ifLet: subtitle)
	}
}
```

### Optional property via key path helper

```swift
let view = SomeView() { $0
	.ifLet(\.optionalBadgeView).scope { $0
		.isHidden(false)
		.alpha(1)
	}
}
```

### Defaulting while continuing configuration

```swift
let model = SomeCustomType() { $0
	.optionalValue.ifLet(else: 0).modify { $0 += 1 }
}
```

### Write only when current value is nil

```swift
let model = SomeCustomType() { $0
	.optionalValue.ifNil(42)
}
```

## CALayer Extraction Pattern

Prefer extracting reusable nested configuration rather than duplicating `layer.scope` chains.

```swift
extension Configurator where Base: UIView {
	@MainActor
	static func cornerRadius(
		_ radius: CGFloat,
		curve: UICornerCurve = .continuous
	) -> Self {
		.init { $0
			.layer.combined(with: .cornerRadius(radius, curve: curve))
		}
	}
}

extension Configurator where Base: CALayer {
	@MainActor
	static func cornerRadius(
		_ radius: CGFloat,
		curve: UICornerCurve = .continuous
	) -> Self {
		.init { $0
			.cornerRadius(radius)
			.cornerCurve(curve)
		}
	}
}
```

Use the nested `CALayer` configurator when multiple Cocoa views share the same layer style.

## Builder Awareness

Recognize these valid shapes:

```swift
let label = UILabel().builder
	.text("Hello")
	.textAlignment(.center)
	.build()
```

```swift
let builder = Builder(
	initialValue: { UILabel() },
	configuration: .title
)
```

When editing existing `Builder` code:

1. Preserve it if the file already uses the pattern consistently.
2. Use the same `scope`, `ifLet`, `ifNil`, `modify`, and `transform` concepts.
3. Do not convert everything to `Builder` in new code just because the package supports it.

## Custom Type Support

For non-`NSObject` types:

```swift
extension CustomType: DefaultConfigurableProtocol {}
```

For `.builder` support:

```swift
extension CustomType: BuilderProvider {}
```

## Known Swift Inference Issue

Avoid:

```swift
let value: SomeView = .init() { $0
	.alpha(0.5)
}
```

Prefer:

```swift
let value = SomeView() { $0
	.alpha(0.5)
}
```

Or:

```swift
let value: SomeView = .init().configured(using: .alpha(0.5))
```
