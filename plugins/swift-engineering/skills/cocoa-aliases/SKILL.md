---
name: cocoa-aliases
description: >-
  Use when writing shared AppKit/UIKit code with CocoaAliases from https://github.com/capturecontext/cocoa-aliases, especially for replacing platform-specific UI type names with Cocoa-prefixed aliases, reducing #if os(macOS) branching, or working with the package's exported Cocoa marker protocols.
---

# Cocoa Aliases

Use this package when shared Apple-platform UI code should talk in Cocoa-prefixed aliases instead of splitting on `NS*` versus `UI*` types.

## Defaults

1. Prefer `Cocoa*` aliases in codebases that already standardized on this package.
2. Use it to reduce platform-branching boilerplate, not to pretend AppKit and UIKit are perfectly identical.
3. Keep platform checks when API behavior or availability truly differs.
4. Remember that the package also exports Cocoa-prefixed marker protocols.

## Preferred Shape

```swift
import CocoaAliases

extension CocoaView {
	func rounded() {
		self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2
	}
}
```

## Workflow

1. Check whether the file is shared across AppKit/UIKit platforms.
2. If the logic is structurally the same, replace duplicated `NS*` / `UI*` branches with `Cocoa*` aliases.
3. If platform behavior still differs, keep conditional compilation around only the differing parts.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Cross-Platform Cocoa](references/cross-platform-cocoa.md)** | Any shared AppKit/UIKit code using Cocoa aliases or exported marker protocols |

## Common Mistakes

1. Assuming aliases eliminate all platform differences.
2. Keeping large duplicated `#if os(...)` blocks when only the type names differ.
3. Using aliases in code that is not actually shared or cross-platform.
