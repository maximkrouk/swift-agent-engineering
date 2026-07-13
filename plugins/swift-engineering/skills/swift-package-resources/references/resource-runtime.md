# Resource Runtime

`swift-package-resources` provides typed resource models and a runtime API.

## Installation

```swift
.package(
  url: "https://github.com/capturecontext/swift-package-resources.git",
  .upToNextMinor(from: "4.0.2")
)
```

## Products

### PackageResources

Higher-level runtime API for resources such as:

- `Color.resource(...)`
- `UIColor.resource(...)`
- `NSColor.resource(...)`
- `Image.resource(...)`
- `UIImage.resource(...)`
- `NSImage.resource(...)`
- `Font.resource(...)`
- `UIFont.resource(...)`
- `NSFont.resource(...)`

### PackageResourcesCore

Core model declarations only.

Representative aliases:

- `PackageResources.Color`
- `PackageResources.Font`
- `PackageResources.Image`
- `PackageResources.Storyboard`
- `PackageResources.SCNScene`

## Guidance

- Use this package alongside generated accessors.
- For generation/plugin concerns, also load the `package-resources-cli` mental model.
- Keep generated accessors target-local; keep runtime models shared when useful across targets.

