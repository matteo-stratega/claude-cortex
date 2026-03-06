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
#    30 8 * * * cd /path/to/cortex && ./scripts/morning-brief.sh
#
#  macOS launchd: see scripts/com.cortex.morning-brief.plist
#
# ============================================

set -eo pipefail

# Change to workspace root (script may be called from cron)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORKSPACE_DIR"

# Check prerequisites
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code not found. Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

if [ ! -f "brain/context.md" ]; then
    echo "Error: brain/context.md not found. Run /setup first to initialize your workspace."
    exit 1
fi

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "Error: ANTHROPIC_API_KEY not set. Non-interactive mode requires an API key."
    echo "Get one at https://console.anthropic.com"
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

Keep it under 20 lines. No fluff." 2>&1) || {
    echo "Error: Claude failed to generate brief"
    echo "$BRIEF"
    exit 1
}

# Output to terminal
echo "$BRIEF"

# Save to file (append if already exists today)
BRIEF_FILE="notes/daily-summaries/brief-$(date '+%Y%m%d').md"
if [ -f "$BRIEF_FILE" ]; then
    echo "" >> "$BRIEF_FILE"
    echo "---" >> "$BRIEF_FILE"
    echo "" >> "$BRIEF_FILE"
    echo "$BRIEF" >> "$BRIEF_FILE"
    echo "Appended to $BRIEF_FILE" >&2
else
    echo "$BRIEF" > "$BRIEF_FILE"
    echo "Saved to $BRIEF_FILE" >&2
fi
