#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_PLUGIN_FILE="$SCRIPT_DIR/../.claude-plugin/plugin.json"
CODEX_PLUGIN_FILE="$SCRIPT_DIR/../.codex-plugin/plugin.json"
MARKETPLACE_FILE="$SCRIPT_DIR/../../../.claude-plugin/marketplace.json"
PLUGIN_README="$SCRIPT_DIR/../README.md"

if [ ! -f "$CLAUDE_PLUGIN_FILE" ] && [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
  CLAUDE_PLUGIN_FILE="$CLAUDE_PROJECT_DIR/plugins/swift-engineering/.claude-plugin/plugin.json"
  CODEX_PLUGIN_FILE="$CLAUDE_PROJECT_DIR/plugins/swift-engineering/.codex-plugin/plugin.json"
  MARKETPLACE_FILE="$CLAUDE_PROJECT_DIR/.claude-plugin/marketplace.json"
  PLUGIN_README="$CLAUDE_PROJECT_DIR/plugins/swift-engineering/README.md"
fi

BUMP_TYPE=${1:-patch}  # patch, minor, major

CURRENT_VERSION=$(jq -r '.version' "$CLAUDE_PLUGIN_FILE")

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

update_manifest_version() {
  local file_path="$1"

  if [ ! -f "$file_path" ]; then
    return
  fi

  jq --arg version "$NEW_VERSION" '.version = $version' "$file_path" > "$file_path.tmp"
  mv "$file_path.tmp" "$file_path"
}

update_marketplace_version() {
  local file_path="$1"

  if [ ! -f "$file_path" ]; then
    return
  fi

  jq --arg version "$NEW_VERSION" '(.plugins[] | select(.name == "swift-engineering") | .version) = $version' "$file_path" > "$file_path.tmp"
  mv "$file_path.tmp" "$file_path"
}

update_manifest_version "$CLAUDE_PLUGIN_FILE"
update_manifest_version "$CODEX_PLUGIN_FILE"
update_marketplace_version "$MARKETPLACE_FILE"

if [ -f "$PLUGIN_README" ]; then
  sed -i.bak -E "s/\*\*Version:\*\* [0-9]+\.[0-9]+\.[0-9]+/**Version:** ${NEW_VERSION}/g" "$PLUGIN_README"
  rm -f "$PLUGIN_README.bak"
  echo "Updated plugin README to version $NEW_VERSION"
fi

echo "Updated manifest versions:"
echo "- $CLAUDE_PLUGIN_FILE"

if [ -f "$CODEX_PLUGIN_FILE" ]; then
  echo "- $CODEX_PLUGIN_FILE"
fi

if [ -f "$MARKETPLACE_FILE" ]; then
  echo "- $MARKETPLACE_FILE"
fi

echo "Bumped version from $CURRENT_VERSION to $NEW_VERSION"
exit 0
