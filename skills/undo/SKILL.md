---
name: undo
description: The undo button. Use when the user types /undo or $undo, or says "undo", "go back", "revert that", "put it back how it was", or "restore the earlier version". Takes the project back to an earlier Git save point without losing anything, so the undo can itself be undone.
---

# Undo

Take the project back to an earlier save point. Nothing is ever deleted: the current state is saved first, and going back creates a new save point, so the user can always undo the undo.

1. If the folder is not a Git repository or has no save points yet, say so plainly and offer to start save points now (see the `save-points` skill). Stop there.
2. Save the current state first, even if it is broken: `git add -A && git commit -m "Save point: before undo"` (skip if there is nothing to commit).
3. Show the last save points in plain English, newest first, numbered, from `git log --format="%h %ar %s" -10`. For example: "1. 5 minutes ago: added the contact form".
4. Pick the target:
   - If the user just said "undo" with no detail: when step 2 found unsaved changes, the target is the last save point before them (the entry right after "Save point: before undo"). When there were no unsaved changes, the target is the save point before the most recent one. Say which one you are going back to.
   - If they described a moment ("before we changed the colours"), find the matching save point and confirm it in one line.
5. Restore every file to that save point and record it as a new save point:
   `git restore --source=<hash> --staged --worktree -- .`
   then `git add -A && git commit -m "Undo: back to <hash> (<its message>)"`.
   Files listed in `.gitignore` (such as `.env`) are not touched.
6. Check the result the way the user will see it (reload the page or rerun the app) and tell them in one or two sentences what is back. Remind them they can say "undo" again to go further back, or "redo" to return to where they were.

**Redo:** if the user says "redo" or "undo the undo", restore the "Save point: before undo" commit the same way as step 5.

Never use `git reset --hard`, `git clean`, `git checkout -- .`, or force-push for undo.
