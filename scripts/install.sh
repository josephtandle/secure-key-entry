#!/usr/bin/env bash
# Install the safety skills (secure-key-entry, save-points, undo, safe-delete) for
# Claude Code and Codex (macOS / Linux / Git Bash). Safe to re-run: it updates the
# installed copies to this version.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
for base in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  for skill in "$SRC"/skills/*/; do
    name="$(basename "$skill")"; dest="$base/$name"
    mkdir -p "$dest/scripts"
    cp "$skill/SKILL.md" "$dest/SKILL.md"
    cp "$SRC"/scripts/secure-key-entry.* "$SRC"/scripts/safe-delete.* "$dest/scripts/"
    chmod +x "$dest"/scripts/*.sh
    echo "Installed: $dest"
  done
done
echo "Done. Start a new Claude Code or Codex session to load: secure-key-entry, save-points, undo, safe-delete."
