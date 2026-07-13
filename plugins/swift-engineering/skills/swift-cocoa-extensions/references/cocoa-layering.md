# Cocoa Layering

`CocoaExtensions` is an umbrella package for Cocoa-focused helpers.

## Installation

```swift
.package(
  url: "https://github.com/capturecontext/swift-cocoa-extensions.git",
  .upToNextMinor(from: "0.5.0")
)
```

## Dependency Layer

It builds on:

- `CocoaAliases`
- `DeclarativeConfiguration`
- `FoundationExtensions`
- `IdentifiedCollections`

Macros target:

- `CocoaExtensionsMacros`

## Usage Guidance

- Keep `import CocoaExtensions` in codebases already standardized on it.
- When editing code, preserve the umbrella-package style unless there is a concrete reason to split imports.
- For details on aliases and declarative configuration, follow the semantics of those packages.

