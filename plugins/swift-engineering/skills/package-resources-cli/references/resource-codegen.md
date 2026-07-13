# Resource Codegen

`package-resources-cli` is the codegen and plugin companion to `swift-package-resources`.

## Installation

```swift
.package(
  url: "https://github.com/capturecontext/package-resources-cli.git",
  .upToNextMajor(from: "2.0.0")
),
.package(
  url: "https://github.com/capturecontext/swift-package-resources.git",
  .upToNextMajor(from: "4.0.0")
)
```

## Plugin Setup

```swift
.target(
  name: "AppUI",
  dependencies: [
    .product(
      name: "PackageResources",
      package: "swift-package-resources"
    )
  ],
  resources: [...],
  plugins: [
    .plugin(
      name: "package-resources-plugin",
      package: "package-resources-cli"
    )
  ]
)
```

Alias alternative:

```swift
.product(
  name: "_ExportedPackageResources",
  package: "package-resources-cli"
)
```

## Configuration File

Package root: `.packageresources`

Main concerns:

- output path
- indentation
- number tokenization
- acronym handling

## Commands

- `swift package resources generate`
- `swift package resources config init`
- `swift package resources config edit`

## Resource Types

- colors
- fonts
- images
- storyboards
- scene assets

Fonts need additional runtime registration/setup.

