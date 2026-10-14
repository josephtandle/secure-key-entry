#!/usr/bin/env bash
# Install the secure-key-entry skill for Claude Code and Codex (macOS / Linux / Git Bash).
# Safe to re-run: it updates the installed copy to this version.
set -euo pipefail
SRC="$(cd "$(dirname "$0")/.." && pwd)"
for dest in "$HOME/.claude/skills/secure-key-entry" "$HOME/.agents/skills/secure-key-entry"; do
  mkdir -p "$dest/scripts"
  cp "$SRC/skills/secure-key-entry/SKILL.md" "$dest/SKILL.md"
  cp "$SRC/scripts/secure-key-entry.sh" "$SRC/scripts/secure-key-entry.ps1" "$dest/scripts/"
  chmod +x "$dest/scripts/secure-key-entry.sh"
  echo "Installed: $dest"
done
echo "Done. Start a new Claude Code or Codex session so it picks up the secure-key-entry skill."
