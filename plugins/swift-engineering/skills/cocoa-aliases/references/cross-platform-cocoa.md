# Cross-Platform Cocoa

`CocoaAliases` maps Cocoa-prefixed names onto UIKit or AppKit types depending on platform.

## Installation

```swift
.package(
  url: "https://github.com/capturecontext/cocoa-aliases.git",
  .upToNextMinor(from: "3.3.0")
)
```

Target dependency:

```swift
.product(
  name: "CocoaAliases",
  package: "cocoa-aliases"
)
```

Import:

```swift
import CocoaAliases
```

## Guidance

Use aliases like `CocoaView` when the shared implementation is truly the same.

Keep `#if os(...)` where:

- platform APIs diverge
- lifecycle behavior differs
- availability is different
- UIKit/AppKit equivalents are not 1:1

The package also exports Cocoa-prefixed marker protocols from the marker-protocol dependency.

