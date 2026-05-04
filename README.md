# swift-agent-engineering [WIP]

[![License](https://img.shields.io/badge/license-MIT-green)](#) [![Platform](https://img.shields.io/badge/platform-iOS%2026%2B%20%7C%20macOS-blue)](#)

> Swift engineering plugin repository for Claude and Codex

This repository packages `swift-engineering`, a modern Swift/SwiftUI toolkit for planning, implementing, testing, documenting, and reviewing iOS and macOS features.

The repo is being prepared for marketplace publication. Shared Swift skills and metadata are packaged for both Claude and Codex, while Claude-specific commands, hooks, and config remain explicitly scoped to Claude workflows.

## Swift Engineering Plugin

The `swift-engineering` plugin provides:

- **12 specialized agents** for planning, implementation, testing, documentation, and review
- **18 comprehensive skills** covering architecture, Apple frameworks, design guidance, and tooling
- **Modern Swift workflows** for Swift 6.2, strict concurrency, SwiftUI, and TCA
- **Shared repository metadata** for Claude and Codex packaging

Detailed plugin usage and the current Claude-specific workflow documentation live in [plugins/swift-engineering/README.md](plugins/swift-engineering/README.md).

## Packaging

This repository currently includes these distribution artifacts:

- **Claude marketplace catalog:** `.claude-plugin/marketplace.json`
- **Codex marketplace catalog:** `.agents/plugins/marketplace.json`
- **Claude plugin manifest:** `plugins/swift-engineering/.claude-plugin/plugin.json`
- **Codex plugin manifest:** `plugins/swift-engineering/.codex-plugin/plugin.json`

Claude-specific operational assets remain under:

- `plugins/swift-engineering/claude/`
- `plugins/swift-engineering/commands/`
- `plugins/swift-engineering/hooks-scripts/`

## Repository Structure

```text
swift-agent-engineering/
├── .agents/
│   └── plugins/
│       └── marketplace.json             # Codex marketplace configuration
├── .claude-plugin/
│   └── marketplace.json                 # Claude marketplace configuration
├── plugins/
│   └── swift-engineering/
│       ├── .claude-plugin/
│       │   └── plugin.json              # Claude plugin manifest
│       ├── .codex-plugin/
│       │   └── plugin.json              # Codex plugin manifest
│       ├── agents/                      # Claude-oriented agent specs
│       ├── commands/                    # Claude-oriented command docs
│       ├── hooks-scripts/               # Claude hook scripts
│       ├── skills/                      # Shared Swift skills
│       ├── scripts/                     # Helper utilities
│       ├── rules/                       # Shared development rules
│       └── README.md                    # Plugin documentation
└── worktrees/                           # Git worktrees for features
```

## Contributor Notes

### Versioning

Use the helper script to bump the plugin version:

```bash
bash plugins/swift-engineering/scripts/bump-plugin-version.sh <patch|minor|major>
```

The script keeps the Claude manifest, Codex manifest, Claude marketplace version entry, and plugin README version line in sync.

### Adding Or Updating Plugin Assets

1. Keep shared skills and metadata platform-neutral where possible.
2. Keep Claude-only runtime assets clearly labeled and isolated to Claude-specific paths.
3. Update both READMEs when changing published-facing behavior or packaging.
4. Validate manifest and marketplace JSON after metadata changes.

## Credits

- **Publisher:** CaptureContext
- **Author:** Maxim Krouk (@maximkrouk)
- **Repository:** [capturecontext/swift-agent-engineering](https://github.com/capturecontext/swift-agent-engineering)
- **Swift Version:** 6.2+
- **iOS Deployment Target:** 26.0+
