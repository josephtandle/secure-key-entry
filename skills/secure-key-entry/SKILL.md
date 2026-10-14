---
name: secure-key-entry
description: Use whenever the user needs to provide an API key, token, password, or any other secret. Opens a private pop-up on their computer so the secret goes straight into a .env file or the system keychain and never appears in the chat. Never ask the user to paste a secret into the chat.
---

# Secure key entry

Secrets never go in the chat. When a task needs an API key, token, or password:

1. Do not ask the user to paste it into the conversation. If they paste one anyway, tell them to revoke it and create a new one, because chat history is not a safe place for keys.
2. Tell the user: "A small pop-up will appear on your screen. Paste the key there and click Save."
3. Run the script for their computer (scripts sit next to this file, in `scripts/`):

macOS:

```bash
bash "<this skill folder>/scripts/secure-key-entry.sh" --var OPENAI_API_KEY --env-file .env --prefix sk-
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "<this skill folder>\scripts\secure-key-entry.ps1" -Var OPENAI_API_KEY -EnvFile .env -Prefix sk-
```

- `--var` / `-Var`: the variable name the project expects (check the project's README or `.env.example`).
- `--env-file` / `-EnvFile`: usually `.env` in the project root.
- `--prefix` / `-Prefix`: optional. Use the provider's known prefix (for example `sk-` for OpenAI, `sk-ant-` for Anthropic, `re_` for Resend, `sk_live_` or `rk_live_` for Stripe live keys) so a wrong paste is refused.
- macOS only: `--keychain <service>` saves to the Keychain instead of a file.
- Windows only: `-UserEnv` saves a user environment variable instead of a file.

4. The script prints only the length and the last 4 characters. Never print, echo, `cat`, or read the saved value back into the chat. To use it, let the program load `.env`, or pipe it directly, for example `security find-generic-password -a "$USER" -s <service> -w | some-cli login --with-token`.
5. The script adds the `.env` file to `.gitignore` when the project is a Git repository. Never commit `.env`, and never remove it from `.gitignore`.
6. If the pop-up cannot appear (for example, a remote or headless machine), stop and tell the user to add the line `NAME=value` to `.env` themselves in a text editor. Do not fall back to asking for the key in chat.
