---
name: safe-delete
description: Use whenever a file or folder needs to be deleted or removed. Sends it to the Trash (Mac) or Recycle Bin (Windows) instead of deleting it permanently, so the user can always get it back. Never use rm, rm -rf, del, Remove-Item, or rmdir on the user's files.
---

# Safe delete

Deleting always goes to the Trash or Recycle Bin, never straight to permanent deletion.

1. Before deleting anything in a project, make a save point (see the `save-points` skill) when the project uses Git.
2. Delete with the script next to this file:

macOS:

```bash
bash "<this skill folder>/scripts/safe-delete.sh" path/to/file-or-folder [more paths...]
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "<this skill folder>\scripts\safe-delete.ps1" path\to\file-or-folder [more paths...]
```

3. Tell the user what went to the Trash and that they can restore it from there.

Rules:
- Never use `rm`, `rm -rf`, `rmdir`, `del`, `erase`, `Remove-Item`, `unlink`, or `git clean` on the user's files.
- Temporary files you created yourself in a system temp folder during this task are the only exception.
- Never empty the Trash or Recycle Bin. That is the user's decision.
- If the script cannot reach the Trash (for example on a server), move the item into a `_deleted/<date>/` folder inside the project instead and tell the user.
