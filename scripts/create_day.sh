#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY="$(date +%F)"
JOURNAL_DIR="$REPO_DIR/journal"
STATE_DIR="$REPO_DIR/.state"
CURRENT_DAY_FILE="$STATE_DIR/current_day"
DAY_RAW="${1:-}"

mkdir -p "$JOURNAL_DIR" "$STATE_DIR"

normalize_day() {
  local raw="${1:-}"
  raw="${raw#0}"
  if [ -z "$raw" ]; then
    raw="0"
  fi
  printf "%02d" "$((10#$raw))"
}

if [ -z "$DAY_RAW" ]; then
  if [ -f "$CURRENT_DAY_FILE" ]; then
    DAY="$(cat "$CURRENT_DAY_FILE")"
  else
    DAY="01"
  fi
else
  DAY="$(normalize_day "$DAY_RAW")"
fi

PLAN_FILE="$REPO_DIR/daily_plans/day-$DAY.md"
DAY_FILE="$JOURNAL_DIR/$TODAY.md"

if [ ! -f "$PLAN_FILE" ]; then
  echo "Plan not found: daily_plans/day-$DAY.md"
  exit 1
fi

if [ -f "$DAY_FILE" ]; then
  EXISTING_DAY="$(grep -m1 '^Day:' "$DAY_FILE" | sed 's/^Day:[[:space:]]*//' | tr -d '\r' || true)"
  if [ "$EXISTING_DAY" = "$DAY" ]; then
    echo "Journal already exists: journal/$TODAY.md"
    exit 0
  fi
  echo "Journal already exists for Day $EXISTING_DAY: journal/$TODAY.md"
  exit 2
fi

cp "$PLAN_FILE" "$DAY_FILE"

python3 - "$DAY_FILE" "$TODAY" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
today = sys.argv[2]
text = path.read_text(encoding="utf-8")
text = text.replace("Date:\n", f"Date: {today}\n", 1)
path.write_text(text, encoding="utf-8")
PY

echo "$DAY" > "$CURRENT_DAY_FILE"
echo "Created: $DAY_FILE"
