#!/usr/bin/env bash
# Installs the generated Codex AGENTS.md into a target repository.

set -euo pipefail

RULES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$PWD}"

python3 "$RULES_ROOT/scripts/build-codex-agents.py"
python3 "$RULES_ROOT/scripts/install-codex-rules.py" "$RULES_ROOT" "$TARGET_DIR"

echo "Installed Codex rules into $TARGET_DIR"
