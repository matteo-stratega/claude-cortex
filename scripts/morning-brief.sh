#!/bin/bash

# ============================================
#  MORNING BRIEF — Automated Daily Status
# ============================================
#
#  Runs Claude Code non-interactively to generate
#  a morning brief from your brain context.
#
#  Usage:
#    ./scripts/morning-brief.sh
#
#  Cron (every day at 8:30 AM):
#    30 8 * * * cd /path/to/workspace && ./scripts/morning-brief.sh
#
#  macOS launchd: see scripts/com.cortex.morning-brief.plist
#
# ============================================

set -e

# Change to workspace root (script may be called from cron)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORKSPACE_DIR"

# Check claude is available
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code not found. Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Generate brief
BRIEF=$(claude -p "Read brain/context.md and the latest file in notes/daily-summaries/ (if any exist). Then generate a morning brief in this format:

## Brief — $(date '+%A, %d %B %Y')

**Focus:** [main area from context]

### Yesterday
- [key completions from latest closing report, or 'First brief — no prior sessions' if none exist]

### Today's Priorities
1. [most urgent from This Week]
2. [second priority]
3. [third priority]

### Blockers
- [anything stuck or waiting, or 'None' if clear]

Keep it under 20 lines. No fluff." 2>/dev/null)

# Output to terminal
echo "$BRIEF"

# Optionally save to file
BRIEF_FILE="notes/daily-summaries/brief-$(date '+%Y%m%d').md"
echo "$BRIEF" > "$BRIEF_FILE"
echo ""
echo "Saved to $BRIEF_FILE"
