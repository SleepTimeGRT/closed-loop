#!/usr/bin/env bash
# closed-loop SessionStart hook — check for plugin updates
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
UPDATE_SCRIPT="$PLUGIN_DIR/bin/update-check.sh"

if [ -x "$UPDATE_SCRIPT" ]; then
  _UPD=$("$UPDATE_SCRIPT" 2>/dev/null || true)
  [ -n "$_UPD" ] && echo "$_UPD" || true
fi
