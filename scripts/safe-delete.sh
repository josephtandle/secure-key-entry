#!/usr/bin/env bash
# Safe delete: move files or folders to the Trash (macOS) or Recycle Bin (Windows)
# instead of deleting them permanently. Usage: safe-delete.sh <path> [path...]
set -u
[ $# -gt 0 ] || { echo "Usage: safe-delete.sh <path> [path...]"; exit 2; }
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*)
    PS1="$(cd "$(dirname "$0")" && pwd -W 2>/dev/null || pwd)/safe-delete.ps1"
    exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS1" "$@";;
esac
status=0
for p in "$@"; do
  if [ ! -e "$p" ] && [ ! -L "$p" ]; then echo "Not found: $p"; status=1; continue; fi
  abs="$(cd "$(dirname "$p")" && pwd -P)/$(basename "$p")"
  if [ -x /usr/bin/trash ]; then
    /usr/bin/trash "$abs" >/dev/null 2>&1 && { echo "Moved to Trash: $p"; continue; }
  fi
  if command -v osascript >/dev/null; then
    esc=${abs//\\/\\\\}; esc=${esc//\"/\\\"}
    osascript -e "tell application \"Finder\" to delete (POSIX file \"$esc\" as alias)" >/dev/null 2>&1 \
      && { echo "Moved to Trash: $p"; continue; }
  fi
  if command -v gio >/dev/null && gio trash "$abs" 2>/dev/null; then echo "Moved to Trash: $p"; continue; fi
  echo "Could not reach the Trash for: $p (nothing was deleted)"; status=1
done
exit $status
