<#
Secure key entry (Windows). Pops up a masked dialog so an API key or password
goes straight into a .env file or your Windows user environment variables.
The value is never printed and never in the AI chat.

Usage:
  powershell -ExecutionPolicy Bypass -File secure-key-entry.ps1 -Var OPENAI_API_KEY [-EnvFile .env] [-Prompt "Paste your OpenAI key"] [-Prefix sk-]
  powershell -ExecutionPolicy Bypass -File secure-key-entry.ps1 -Var OPENAI_API_KEY -UserEnv

  -Var      Variable name to save
  -EnvFile  Env file path (default .\.env). Backed up before changes and added to
            .gitignore when it sits inside a Git repository.
  -UserEnv  Save as a Windows user environment variable instead of a file
  -Prefix   Comma list of expected key prefixes; anything else is refused
#>
param(
  [Parameter(Mandatory = $true)][string]$Var,
  [string]$EnvFile = ".env",
  [switch]$UserEnv,
  [string]$Prefix = "",
  [string]$Prompt = ""
)
$ErrorActionPreference = "Stop"
if ($Var -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') { Write-Output "Invalid variable name: $Var"; exit 2 }
if (-not $Prompt) { $Prompt = "Paste $Var here. It is saved privately and never shown in the chat." }

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = "Secure key entry"; $form.Width = 460; $form.Height = 180
$form.StartPosition = "CenterScreen"; $form.TopMost = $true; $form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false; $form.MinimizeBox = $false
$label = New-Object System.Windows.Forms.Label
$label.Text = $Prompt; $label.Left = 12; $label.Top = 12; $label.Width = 420; $label.Height = 36
$box = New-Object System.Windows.Forms.TextBox
$box.Left = 12; $box.Top = 52; $box.Width = 420; $box.UseSystemPasswordChar = $true
$ok = New-Object System.Windows.Forms.Button
$ok.Text = "Save"; $ok.Left = 276; $ok.Top = 90; $ok.DialogResult = [System.Windows.Forms.DialogResult]::OK
$cancel = New-Object System.Windows.Forms.Button
$cancel.Text = "Cancel"; $cancel.Left = 357; $cancel.Top = 90; $cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.Controls.AddRange(@($label, $box, $ok, $cancel)); $form.AcceptButton = $ok; $form.CancelButton = $cancel
$form.Add_Shown({ $form.Activate(); $box.Focus() })
$result = $form.ShowDialog()
$k = $box.Text.Trim()
$box.Text = ""; $form.Dispose()
if ($result -ne [System.Windows.Forms.DialogResult]::OK) { Write-Output "Cancelled. Nothing saved."; exit 1 }
if (-not $k) { Write-Output "Empty. Nothing saved."; exit 1 }

if ($Prefix) {
  $match = $false
  foreach ($p in $Prefix.Split(",")) { if ($k.StartsWith($p.Trim())) { $match = $true } }
  if (-not $match) { $k = $null; Write-Output "That does not look like the right key (expected it to start with $Prefix). Nothing saved."; exit 1 }
}
$hint = "$($k.Length) characters, ending ...$($k.Substring([Math]::Max(0, $k.Length - 4)))"

if ($UserEnv) {
  [Environment]::SetEnvironmentVariable($Var, $k, "User")
  $k = $null
  Write-Output "Saved $Var as a Windows user environment variable ($hint). Open a new terminal or restart the app to use it."
  exit 0
}

$full = [System.IO.Path]::GetFullPath($EnvFile)
$dir = Split-Path $full -Parent
if (-not (Test-Path $dir)) { $k = $null; Write-Output "Folder for $EnvFile does not exist."; exit 1 }
if (Test-Path $full) {
  $bk = Join-Path $dir ".env-backups"
  New-Item -ItemType Directory -Force -Path $bk | Out-Null
  Copy-Item $full (Join-Path $bk ("{0}.{1}" -f (Split-Path $full -Leaf), (Get-Date -Format "yyyyMMdd-HHmmss")))
  $lines = @(Get-Content $full | Where-Object { $_ -notmatch "^$([regex]::Escape($Var))=" })
} else { $lines = @() }
$lines += "$Var=$k"
[System.IO.File]::WriteAllLines($full, [string[]]$lines)
$k = $null
try {
  $acl = Get-Acl $full; $acl.SetAccessRuleProtection($true, $false)
  $acl.Access | ForEach-Object { [void]$acl.RemoveAccessRule($_) }
  $acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "FullControl", "Allow")))
  Set-Acl $full $acl
} catch { }

$ErrorActionPreference = "Continue"
$root = $null
if (Get-Command git -ErrorAction SilentlyContinue) {
  $root = (& git -C $dir rev-parse --show-toplevel 2>$null)
  if ($LASTEXITCODE -ne 0) { $root = $null }
}
if ($root) {
  $rootFull = [System.IO.Path]::GetFullPath($root).TrimEnd('\', '/')
  foreach ($p in @($full, (Join-Path $dir ".env-backups\x"))) {
    & git -C $rootFull check-ignore -q $p 2>$null
    if ($LASTEXITCODE -ne 0 -and $p.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
      # Works on Windows PowerShell 5.1, which has no Path.GetRelativePath.
      $rel = $p.Substring($rootFull.Length).TrimStart('\', '/').Replace("\", "/")
      if ($rel.EndsWith("/x")) { $rel = $rel.Substring(0, $rel.Length - 1) }
      Add-Content -Path (Join-Path $rootFull ".gitignore") -Value $rel
      Write-Output "Added $rel to .gitignore so it is never committed."
    }
  }
}
Write-Output "Saved $Var to $full ($hint)."
