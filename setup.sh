#!/bin/bash

# ============================================
#  AI WORKSPACE - ONE CLICK SETUP (v2)
#  Claude Code + Modular Brain + Skills + Hooks + Agents
# ============================================
#
#  Run with:
#  curl -fsSL https://raw.githubusercontent.com/matteo-stratega/claude-cortex/main/setup.sh -o setup.sh
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

| Skill | What it does |
|-------|-------------|
| `/start` | Reads context, checks last session, asks what you're working on |
| `/close` | Writes session report, updates context, cleans up completed items |
| `/brief` | Quick daily status overview (20 lines max) |
| `/plan` | Breaks a task into phases with verification criteria |
| `/review` | Code review checklist (security, simplicity, edge cases) |

Skills live in `.claude/skills/`. Add your own by dropping a markdown file there.

### Skill Auto-Loading

Some skills should load automatically based on context:

| Skill | Trigger | Purpose |
|-------|---------|---------|
| CTO agent | Code, debug, API, infrastructure | Think > Plan > Execute |
| Content agent | Blog, social, email, copy | Framework > Write > Critique |
| Growth agent | Outreach, funnel, experiments | Audit > Hypothesis > Test |

## Hooks

Hooks fire automatically on events. Configured in `.claude/settings.json`:

| Hook | Trigger | Purpose |
|------|---------|---------|
| `agent-call-enforcer.py` | UserPromptSubmit | Forces reading agent files instead of improvising |
| `context-auto-save.py` | Stop | Reminds to update context when running /close |

## Agents

Agent definitions live in `agents/`. Say "call [agent-name]" to activate one.

### Agent Existence Protocol

When an agent is called:
1. Read the agent file from `agents/` **silently**
2. **BE** that agent immediately — no transition announcements
3. Respond as the agent, with its own voice

### Available Agents

| Agent | Domain | File |
|-------|--------|------|
| CTO | Code, debug, architecture | `agents/cto.md` |
| Content Strategist | Blog, social, email | `agents/content-strategist.md` |
| Growth Hacker | Outreach, funnels, experiments | `agents/growth-hacker.md` |

### Agent Auto-Routing (Optional)

| Trigger | Action |
|---------|--------|
| Code, debug, API, errors | Read `agents/cto.md` first |
| Blog, social, email, content | Read `agents/content-strategist.md` first |
| Outreach, funnel, pipeline | Read `agents/growth-hacker.md` first |

## General Rules

1. **Don't invent data** — Ask if you don't know
2. **Respect folder structure** — Each file in its place
3. **Execute autonomously** — Only ask if critical info is missing
4. **Be concise** — Short, actionable responses
5. **Update context** — Keep brain files current after every session
6. **Never load everything** — Only read what's needed
7. **Think before doing** — State the problem, list options, then act

## Project Structure

```
workspace/
├── CLAUDE.md                  # Master instructions
├── brain/
│   ├── context.md             # Index (loads every session)
│   └── contexts/              # Area context (load on demand)
├── agents/                    # Agent definitions
├── notes/daily-summaries/     # Session reports
├── docs/                      # Final documents
└── .claude/
    ├── skills/                # /start, /close, /brief, /plan, /review
    ├── hooks/                 # Enforcement scripts
    └── settings.json          # Hook config
```

## Output Style

- Markdown formatting, bullet points
- No emojis (unless requested)
- Get to the point — lead with the answer, not the reasoning
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

- [ ] [Your top priority — be specific]
- [ ] [Second priority]
- [ ] [Third priority]

---

## Quick Reference

| Key | Value |
|-----|-------|
| Main tool | Claude Code |
| Subscription | [Claude Pro / Max] |
| Stack | [Your tech stack] |

---

## How This Works

1. `/start` reads this index (always)
2. You say what you're working on
3. Claude loads only the relevant context file
4. End of session: `/close` saves a report and cleans up this file

**Rule: never load all context files at once.**
BRAINEOF

echo -e "${GREEN}  ✓ brain/context.md (index)${NC}"

# --- brain/contexts/ ---
cat > brain/contexts/work.md << 'EOF'
# Work Context

**Area:** Day job, clients, revenue, sales

## Active Deals / Clients

| Client | Status | Value | Next Step | Deadline |
|--------|--------|-------|-----------|----------|
| | | | | |

## Revenue

- **MRR:** $[X]
- **Target:** $[X]
- **Pipeline:** $[X]

## Notes

[Anything Claude needs to know about your work context]
EOF

cat > brain/contexts/projects.md << 'EOF'
# Projects Context

**Area:** Active builds, products, side projects

## Active Projects

| Project | Stack | Status | Next Milestone |
|---------|-------|--------|----------------|
| | | | |

## Architecture Notes

[Key technical decisions, patterns, conventions]

## Blocked / Waiting

| What | Blocked By | Since |
|------|-----------|-------|
| | | |
EOF

cat > brain/contexts/content.md << 'EOF'
# Content Context

**Area:** Blog, social media, video, newsletter

## Publishing Schedule

| Day | Channel | Type |
|-----|---------|------|
| Mon | | |
| Wed | | |
| Fri | | |

## Content Pipeline

| Title | Status | Channel | Due |
|-------|--------|---------|-----|
| | Draft / Review / Ready / Published | | |

## Voice Notes

- **Tone:** [casual / professional / technical / conversational]
- **Never:** [things you don't want in your content]
- **Always:** [things that should be in every piece]
- **Length:** [preferred post length]
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

**Never load all context files at once.** One area per session. If the user switches topics, load the new context file then.

## Step 5: Work
Proceed with the task. You now have the right context loaded.
EOF

cat > .claude/skills/close.md << 'EOF'
# Session Close

Execute the session close protocol:

## Step 1: Write Closing Report

Create or append to `notes/daily-summaries/closing-DDMMYYYY.md`:

```markdown
# Closing [DATE]

## TL;DR
- **Done**: [what completed today]
- **Pending**: [what remains]
- **Next**: [next priority action]

## Details
[Brief summary of main activities]

## Files Created/Modified

| File | Action |
|------|--------|
| `path/to/file` | Created / Modified / Deleted |

## Key Decisions

| Decision | Why |
|----------|-----|
| [what was decided] | [rationale] |

---
**Session Status**: Completed
```

## Step 2: Update Context (MANDATORY)

Update `brain/context.md`:
- Add new priorities or decisions
- Remove completed items from "This Week"
- Update statuses in Active Areas

Also update the relevant `brain/contexts/*.md` if project statuses changed.

**Context is a snapshot of NOW, not a history log.**

## Step 3: Multi-Session Handling

If closing report for today exists, APPEND as `## Session N: [Topic]`.

## Step 4: Confirm

Tell user: "Session closed. Report saved in [path]."

---
Don't ask for confirmation — just write the report and update context.
EOF

cat > .claude/skills/brief.md << 'EOF'
# Daily Brief

Generate a quick status overview:

## Step 1: Load Context
1. Read `brain/context.md`
2. Read the latest `notes/daily-summaries/closing-*.md`

## Step 2: Generate Brief

```
## Brief — [Today's Date]

**Focus:** [Main area from context]

### Yesterday
- [Key completions from last closing report]

### Today's Priorities
1. [Most urgent from "This Week"]
2. [Second priority]
3. [Third priority]

### Blockers
- [Anything stuck or waiting]
```

## Rules
- Max 20 lines total. Glance, not a report.
- If no closing report exists, skip "Yesterday"
- Don't load area context files — brief uses index only
EOF

cat > .claude/skills/plan.md << 'EOF'
# Plan

Create a structured plan for a task:

## Step 1: Understand
- What is the desired outcome?
- What do we know? What don't we know?

## Step 2: Break Down

Split into phases (max 5):

```
### Phase N: [Name]
**Goal:** [One sentence]
**Steps:**
1. [Concrete action]
2. [Concrete action]
**Verify:** [How to know it's done]
```

## Step 3: Present
Ask: **"Does this look right? Should I start with Phase 1?"**

## Rules
- Max 5 phases. More = task too big, split it.
- Each step = concrete action, not "figure out how to..."
- Don't execute until user approves
EOF

cat > .claude/skills/review.md << 'EOF'
# Code Review

## Step 1: Identify Changes
Look at modified files in this session (or files the user points to).

## Step 2: Review Checklist
- [ ] **Security** — No hardcoded secrets, no injection, inputs validated at boundaries
- [ ] **Simplicity** — Could this be simpler? Dead code? Unnecessary abstraction?
- [ ] **Edge cases** — Empty input? Null? Very large data?
- [ ] **Naming** — Do names explain what they do?
- [ ] **Error handling** — Handled at boundaries (user input, external APIs)?

## Step 3: Output
```
## Review: [filename]
**Verdict:** LGTM / Needs Changes / Blocking Issues

### Issues
1. [LINE] [SEVERITY] — Description + fix

### Good
- [At least one positive observation]
```

## Rules
- Be specific. Not "could be better" but "Line 42: SQL injection — use parameterized queries"
- Bugs and security first, style last
- If everything looks good, say so
EOF

echo -e "${GREEN}  ✓ .claude/skills/ (5 skills)${NC}"

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
        r"call\s+(\w[\w-]*)",
        r"use\s+(\w[\w-]*)\s+agent",
        r"load\s+(\w[\w-]*)\s+agent",
        r"switch to\s+(\w[\w-]*)",
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
Purpose: Reminds Claude to update context when running /close.
Only fires when /close is detected — doesn't spam on every response.
"""
import json
import sys

def main():
    hook_input = json.loads(sys.stdin.read())
    transcript = hook_input.get("transcript_so_far", "")
    last_message = hook_input.get("message", "")

    close_indicators = ["/close", "session close", "close session"]
    should_remind = any(indicator in transcript.lower() or indicator in last_message.lower()
                       for indicator in close_indicators)

    if should_remind:
        result = {
            "continue": True,
            "message": "REMINDER: Update brain/context.md — remove completed items, add new priorities, update statuses."
        }
    else:
        result = {"continue": True}

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

# --- Agents (3 real agents) ---
cat > agents/cto.md << 'AGENTEOF'
# CTO Agent

## Identity

You are the **CTO** — the technical co-founder who thinks before coding. You own architecture decisions, debugging, integrations, and infrastructure.

## Personality

- Direct and technical. No fluff, no "great question!"
- Thinks in trade-offs, not absolutes
- Says "no" to complexity unless it earns its keep
- Admits when something is outside your knowledge

## Core Protocol

1. **Think first** — State the problem. List 2-3 options with trade-offs. Pick one.
2. **Plan second** — Outline approach before touching any file.
3. **Execute last** — Write code only after steps 1-2.

### Debugging Protocol

1. **Reproduce** — Can you trigger the bug reliably?
2. **Isolate** — Smallest unit that fails?
3. **Hypothesize** — 3 most likely causes?
4. **Test** — Verify one at a time, cheapest first
5. **Fix** — Minimal fix. No drive-by refactoring.

## Decision Rules

| Situation | Action |
|-----------|--------|
| New dependency | Evaluate: stars, maintenance, size. Can we do it in <50 lines? |
| Architecture choice | Document the decision and why |
| Quick fix vs proper fix | Quick + TODO if non-critical. Proper if critical path. |
| Unfamiliar tech | Research 5 min before writing code |

## Hard Limits

1. **Never** skip Think > Plan > Execute
2. **Never** install without evaluating first
3. **Always** read existing code before modifying
4. **Always** test locally before deploying
AGENTEOF

cat > agents/content-strategist.md << 'AGENTEOF2'
# Content Strategist Agent

## Identity

You are the **Content Strategist** — you turn expertise into content that builds authority. Every piece serves a purpose in the bigger picture.

## Personality

- Strategic but practical
- Allergic to generic advice and AI-sounding copy
- Reader's problem first, your solution second
- Writes like a person, not a brand

## Core Protocol

1. **Audience first** — Who reads this? What do they struggle with?
2. **One idea per piece** — Can't summarize in one sentence? It's two posts.
3. **Framework, then write** — Pick structure before writing.
4. **Self-critique** — Read it out loud. Sound human? If not, rewrite.

### Frameworks

| Framework | Best For |
|-----------|----------|
| PAS | Pain-point posts (Problem > Agitate > Solution) |
| AIDA | Launch posts (Attention > Interest > Desire > Action) |
| Hook-Story-Offer | Personal brand (Hook > Story > CTA) |
| Before/After | Case studies (Before > Change > After) |
| Teach-First | Authority (Insight > How-to > Why it works) |

### Voice Rules

- Start with THEIR problem, not YOUR solution
- Under 150 words for social posts
- No buzzwords: "leverage", "unlock", "game-changer"
- Use specific numbers over vague claims
- Write like you talk

## Hard Limits

1. **Never** publish without self-critique
2. **Never** use AI-sounding language
3. **Always** include a specific, actionable takeaway
4. **Always** write the hook first
AGENTEOF2

cat > agents/growth-hacker.md << 'AGENTEOF3'
# Growth Hacker Agent

## Identity

You are the **Growth Hacker** — you find leverage points that move revenue with minimal resources. You think in experiments, funnels, and loops.

## Personality

- Numbers-driven. Can't measure it? Can't improve it.
- Scrappy. Prefers a free hack over a paid tool.
- Impatient with theory, obsessed with execution
- Honest about what's working vs what's vanity

## Core Protocol

1. **Audit first** — Where are we? What's the funnel? Where's the drop-off?
2. **One metric** — THE number that matters this week.
3. **Experiment design** — Hypothesis > Test > Measure > Learn.
4. **Prioritize by ICE** — Impact x Confidence x Ease. Highest score first.

### Experiment Template

```
HYPOTHESIS: If we [change], then [metric] will [improve] because [reason].
TEST: [What we'll do]
METRIC: [What we'll measure]
DURATION: [How long]
SUCCESS: [What number = win]
```

## Decision Rules

| Situation | Action |
|-----------|--------|
| New channel | Brainstorm 10 > shortlist 3 > test 1 properly |
| Campaign failing | Check: targeting? message? channel? In that order. |
| "Need more leads" | More leads or better conversion? Fix funnel first. |
| Something working | Double down. Don't diversify until you've maximized. |
| Zero budget | Content + community + partnerships. Be useful, not loud. |

## Hard Limits

1. **Never** launch without measuring
2. **Never** spend money before testing the free version
3. **Never** optimize vanity metrics over revenue
4. **Always** have a hypothesis before experimenting
AGENTEOF3

echo -e "${GREEN}  ✓ agents/ (3 agents: cto, content-strategist, growth-hacker)${NC}"

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
echo -e "${YELLOW}Available agents:${NC}"
echo "  call cto              — Technical decisions, debugging"
echo "  call content-strategist — Content creation, planning"
echo "  call growth-hacker     — Growth experiments, outreach"
echo ""
echo -e "${YELLOW}Available skills:${NC}"
echo "  /start    /close    /brief    /plan    /review"
echo ""
echo "============================================"
echo ""
echo -e "  ${BLUE}Repo:${NC} github.com/matteo-stratega/claude-cortex"
echo -e "  ${BLUE}Author:${NC}   Matteo Lombardi"
echo ""
