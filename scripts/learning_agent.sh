#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JOURNAL_DIR="$REPO_DIR/journal"
METRICS_FILE="$REPO_DIR/metrics/learning_metrics.md"
PORTFOLIO_FILE="$REPO_DIR/metrics/portfolio_metrics.md"
CURRICULUM_FILE="$REPO_DIR/curriculum.md"

TODAY="$(date +%F)"
TODAY_FILE="$JOURNAL_DIR/$TODAY.md"

cmd="${1:-status}"
shift || true
payload="${*:-}"

mkdir -p "$JOURNAL_DIR"

create_day_if_missing() {
  if [ ! -f "$TODAY_FILE" ]; then
    "$REPO_DIR/scripts/create_day.sh" >/dev/null 2>&1 || true
  fi
}

count_days() {
  find "$JOURNAL_DIR" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' '
}

count_artifacts() {
  find "$REPO_DIR/cases" "$REPO_DIR/workflows" -type f 2>/dev/null | wc -l | tr -d ' '
}

current_case() {
  if grep -qi "Intake Bot" "$PORTFOLIO_FILE" 2>/dev/null; then
    echo "Telegram Intake Bot"
  else
    echo "Case not defined"
  fi
}

start_message() {
  create_day_if_missing
  cat <<MSG
Day: $TODAY

Goal:
Document and validate the first portfolio case: Telegram Intake Bot

Time:
60–90 minutes

Deliverables:
1. Create a case file from CASE_TEMPLATE.md
2. Define business problem, input, output, workflow logic
3. Export or prepare first n8n workflow draft
4. Add at least 1 happy path and 1 failure path
5. Fill today's journal

Suggested artifact names:
- cases/telegram-intake-bot/README.md
- workflows/telegram-intake-bot-v1.json

Definition of Done:
- artifact exists
- journal exists
- happy path defined
- failure path defined
- commit created
MSG
}

status_message() {
  local days artifacts case_name
  days="$(count_days)"
  artifacts="$(count_artifacts)"
  case_name="$(current_case)"

  cat <<MSG
Training Status

Days completed: $days
Artifacts detected: $artifacts
Current focus: $case_name

Required loop:
1. /start
2. build artifact
3. /report what was done
4. commit to git

Today's journal:
$TODAY_FILE
MSG
}

append_report() {
  create_day_if_missing

  {
    echo
    echo "Report update ($TODAY $(date +%H:%M:%S))"
    echo "$payload"
  } >> "$TODAY_FILE"

  cat <<MSG
Report saved to:
$TODAY_FILE

Pre-check:
- report recorded
- journal exists

Before PASS confirm:
1. artifact created
2. happy path present
3. failure path present
4. git commit done
MSG
}

pass_check() {
  local missing=0

  echo "PASS check for $TODAY"
  echo

  if [ ! -f "$TODAY_FILE" ]; then
    echo "- missing journal: $TODAY_FILE"
    missing=1
  else
    echo "+ journal exists"
  fi

  if [ ! -f "$REPO_DIR/cases/telegram-intake-bot/README.md" ]; then
    echo "- missing case artifact: cases/telegram-intake-bot/README.md"
    missing=1
  else
    echo "+ case artifact exists"
  fi

  if ! find "$REPO_DIR/workflows" -maxdepth 1 -type f | grep -q .; then
    echo "- no workflow artifact found in workflows/"
    missing=1
  else
    echo "+ workflow artifact found"
  fi

  if ! git -C "$REPO_DIR" log -1 --pretty=%B >/dev/null 2>&1; then
    echo "- unable to read git history"
    missing=1
  else
    echo "+ git history available"
  fi

  echo
  if [ "$missing" -eq 0 ]; then
    echo "PASS: minimum conditions met"
  else
    echo "FAIL: not enough evidence for PASS"
  fi
}

case "$cmd" in
  start)
    start_message
    ;;
  status)
    status_message
    ;;
  report)
    append_report
    ;;
  pass-check)
    pass_check
    ;;
  *)
    cat <<MSG
Unknown command: $cmd

Allowed commands:
- start
- status
- report "text"
- pass-check
MSG
    exit 1
    ;;
esac
