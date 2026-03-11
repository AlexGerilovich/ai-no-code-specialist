#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOURNAL_DIR="$REPO_DIR/journal"
PLAN_FILE="$REPO_DIR/curriculum/day_plan.tsv"
STATE_DIR="$REPO_DIR/.state"
CURRENT_DAY_FILE="$STATE_DIR/current_day"

cmd="${1:-status}"
shift || true
payload="${*:-}"

mkdir -p "$JOURNAL_DIR" "$STATE_DIR"

normalize_day() {
  local raw="${1:-}"
  raw="${raw#0}"
  if [ -z "$raw" ]; then
    raw="0"
  fi
  printf "%02d" "$((10#$raw))"
}

get_current_day() {
  if [ -f "$CURRENT_DAY_FILE" ]; then
    cat "$CURRENT_DAY_FILE"
  else
    echo "01"
  fi
}

journal_file_for_day() {
  local day="$1"
  echo "$JOURNAL_DIR/day-$day.md"
}

plan_field() {
  local day="$1"
  local field="$2"
  python3 - "$PLAN_FILE" "$day" "$field" <<'PY'
from pathlib import Path
import sys

plan_file = Path(sys.argv[1])
day = sys.argv[2]
field = sys.argv[3]

if not plan_file.exists():
    print("")
    raise SystemExit

lines = plan_file.read_text(encoding="utf-8").splitlines()
if not lines:
    print("")
    raise SystemExit

header = lines[0].split("|")
index = {name: i for i, name in enumerate(header)}

for line in lines[1:]:
    parts = line.split("|")
    if parts[0] == day:
        print(parts[index[field]])
        raise SystemExit

print("")
PY
}

count_days() {
  find "$JOURNAL_DIR" -maxdepth 1 -type f -name 'day-*.md' | wc -l | tr -d ' '
}

count_artifacts() {
  find "$REPO_DIR/cases" "$REPO_DIR/workflows" -type f 2>/dev/null | wc -l | tr -d ' '
}

status_message() {
  local day theme goal days artifacts journal_file journal_state next_step
  day="$(get_current_day)"
  theme="$(plan_field "$day" "theme")"
  goal="$(plan_field "$day" "goal")"
  days="$(count_days)"
  artifacts="$(count_artifacts)"
  journal_file="$(journal_file_for_day "$day")"

  if [ -f "$journal_file" ]; then
    journal_state="OK (Day $day)"
    next_step="/report or /accept"
  else
    journal_state="MISSING"
    next_step="/day $day"
  fi

  cat <<MSG
Agent: ONLINE
Mode: STDOUT(JSON)
Time: $(date --iso-8601=seconds)
Journal: $journal_state
Day: $day
Theme: $theme
Goal: $goal
Days completed: $days
Artifacts detected: $artifacts
Current journal: journal/day-$day.md
Next: $next_step
MSG
}

start_message() {
  local day theme goal tasks deliverables tests commit
  day="${1:-$(get_current_day)}"
  day="$(normalize_day "$day")"
  theme="$(plan_field "$day" "theme")"
  goal="$(plan_field "$day" "goal")"
  tasks="$(plan_field "$day" "tasks")"
  deliverables="$(plan_field "$day" "deliverables")"
  tests="$(plan_field "$day" "tests")"
  commit="$(plan_field "$day" "commit")"

  cat <<MSG
Day: $day
Theme: $theme

Goal:
$goal

Time:
60–90 minutes

Tasks:
$tasks

Deliverables:
$deliverables

Tests:
$tests

Suggested commit:
$commit
MSG
}

append_report() {
  local day journal_file
  day="$(get_current_day)"
  journal_file="$(journal_file_for_day "$day")"

  if [ ! -f "$journal_file" ]; then
    echo "❌ Нет journal для Day $day. Сначала /day $day"
    exit 1
  fi

  {
    echo
    echo "Report update ($(date +%F) $(date +%H:%M:%S))"
    echo "$payload"
  } >> "$journal_file"

  cat <<MSG
✅ /report принят. Проверь прогресс: /status. Когда готов — /accept
MSG
}

case "$cmd" in
  start)
    start_message "${1:-}"
    ;;
  status)
    status_message
    ;;
  report)
    append_report
    ;;
  *)
    cat <<MSG
Unknown command: $cmd

Allowed commands:
- start [day]
- status
- report "text"
MSG
    exit 1
    ;;
esac
