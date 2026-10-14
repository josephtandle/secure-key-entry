---
name: save-points
description: Use in every project to keep Git save points. Creates a save point before any significant change and after each working result, so the user can undo at any time with /undo (Claude Code) or $undo (Codex). Also use when the user says "save", "save point", "checkpoint", or asks what changed.
---

# Save points

Every project gets automatic save points using Git, so nothing the user builds can be lost and any change can be undone.

## First time in a project

1. If the folder is not a Git repository, run `git init`.
2. Make sure `.gitignore` exists and contains at least: `.env`, `.env.*`, `.env-backups/`, `node_modules/`, `.DS_Store`. Add only the lines that are missing.
3. If Git asks who you are, set it for this project only: `git config user.name "<their name>"` and `git config user.email "<their email or you@example.com>"`. Ask the user for their name if you do not know it.
4. Create the first save point: `git add -A` then `git commit -m "Save point: starting point"`.

## When to save

- **Before** any change that touches more than one file, deletes anything, installs something, or the user might want to reverse.
- **After** each change that works (you checked it), with a short plain-English message.

Command: `git add -A && git commit -m "Save point: <what changed, in plain words>"`. If there is nothing to commit, that is fine, carry on.

Never commit secrets: before saving, `git status --short` must not list `.env` or anything with keys in it. If it does, add it to `.gitignore` first.

## Rules

- Never use `git reset --hard`, `git clean`, `git checkout -- .`, `git push --force`, or anything that throws work away. Undo is always done by adding a new save point (see the `undo` skill), so every state stays recoverable.
- Do not push to GitHub or any remote unless the user asks.
- If another session or agent is working in this project at the same time, do not both edit the same files at once. Finish and save one, then start the other. If you notice files changing that you did not change, stop and tell the user before saving or undoing anything.
- When the user asks "what changed?", summarise `git log --oneline -10` and `git diff --stat` in plain English, not raw output.
