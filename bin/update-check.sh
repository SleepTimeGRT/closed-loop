#!/usr/bin/env bash
# closed-loop update check — periodic version check.
#
# Output (one line, or nothing):
#   UPGRADE_AVAILABLE <old> <new>   — remote VERSION differs from local
#   (nothing)                       — up to date or check skipped
#
# Env overrides (for testing):
#   CLOSED_LOOP_DIR       — override auto-detected plugin root
#   CLOSED_LOOP_STATE_DIR — override ~/.closed-loop state directory
#   CLOSED_LOOP_REMOTE_URL — override remote VERSION URL
set -euo pipefail

PLUGIN_DIR="${CLOSED_LOOP_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
STATE_DIR="${CLOSED_LOOP_STATE_DIR:-$HOME/.closed-loop}"
CACHE_FILE="$STATE_DIR/last-update-check"
VERSION_FILE="$PLUGIN_DIR/VERSION"
REMOTE_URL="${CLOSED_LOOP_REMOTE_URL:-https://raw.githubusercontent.com/SleepTimeGRT/closed-loop/main/VERSION}"

# ─── Read local version ──────────────────────────────
LOCAL=""
if [ -f "$VERSION_FILE" ]; then
  LOCAL="$(cat "$VERSION_FILE" 2>/dev/null | tr -d '[:space:]')"
fi
if [ -z "$LOCAL" ]; then
  exit 0
fi

# ─── Check cache freshness (60 min TTL) ──────────────
if [ -f "$CACHE_FILE" ]; then
  CACHED="$(cat "$CACHE_FILE" 2>/dev/null || true)"
  case "$CACHED" in
    UP_TO_DATE*)
      STALE=$(find "$CACHE_FILE" -mmin +60 2>/dev/null || true)
      if [ -z "$STALE" ]; then
        CACHED_VER="$(echo "$CACHED" | awk '{print $2}')"
        if [ "$CACHED_VER" = "$LOCAL" ]; then
          exit 0
        fi
      fi
      ;;
    UPGRADE_AVAILABLE*)
      STALE=$(find "$CACHE_FILE" -mmin +720 2>/dev/null || true)
      if [ -z "$STALE" ]; then
        CACHED_OLD="$(echo "$CACHED" | awk '{print $2}')"
        if [ "$CACHED_OLD" = "$LOCAL" ]; then
          echo "$CACHED"
          exit 0
        fi
      fi
      ;;
  esac
fi

# ─── Slow path — fetch remote version ────────────────
mkdir -p "$STATE_DIR"

REMOTE=""
REMOTE="$(curl -sf --max-time 5 "$REMOTE_URL" 2>/dev/null || true)"
REMOTE="$(echo "$REMOTE" | tr -d '[:space:]')"

# Validate: must look like a version number
if ! echo "$REMOTE" | grep -qE '^[0-9]+\.[0-9.]+$'; then
  echo "UP_TO_DATE $LOCAL" > "$CACHE_FILE"
  exit 0
fi

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "UP_TO_DATE $LOCAL" > "$CACHE_FILE"
  exit 0
fi

# Versions differ
echo "UPGRADE_AVAILABLE $LOCAL $REMOTE" > "$CACHE_FILE"
echo "UPGRADE_AVAILABLE $LOCAL $REMOTE"
