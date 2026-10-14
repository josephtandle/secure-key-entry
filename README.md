# Secure Key Entry

A small pop-up for pasting API keys and passwords, so they go straight into your project's `.env` file (or your system keychain) and never into the AI chat. Works with Claude Code and Codex, on Mac and Windows.

## Why

Anything you paste into a chat is stored in the conversation history. Keys that end up there should be treated as leaked. With this skill installed, your AI assistant opens a private pop-up instead of asking you to paste a key into the chat.

## Install

Paste this into Claude Code or Codex:

```
Install the secure-key-entry skill from https://github.com/josephtandle/secure-key-entry. Clone it (or pull the latest if it is already cloned) into ~/.secure-key-entry, then run scripts/install.sh on Mac, or scripts/install.ps1 with PowerShell on Windows. Confirm the skill is in ~/.claude/skills/secure-key-entry and ~/.agents/skills/secure-key-entry.
```

Or run it yourself:

- Mac: `git clone https://github.com/josephtandle/secure-key-entry ~/.secure-key-entry && bash ~/.secure-key-entry/scripts/install.sh`
- Windows (PowerShell): `git clone https://github.com/josephtandle/secure-key-entry $HOME\.secure-key-entry; powershell -ExecutionPolicy Bypass -File $HOME\.secure-key-entry\scripts\install.ps1`

To update to the latest version later, run `git -C ~/.secure-key-entry pull` and the install script again.

## Use

Just ask for what you need, for example "connect my OpenAI key". The assistant will say a pop-up is coming. Paste the key into the pop-up and click Save.

You can also run it directly:

- Mac: `bash scripts/secure-key-entry.sh --var OPENAI_API_KEY --env-file .env --prefix sk-`
- Windows: `powershell -ExecutionPolicy Bypass -File scripts\secure-key-entry.ps1 -Var OPENAI_API_KEY -EnvFile .env -Prefix sk-`

What it does:

- Saves `NAME=value` to `.env` (keeps your other lines, backs up the old file into `.env-backups/`), and locks the file to your user account.
- Adds `.env` and the backups to `.gitignore` when the project uses Git, so the key is never committed.
- Shows only the length and last 4 characters, so you can check you pasted the right key.
- `--prefix` refuses a key that does not start the way it should, which catches pasting the wrong thing.
- Mac: `--keychain <name>` saves to the macOS Keychain instead. Windows: `-UserEnv` saves a user environment variable instead.

Created by Joe Che, mastermindshq.business. Free to use, share, and adapt.
