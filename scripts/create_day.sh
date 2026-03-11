#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY="$(date +%F)"
DAY_FILE="$REPO_DIR/journal/$TODAY.md"
TEMPLATE="$REPO_DIR/templates/daily.md"

mkdir -p "$REPO_DIR/journal"

if [ -f "$DAY_FILE" ]; then
  echo "Journal already exists: $DAY_FILE"
  exit 0
fi

if [ ! -f "$TEMPLATE" ]; then
  echo "Template not found: $TEMPLATE"
  exit 1
fi

cp "$TEMPLATE" "$DAY_FILE"
echo "Created: $DAY_FILE"
