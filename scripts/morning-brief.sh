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

# Inject the context DETERMINISTICALLY (cat it into the prompt) instead of
# asking the model to read it. In non-interactive mode "please read X" is
# unreliable — the model may skip the read and emit a hollow brief. Feeding the
# content guarantees it's there.
CONTEXT=$(cat brain/context.md)
LATEST_CLOSING=$(ls -t notes/daily-summaries/closing-*.md notes/daily-summaries/*/closing-*.md 2>/dev/null | head -1)
CLOSING_CONTENT="(no prior sessions yet)"
[ -n "$LATEST_CLOSING" ] && CLOSING_CONTENT=$(cat "$LATEST_CLOSING")

BRIEF=$(claude -p "Generate a morning brief from the context below. Do NOT call any tools — everything you need is here. Output ONLY the brief, starting at the '## Brief' line, no preamble.

=== brain/context.md ===
$CONTEXT

=== latest closing report ===
$CLOSING_CONTENT
=== end ===

Format:

## Brief — $(date '+%A, %d %B %Y')

**Focus:** [main area from context]

### Yesterday
- [key completions from the closing report above, or 'First brief — no prior sessions']

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

# Strip any preamble before the brief header (defense in depth).
case "$BRIEF" in
    *"## Brief"*) BRIEF=$(printf '%s\n' "$BRIEF" | sed -n '/## Brief/,$p') ;;
esac

# Hollow-output tripwire: a real brief has several non-blank lines.
NONBLANK=$(printf '%s\n' "$BRIEF" | grep -c .)
if [ "$NONBLANK" -lt 4 ]; then
    echo "Error: brief looks hollow (${NONBLANK} non-blank lines) — context may not have loaded. Not saving." >&2
    echo "$BRIEF" >&2
    exit 1
fi

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
