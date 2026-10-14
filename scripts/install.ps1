# Install the secure-key-entry skill for Claude Code and Codex (Windows).
# Safe to re-run: it updates the installed copy to this version.
$ErrorActionPreference = "Stop"
$src = Split-Path -Parent $PSScriptRoot
foreach ($dest in @("$HOME\.claude\skills\secure-key-entry", "$HOME\.agents\skills\secure-key-entry")) {
  New-Item -ItemType Directory -Force -Path "$dest\scripts" | Out-Null
  Copy-Item "$src\skills\secure-key-entry\SKILL.md" "$dest\SKILL.md" -Force
  Copy-Item "$src\scripts\secure-key-entry.sh", "$src\scripts\secure-key-entry.ps1" "$dest\scripts\" -Force
  Write-Output "Installed: $dest"
}
Write-Output "Done. Start a new Claude Code or Codex session so it picks up the secure-key-entry skill."
