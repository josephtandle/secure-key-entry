#!/usr/bin/env bash
# Secure key entry (macOS). Pops up a hidden-answer dialog so an API key or
# password goes straight into a .env file or the macOS Keychain. The value is
# never printed, never in shell history, and never in the AI chat.
#
# Usage:
#   secure-key-entry.sh --var OPENAI_API_KEY [--env-file .env] [--prompt "Paste your OpenAI key"] [--prefix sk-]
#   secure-key-entry.sh --keychain my-service [--account me] [--prompt "..."]
#
#   --var       Variable name to write into the env file (default file: ./.env)
#   --env-file  Env file path (created if missing, backed up before changes, chmod 600,
#               and added to .gitignore when it sits inside a Git repository)
#   --keychain  Save to the macOS Keychain under this service name instead of a file
#   --prefix    Comma list of expected key prefixes; anything else is refused
#
# Read a Keychain value back without printing it:
#   security find-generic-password -a <account> -s <service> -w
set -u
# Windows (Git Bash, MSYS, Cygwin): hand off to the PowerShell version, same options.
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*)
    PS1="$(cd "$(dirname "$0")" && pwd -W 2>/dev/null || pwd)/secure-key-entry.ps1"
    args=(); while [ $# -gt 0 ]; do
      case "$1" in
        --var) args+=(-Var "$2"); shift 2;; --env-file) args+=(-EnvFile "$2"); shift 2;;
        --prefix) args+=(-Prefix "$2"); shift 2;; --prompt) args+=(-Prompt "$2"); shift 2;;
        --user-env|--keychain) args+=(-UserEnv); [ "$1" = "--keychain" ] && shift; shift;;
        *) args+=("$1"); shift;;
      esac
    done
    exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$PS1" "${args[@]}";;
esac
command -v osascript >/dev/null || { echo "This pop-up needs macOS or Windows. On other systems, add NAME=value to .env yourself in a text editor."; exit 1; }
VAR="" ENVFILE=".env" SERVICE="" ACCOUNT="${USER:-me}" PREFIX="" PROMPT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --var) VAR="$2"; shift 2;; --env-file) ENVFILE="$2"; shift 2;;
    --keychain) SERVICE="$2"; shift 2;; --account) ACCOUNT="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;; --prompt) PROMPT="$2"; shift 2;;
    -h|--help) sed -n '2,19p' "$0"; exit 0;;
    *) echo "Unknown option: $1"; exit 2;;
  esac
done
[ -n "$VAR" ] || [ -n "$SERVICE" ] || { echo "Need --var NAME (env file) or --keychain SERVICE."; exit 2; }
if [ -n "$VAR" ] && ! [[ "$VAR" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then echo "Invalid variable name: $VAR"; exit 2; fi
[ -n "$PROMPT" ] || PROMPT="Paste ${VAR:-$SERVICE} here. It is saved privately and never shown in the chat."
PROMPT_ESC=${PROMPT//\\/\\\\}; PROMPT_ESC=${PROMPT_ESC//\"/\\\"}

K=$(osascript -e "text returned of (display dialog \"$PROMPT_ESC\" default answer \"\" with hidden answer with title \"Secure key entry\" with icon caution buttons {\"Cancel\",\"Save\"} default button \"Save\")" 2>/dev/null) \
  || { echo "Cancelled. Nothing saved."; exit 1; }
K="${K#"${K%%[![:space:]]*}"}"; K="${K%"${K##*[![:space:]]}"}"   # trim stray spaces/newlines
[ -n "$K" ] || { echo "Empty. Nothing saved."; exit 1; }

if [ -n "$PREFIX" ]; then
  ok=0; IFS=',' read -ra P <<< "$PREFIX"; for p in "${P[@]}"; do [[ "$K" == "$p"* ]] && ok=1; done
  [ $ok = 1 ] || { unset K; echo "That does not look like the right key (expected it to start with $PREFIX). Nothing saved."; exit 1; }
fi
HINT="${#K} characters, ending ...${K: -4}"

if [ -n "$SERVICE" ]; then
  security add-generic-password -U -a "$ACCOUNT" -s "$SERVICE" -w "$K" >/dev/null \
    && echo "Saved to the macOS Keychain as '$SERVICE' ($HINT)." \
    || { unset K; echo "Keychain save failed. Nothing saved."; exit 1; }
  unset K; exit 0
fi

DIR=$(cd "$(dirname "$ENVFILE")" 2>/dev/null && pwd -P) || { unset K; echo "Folder for $ENVFILE does not exist."; exit 1; }
FILE="$DIR/$(basename "$ENVFILE")"
if [ -f "$FILE" ]; then
  mkdir -p "$DIR/.env-backups" && chmod 700 "$DIR/.env-backups"
  cp -p "$FILE" "$DIR/.env-backups/$(basename "$FILE").$(date +%Y%m%d-%H%M%S)"
fi
umask 077
{ [ -f "$FILE" ] && grep -v "^${VAR}=" "$FILE"; printf '%s=%s\n' "$VAR" "$K"; } > "$FILE.tmp" && mv "$FILE.tmp" "$FILE" && chmod 600 "$FILE"
unset K

# Keep the key out of Git.
if ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null) && ROOT=$(cd "$ROOT" && pwd -P); then
  for p in "$FILE" "$DIR/.env-backups/x"; do
    if ! git -C "$ROOT" check-ignore -q "$p" 2>/dev/null; then
      rel="${p#"$ROOT"/}"; [ "$p" = "$DIR/.env-backups/x" ] && rel="${rel%/x}/"
      printf '%s\n' "$rel" >> "$ROOT/.gitignore"; echo "Added $rel to .gitignore so it is never committed."
    fi
  done
fi
echo "Saved $VAR to $FILE ($HINT)."
