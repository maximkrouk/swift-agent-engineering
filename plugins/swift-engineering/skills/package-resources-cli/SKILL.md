---
name: package-resources-cli
description: >-
  Use when configuring or generating resource accessors with package-resources-cli from https://github.com/capturecontext/package-resources-cli, especially for SwiftPM build plugins, .packageresources configuration files, generated resource accessors, package resource command/plugin usage, or when the package reexports swift-package-resources products for import convenience.
---

# Package Resources CLI

Use this package when the project generates strongly typed resource accessors for SwiftPM resources using the CaptureContext codegen flow.

## Defaults

1. This package is primarily a code generator and plugin layer.
2. It is designed to work with `swift-package-resources`.
3. Prefer the build plugin for normal package integration.
4. Use the command plugin or executable when manually managing config or generated output.
5. Remember that `_ExportedPackageResources` and `_ExportedPackageResourcesCore` are convenience reexports over `swift-package-resources`.

## Workflow

1. Check whether the package uses the build tool plugin, command plugin, or manual CLI execution.
2. If generating accessors for a target, ensure the target has resources plus the `package-resources-plugin`.
3. If editing configuration, work with the `.packageresources` file at the package root.
4. If the code only needs the runtime resource model API, also follow the `swift-package-resources` skill.

## Reference Loading Guide

Always load the reference when this skill triggers:

| Reference | Load When |
|-----------|-----------|
| **[Resource Codegen](references/resource-codegen.md)** | Any use of `.packageresources`, build plugins, generated accessors, exported aliases, or manual CLI commands |

## Common Mistakes

1. Treating this package as the runtime API instead of the generator/plugin layer.
2. Forgetting to add the plugin to the target with resources.
3. Manually maintaining generated accessors that should come from the plugin.
4. Ignoring the exported alias products when a project wants `import PackageResources` without adding the runtime package separately.
