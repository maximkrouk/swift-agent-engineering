---
name: swift-cocoa-extensions
description: >-
  Use when working with CocoaExtensions from https://github.com/capturecontext/swift-cocoa-extensions, especially for Cocoa convenience APIs that layer on top of CocoaAliases, DeclarativeConfiguration, and FoundationExtensions, or when macros / helpers from this package are already part of the codebase.
---

# Swift Cocoa Extensions

Use this package when the codebase already depends on `CocoaExtensions` as the umbrella layer for Cocoa utilities.

## Defaults

1. Treat this package as a façade over other CaptureContext Cocoa packages.
2. Reference the narrower package skill when the need is primarily aliases, declarative configuration, or foundation helpers.
3. Prefer the existing CocoaExtensions APIs in repos that already standardized on this package.
4. Do not invent usage patterns that are better served directly by `cocoa-aliases` or `swift-declarative-configuration`.

## Reexport / Dependency Awareness

This package depends on and conceptually layers over:

- `cocoa-aliases`
- `swift-declarative-configuration`
- `swift-foundation-extensions`

When a task is mainly about shared Cocoa type aliases or declarative view configuration, also use those specialized skills.

## Workflow

1. Check whether the codebase imports `CocoaExtensions` as its main Cocoa utility surface.
2. If yes, preserve that idiom instead of rewriting imports toward narrower leaf packages.
3. If the task is specifically about cross-platform Cocoa types, load the `cocoa-aliases` mental model.
4. If the task is specifically about inline view/property configuration, load the `swift-declarative-configuration` mental model.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Cocoa Layering](references/cocoa-layering.md)** | Any use of `CocoaExtensions`, its macros target, or projects using it as the umbrella Cocoa utility package |

## Common Mistakes

1. Treating `CocoaExtensions` as a single-purpose package.
2. Replacing existing CocoaExtensions-based code with narrower packages unnecessarily.
3. Forgetting that many patterns here are inherited from `CocoaAliases`, `DeclarativeConfiguration`, and `FoundationExtensions`.
