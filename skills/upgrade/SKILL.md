---
name: upgrade
description: |
  Upgrade the closed-loop plugin to the latest version. Detects the install
  location, runs the update, and shows what changed. Use when asked to
  "upgrade closed-loop", "update closed-loop", "get latest version", or when
  the session start hook outputs UPGRADE_AVAILABLE.
---

# Upgrade closed-loop

Update the closed-loop plugin to the latest version.

## When UPGRADE_AVAILABLE is detected

If the SessionStart hook output `UPGRADE_AVAILABLE <old> <new>`, tell the user:

> closed-loop **v{new}** is available (you're on v{old}). Run `/upgrade` to update, or ignore to skip.

Do NOT auto-upgrade. Just inform.

## When invoked as /upgrade

### Step 1: Check for updates

```bash
bash "${CLAUDE_PLUGIN_ROOT}/bin/update-check.sh" 2>/dev/null || true
```

If output is empty or `UP_TO_DATE`, tell the user they're on the latest version and stop.

If output is `UPGRADE_AVAILABLE <old> <new>`, proceed to Step 2.

### Step 2: Run the update

Use `claude plugin update` to update the plugin:

```bash
claude plugin update closed-loop 2>&1
```

If the command succeeds, tell the user:

> closed-loop updated to v{new}! Restart Claude Code to apply the changes.

If the command fails, show the error and suggest manual update:

> Update failed. You can manually update by running:
> ```
> claude plugin update closed-loop
> ```

### Step 3: Show what's new

Read `${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md` if it exists. Summarize the changes between old and new version as 3-5 bullets. If no CHANGELOG exists, skip this step.
