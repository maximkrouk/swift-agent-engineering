---
name: swift-package-resources
description: >-
  Use when working with PackageResources or PackageResourcesCore from https://github.com/capturecontext/swift-package-resources, especially for generated resource model access, typed asset wrappers, runtime resource loading APIs, or projects that pair the package with package-resources-cli code generation.
---

# Swift Package Resources

Use this package for the typed runtime API behind generated SwiftPM resource accessors.

## Defaults

1. This package is meant to be used with code generation.
2. The default generator in this ecosystem is `package-resources-cli`.
3. Use `PackageResources` for the higher-level runtime access API.
4. Use `PackageResourcesCore` when only resource models are needed and the higher-level helpers are redundant.

## Workflow

1. Check whether the project only needs resource models or also wants ready-made runtime loaders.
2. If the package already uses generated accessors, keep generated code separate from the runtime models.
3. If the project needs generation/setup help, also use the `package-resources-cli` skill.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Resource Runtime](references/resource-runtime.md)** | Any use of `PackageResources`, `PackageResourcesCore`, typed resources, or runtime loading APIs |

## Common Mistakes

1. Treating this package as the code generator.
2. Reimplementing resource models that already exist in `PackageResourcesCore`.
3. Using `PackageResources` helpers when only the core models are needed.
