# Install the safety skills (secure-key-entry, save-points, undo, safe-delete) for
# Claude Code and Codex (Windows). Safe to re-run: it updates the installed copies.
$ErrorActionPreference = "Stop"
$src = Split-Path -Parent $PSScriptRoot
foreach ($base in @("$HOME\.claude\skills", "$HOME\.agents\skills")) {
  foreach ($skill in Get-ChildItem -Directory "$src\skills") {
    $dest = Join-Path $base $skill.Name
    New-Item -ItemType Directory -Force -Path "$dest\scripts" | Out-Null
    Copy-Item (Join-Path $skill.FullName "SKILL.md") "$dest\SKILL.md" -Force
    Copy-Item "$src\scripts\secure-key-entry.*", "$src\scripts\safe-delete.*" "$dest\scripts\" -Force
    Write-Output "Installed: $dest"
  }
}
Write-Output "Done. Start a new Claude Code or Codex session to load: secure-key-entry, save-points, undo, safe-delete."
