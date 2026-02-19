#!/bin/bash

# ============================================
#  AI WORKSPACE - ONE CLICK SETUP (v2)
#  Claude Code + Modular Brain + Skills + Hooks + Agents
# ============================================
#
#  Run with:
#  curl -fsSL https://raw.githubusercontent.com/matteo-stratega/claude-workspace-template/main/setup.sh -o setup.sh
#  bash setup.sh
#
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   AI WORKSPACE SETUP (v2)${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# ============================================
# STEP 1: Check Node.js
# ============================================
echo -e "${YELLOW}[1/5] Checking Node.js...${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}Node.js not found!${NC}"
    echo ""
    echo "Please install Node.js first:"
    echo "  → https://nodejs.org (download LTS version)"
    echo ""
    echo "Then run this script again."
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}  ✓ Node.js $NODE_VERSION${NC}"

# ============================================
# STEP 2: Install Claude Code
# ============================================
echo ""
echo -e "${YELLOW}[2/5] Installing Claude Code...${NC}"

if command -v claude &> /dev/null; then
    echo -e "${GREEN}  ✓ Claude Code already installed${NC}"
else
    npm install -g @anthropic-ai/claude-code
    echo -e "${GREEN}  ✓ Claude Code installed${NC}"
fi

# ============================================
# STEP 3: Create workspace
# ============================================
echo ""
echo -e "${YELLOW}[3/5] Creating workspace...${NC}"

read -p "Workspace name (default: workspace): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-workspace}
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr ' ' '-' | tr -cd '[:alnum:]-')

WORKSPACE_PATH="$HOME/$PROJECT_NAME"

if [ -d "$WORKSPACE_PATH" ]; then
    echo -e "${YELLOW}  ! Folder already exists: $WORKSPACE_PATH${NC}"
    read -p "  Continue anyway? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        echo "Aborted."
        exit 1
    fi
else
    mkdir -p "$WORKSPACE_PATH"
fi

cd "$WORKSPACE_PATH"
echo -e "${GREEN}  ✓ Workspace: $WORKSPACE_PATH${NC}"

# ============================================
# STEP 4: Create structure + files
# ============================================
echo ""
echo -e "${YELLOW}[4/5] Creating structure...${NC}"

# Directories
mkdir -p brain/contexts
mkdir -p notes/daily-summaries
mkdir -p docs
mkdir -p agents
mkdir -p .claude/skills
mkdir -p .claude/hooks

# --- CLAUDE.md ---
cat > CLAUDE.md << 'CLAUDEEOF'
# CLAUDE.md

Instructions for Claude Code in this workspace.

## Startup Protocol

On session start:
1. Read `brain/context.md` for current state (the index — always loaded)
2. Read latest `notes/daily-summaries/closing-*.md` (if exists)
3. Ask what we're working on
4. Load ONLY the relevant context file from `brain/contexts/`

**Never load all context files at once.**

## Skills

- `/start` - Start work session (loads context, proposes priorities)
- `/close` - End session (writes report, updates context)

## Hooks

Hooks fire automatically. Configured in `.claude/settings.json`:
- **UserPromptSubmit** → agent-call-enforcer (forces reading agent files)
- **Stop** → context-auto-save (reminds to update context on close)

## Agents

Agent definitions live in `agents/`. Say "call [agent]" to activate one.

## General Rules

1. **Don't invent data** - Ask if you don't know
2. **Respect folder structure** - Each file in its place
3. **Execute autonomously** - Only ask if critical info is missing
4. **Be concise** - Short, actionable responses
5. **Update context** - Keep brain files current
6. **Never load everything** - Only read what's needed

## Project Structure

```
workspace/
├── brain/context.md           # Index (loads always)
├── brain/contexts/            # Area context (load on demand)
├── agents/                    # Agent definitions
├── notes/daily-summaries/     # Session reports
├── docs/                      # Final documents
└── .claude/
    ├── skills/                # /start, /close
    ├── hooks/                 # Enforcement scripts
    └── settings.json          # Hook config
```

## Output Style

- Markdown formatting, bullet points
- No emojis (unless requested)
- Get to the point
CLAUDEEOF

echo -e "${GREEN}  ✓ CLAUDE.md${NC}"

# --- brain/context.md (index) ---
cat > brain/context.md << 'BRAINEOF'
# Context Index

**Last Updated:** [DATE]

This is the main index. It loads every session. Keep it under 60 lines.
Detailed context lives in `brain/contexts/` — load only what's relevant.

---

## Who I Am

- **Name:** [Your name]
- **Role:** [What you do]
- **Company:** [Your company/project]

---

## Active Areas

| Area | Context File | Status |
|------|-------------|--------|
| Work | `contexts/work.md` | Active |
| Projects | `contexts/projects.md` | Active |
| Content | `contexts/content.md` | Active |

---

## This Week

- [ ] Priority 1
- [ ] Priority 2
- [ ] Priority 3

---

## How This Works

1. `/start` reads this index (always)
2. You say what you're working on
3. Claude loads only the relevant context file
4. End of session: `/close` saves a report

**Rule: never load all context files at once.**

---

*Add your areas to the table above. Create matching files in `contexts/`.*
BRAINEOF

echo -e "${GREEN}  ✓ brain/context.md (index)${NC}"

# --- brain/contexts/ ---
cat > brain/contexts/work.md << 'EOF'
# Work Context

**Area:** Day job, clients, revenue, sales

## Active Deals / Clients

| Client | Status | Next Step | Deadline |
|--------|--------|-----------|----------|
| | | | |

## Notes

[Anything Claude needs to know about your work]
EOF

cat > brain/contexts/projects.md << 'EOF'
# Projects Context

**Area:** Active builds, products, side projects

## Active Projects

| Project | Stack | Status | Next Milestone |
|---------|-------|--------|----------------|
| | | | |

## Notes

[Technical decisions, patterns, architecture notes]
EOF

cat > brain/contexts/content.md << 'EOF'
# Content Context

**Area:** Blog, social media, video, newsletter

## Publishing Schedule

| Day | Channel | Type |
|-----|---------|------|
| | | |

## Content Pipeline

| Title | Status | Channel | Due |
|-------|--------|---------|-----|
| | | | |

## Voice Notes

[Tone, style, things to avoid — the more specific, the better Claude matches your voice]
EOF

echo -e "${GREEN}  ✓ brain/contexts/ (3 modules)${NC}"

# --- Skills ---
cat > .claude/skills/start.md << 'EOF'
# Session Start

Execute the session start protocol:

## Step 1: Load Context
1. Read `brain/context.md` (the index — always loaded)
2. Read the latest `notes/daily-summaries/closing-*.md` file (if exists)

## Step 2: Propose
Summarize in max 5 bullet points:
- What was done in last session (from closing report)
- What is pending
- Current focus from context index

Then ask: **"What are we working on today?"**

## Step 3: STOP
**Wait for response before proceeding.**

## Step 4: Load Relevant Context
Based on the user's answer, load ONLY the matching context file from `brain/contexts/`:

| User says... | Load |
|-------------|------|
| Work, clients, sales, deals | `brain/contexts/work.md` |
| Building, coding, projects | `brain/contexts/projects.md` |
| Content, blog, social, video | `brain/contexts/content.md` |

**Never load all context files at once.** One area per session.
EOF

cat > .claude/skills/close.md << 'EOF'
# Session Close

Execute the session close protocol:

## Step 1: Write Closing Report

Create file `notes/daily-summaries/closing-DDMMYYYY.md`:

```
# Closing [DATE]

## TL;DR
- **Done**: [what completed today]
- **Pending**: [what remains]
- **Next**: [next priority action]

## Files Created/Modified
- [list of files touched]

## Decisions Made
- [any key decisions worth remembering]

---
**Session Status**: Completed
```

## Step 2: Update Context

Update `brain/context.md` if there are:
- New priorities for "This Week"
- Completed tasks to remove
- Status changes in Active Areas

Also update the relevant `brain/contexts/*.md` file if project statuses changed.

## Step 3: Confirm

Tell user: "Session closed. Report saved in [path]."

---

Don't ask for confirmation — just write the report and update context.
EOF

echo -e "${GREEN}  ✓ .claude/skills/ (start + close)${NC}"

# --- Hooks ---
cat > .claude/hooks/agent-call-enforcer.py << 'HOOKEOF'
#!/usr/bin/env python3
"""
Hook: Agent Call Enforcer
Trigger: UserPromptSubmit
Purpose: Forces reading agent files when user calls an agent.
"""
import json
import sys
import re

def main():
    hook_input = json.loads(sys.stdin.read())
    message = hook_input.get("message", "").lower()

    patterns = [
        r"call\s+(\w+)",
        r"use\s+(\w+)\s+agent",
        r"load\s+(\w+)\s+agent",
        r"switch to\s+(\w+)",
    ]

    for pattern in patterns:
        match = re.search(pattern, message)
        if match:
            agent_name = match.group(1)
            result = {
                "continue": True,
                "message": f"REQUIRED: Read agents/{agent_name}.md before responding. Do NOT improvise agent behavior."
            }
            print(json.dumps(result))
            return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
HOOKEOF

cat > .claude/hooks/context-auto-save.py << 'HOOKEOF2'
#!/usr/bin/env python3
"""
Hook: Context Auto-Save Reminder
Trigger: Stop
Purpose: Reminds Claude to update context when closing a session.
"""
import json
import sys

def main():
    hook_input = json.loads(sys.stdin.read())

    result = {
        "continue": True,
        "message": "REMINDER: If this is a /close, make sure to update brain/context.md with any status changes, new decisions, or completed tasks."
    }
    print(json.dumps(result))

if __name__ == "__main__":
    main()
HOOKEOF2

chmod +x .claude/hooks/agent-call-enforcer.py
chmod +x .claude/hooks/context-auto-save.py

echo -e "${GREEN}  ✓ .claude/hooks/ (2 hooks)${NC}"

# --- settings.json ---
cat > .claude/settings.json << 'EOF'
{
  "permissions": {
    "allow": []
  },
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 .claude/hooks/agent-call-enforcer.py"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 .claude/hooks/context-auto-save.py"
          }
        ]
      }
    ]
  }
}
EOF

echo -e "${GREEN}  ✓ .claude/settings.json${NC}"

# --- Agent template ---
cat > agents/example-agent.md << 'AGENTEOF'
# Example Agent

> Copy this template, rename it, and make it yours. Delete this file when you have real agents.

## Identity

You are the **[Role Name]** — [one sentence about what this agent does].

## Personality

- [How does this agent communicate?]
- [What tone?]
- [What does this agent never do?]

## Core Protocol

When activated:
1. [First thing this agent always does]
2. [Second thing]
3. [Third thing]

## Decision Rules

| Situation | Action |
|-----------|--------|
| [When X happens] | [Do Y] |

## Hard Limits

1. **Never** [thing this agent must never do]
2. **Always** [thing this agent must always do]

---

**The test:** Does this agent need its own memory and personality that would conflict with another agent's? If yes, it's an agent. If no, it's a protocol inside an existing agent.
AGENTEOF

echo -e "${GREEN}  ✓ agents/example-agent.md${NC}"

# --- .gitignore ---
cat > .gitignore << 'EOF'
# OS files
.DS_Store
Thumbs.db

# Editor files
*.swp
*.swo
*~

# Node
node_modules/

# Credentials (never commit these)
.credentials/
*.pem
*.key
.env
.env.local
MASTER.env

# Claude Code local settings
.claude/settings.local.json

# Large data files (uncomment if needed)
# data/*.csv
# data/*.xlsx

# Temporary files
*.tmp
*.temp
EOF

echo -e "${GREEN}  ✓ .gitignore${NC}"

# ============================================
# STEP 5: Initialize git
# ============================================
echo ""
echo -e "${YELLOW}[5/5] Initializing git...${NC}"

if [ -d ".git" ]; then
    echo -e "${GREEN}  ✓ Git already initialized${NC}"
else
    git init --quiet
    git add -A
    git commit -m "Initial setup (v2)" --quiet
    echo -e "${GREEN}  ✓ Git initialized${NC}"
fi

# ============================================
# DONE!
# ============================================
echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}   SETUP COMPLETE${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
echo "Your workspace is ready:"
echo -e "  ${BLUE}$WORKSPACE_PATH${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "  1. cd $WORKSPACE_PATH"
echo "  2. claude"
echo "  3. /start"
echo ""
echo "  Then edit brain/context.md with your info."
echo ""
echo "============================================"
echo ""
echo -e "  ${BLUE}Template:${NC} github.com/matteo-stratega/claude-workspace-template"
echo -e "  ${BLUE}Author:${NC}   Matteo Lombardi"
echo ""
