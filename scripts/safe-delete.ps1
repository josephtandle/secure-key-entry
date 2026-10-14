# Safe delete (Windows): send files or folders to the Recycle Bin instead of
# deleting them permanently. Usage: safe-delete.ps1 <path> [path...]
$ErrorActionPreference = "Continue"
if ($args.Count -eq 0) { Write-Output "Usage: safe-delete.ps1 <path> [path...]"; exit 2 }
Add-Type -AssemblyName Microsoft.VisualBasic
$status = 0
foreach ($p in $args) {
  if (-not (Test-Path -LiteralPath $p)) { Write-Output "Not found: $p"; $status = 1; continue }
  $full = (Resolve-Path -LiteralPath $p).Path
  try {
    if (Test-Path -LiteralPath $full -PathType Container) {
      [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($full, 'OnlyErrorDialogs', 'SendToRecycleBin')
    } else {
      [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($full, 'OnlyErrorDialogs', 'SendToRecycleBin')
    }
    Write-Output "Moved to Recycle Bin: $p"
  } catch {
    Write-Output "Could not reach the Recycle Bin for: $p (nothing was deleted)"; $status = 1
  }
}
exit $status
