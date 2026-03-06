# ============================================
#  CORTEX - ONE CLICK SETUP (Windows)
#  An operating system for Claude Code
# ============================================
#  Right click -> Run with PowerShell
#  Or: powershell -ExecutionPolicy Bypass -File setup-windows.ps1
# ============================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   CORTEX SETUP" -ForegroundColor Cyan
Write-Host "   An operating system for Claude Code" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# STEP 1: Check Node.js
# ============================================
Write-Host "[1/5] Checking Node.js..." -ForegroundColor Yellow

$nodeCheck = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCheck) {
    Write-Host "Node.js not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Node.js first:"
    Write-Host "  -> https://nodejs.org (download LTS version)"
    Write-Host ""
    Write-Host "Then run this script again."
    Write-Host ""
    Write-Host "Press any key to close..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

$nodeVersion = node --version
Write-Host "  + Node.js $nodeVersion" -ForegroundColor Green

# ============================================
# STEP 2: Install Claude Code
# ============================================
Write-Host ""
Write-Host "[2/5] Installing Claude Code..." -ForegroundColor Yellow

$claudeCheck = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCheck) {
    Write-Host "  + Claude Code already installed" -ForegroundColor Green
} else {
    npm install -g @anthropic-ai/claude-code
    Write-Host "  + Claude Code installed" -ForegroundColor Green
}

# ============================================
# STEP 3: Create workspace
# ============================================
Write-Host ""
Write-Host "[3/5] Creating workspace..." -ForegroundColor Yellow

$ProjectName = Read-Host "Workspace name (default: cortex)"

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = "cortex"
}

$ProjectName = $ProjectName -replace '\s+', '-'
$ProjectName = $ProjectName -replace '[^a-zA-Z0-9-]', ''
$ProjectPath = "$env:USERPROFILE\Documents\$ProjectName"

if (Test-Path $ProjectPath) {
    Write-Host "  ! Folder already exists: $ProjectPath" -ForegroundColor Yellow
    $confirm = Read-Host "  Continue anyway? (y/n)"
    if ($confirm -ne "y") {
        Write-Host "Aborted."
        exit 1
    }
}

Write-Host "  + Workspace: $ProjectPath" -ForegroundColor Green

# ============================================
# STEP 4: Create structure + files
# ============================================
Write-Host ""
Write-Host "[4/5] Creating structure..." -ForegroundColor Yellow

# Directories
New-Item -ItemType Directory -Force -Path "$ProjectPath\brain\contexts" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\notes\daily-summaries" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\docs" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\agents" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\examples" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\scripts" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\.claude\skills" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\.claude\hooks" | Out-Null

# Placeholder files
New-Item -ItemType File -Force -Path "$ProjectPath\notes\daily-summaries\.gitkeep" | Out-Null
New-Item -ItemType File -Force -Path "$ProjectPath\docs\.gitkeep" | Out-Null

# ============================================
# CLAUDE.md
# ============================================
$claudeMd = @'
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
| `/setup` | First-time guided onboarding (run once) |
| `/start` | Reads context, checks last session, asks what you're working on |
| `/close` | Writes session report, updates context, cleans up completed items |
| `/brief` | Quick daily status overview (20 lines max) |
| `/plan` | Breaks a task into phases with verification criteria |
| `/review` | Code review checklist (security, simplicity, edge cases) |
| `/weekly` | Weekly retrospective — what shipped, patterns, next week |

Skills live in `.claude/skills/`. Add your own by dropping a markdown file there.

### Agent Auto-Loading

Agents can auto-load based on context:

| Agent | Trigger | File |
|-------|---------|------|
| CTO | Code, debug, API, infrastructure | `agents/cto.md` |
| Content Strategist | Blog, social, email, copy | `agents/content-strategist.md` |
| Growth Hacker | Outreach, funnel, experiments | `agents/growth-hacker.md` |

## Hooks

Hooks fire automatically on events. Configured in `.claude/settings.json`:

| Hook | Trigger | Purpose |
|------|---------|---------|
| `file-guard.py` | PreToolUse | Blocks writes to credential files, warns on CLAUDE.md edits |
| `agent-call-enforcer.py` | UserPromptSubmit | Forces reading agent files instead of improvising |
| `context-auto-save.py` | Stop | Reminds to update context when running /close |

## Agents

Agent definitions live in `agents/`. Say "call [agent-name]" to activate one.

### Agent Existence Protocol

When an agent is called:
1. Read the agent file from `agents/` **silently**
2. **BE** that agent immediately — no transition announcements
3. Respond as the agent, with its own voice
4. If the agent file doesn't exist, say so — **never improvise an agent from scratch**

### Available Agents

| Agent | Domain | File |
|-------|--------|------|
| CTO | Code, debug, architecture | `agents/cto.md` |
| Content Strategist | Blog, social, email | `agents/content-strategist.md` |
| Growth Hacker | Outreach, funnels, experiments | `agents/growth-hacker.md` |
| War Council | Multi-perspective decisions | `agents/war-council.md` |

### Agent Auto-Routing

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
cortex/
├── CLAUDE.md                    # Master instructions
├── PATTERNS.md                  # Recipes and proven patterns
├── brain/
│   ├── context.md               # Index (loads every session)
│   └── contexts/                # Area context (load on demand)
├── agents/                      # 4 agents
├── examples/                    # What it looks like in action
├── scripts/
│   ├── morning-brief.sh         # Automated daily brief (cron/launchd)
│   └── com.cortex.morning-brief.plist  # macOS launchd config
├── notes/daily-summaries/       # Session reports
├── docs/                        # Final documents
└── .claude/
    ├── skills/                  # 7 skills
    ├── hooks/                   # 3 enforcement scripts
    └── settings.json            # Hook config
```

## Output Style

- Markdown formatting, bullet points
- No emojis (unless requested)
- Get to the point — lead with the answer, not the reasoning
'@
$claudeMd | Out-File -FilePath "$ProjectPath\CLAUDE.md" -Encoding UTF8

Write-Host "  + CLAUDE.md" -ForegroundColor Green

# ============================================
# brain/context.md
# ============================================
$contextMd = @'
# Context Index

**Last Updated:** [DATE]

This is the main index. It loads every session. Keep it under 60 lines.
Detailed context lives in `brain/contexts/` — load only what's relevant.

---

## Who I Am

- **Name:** [Your name]
- **Role:** [What you do — e.g., "Solo founder", "Freelance developer"]
- **Company:** [Your company/project]

---

## Active Areas

| Area | Context File | Status |
|------|-------------|--------|
| Work | `contexts/work.md` | [Active/Paused] |
| Projects | `contexts/projects.md` | [Active/Paused] |
| Content | `contexts/content.md` | [Active/Paused] |

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
'@
$contextMd | Out-File -FilePath "$ProjectPath\brain\context.md" -Encoding UTF8

Write-Host "  + brain/context.md (index)" -ForegroundColor Green

# ============================================
# brain/contexts/
# ============================================
$workMd = @'
# Work Context

**Area:** Day job, clients, revenue, sales

---

## Active Deals / Clients

| Client | Status | Value | Next Step | Deadline |
|--------|--------|-------|-----------|----------|
| | | | | |

---

## Revenue

- **MRR:** [amount]
- **Target:** [amount]
- **Pipeline:** [amount]

---

## Notes

[Anything Claude needs to know about your work context]
'@
$workMd | Out-File -FilePath "$ProjectPath\brain\contexts\work.md" -Encoding UTF8

$projectsMd = @'
# Projects Context

**Area:** Active builds, products, side projects

---

## Active Projects

| Project | Stack | Status | Next Milestone |
|---------|-------|--------|----------------|
| | | | |

---

## Architecture Notes

[Key technical decisions, patterns, conventions]

---

## Blocked / Waiting

| What | Blocked By | Since |
|------|-----------|-------|
| | | |
'@
$projectsMd | Out-File -FilePath "$ProjectPath\brain\contexts\projects.md" -Encoding UTF8

$contentMd = @'
# Content Context

**Area:** Blog, social media, video, newsletter

---

## Publishing Schedule

| Day | Channel | Type |
|-----|---------|------|
| Mon | | |
| Wed | | |
| Fri | | |

---

## Content Pipeline

| Title | Status | Channel | Due |
|-------|--------|---------|-----|
| | Draft / Review / Ready / Published | | |

---

## Voice Notes

- **Tone:** [casual / professional / technical / conversational]
- **Never:** [things you don't want in your content]
- **Always:** [things that should be in every piece]
- **Length:** [preferred post length]
'@
$contentMd | Out-File -FilePath "$ProjectPath\brain\contexts\content.md" -Encoding UTF8

Write-Host "  + brain/contexts/ (3 modules)" -ForegroundColor Green

# ============================================
# Skills (7 skills)
# ============================================
$setupSkill = @'
# First-Time Setup

Guide the user through setting up their workspace. Run this once after cloning.

## Step 1: Welcome

Say:
"Welcome to Cortex. I'll help you set it up in about 5 minutes. I'll ask you a few questions, then fill in your context files."

## Step 2: Gather Info

Ask these questions ONE AT A TIME (wait for each answer):

1. "What's your name and what do you do?"
2. "What are you working on right now? Give me your top 3 priorities this week."
3. "What's your tech stack?"
4. "Do you have active clients or deals? If yes, list them briefly."
5. "Do you create content? If yes, what channels and how often?"

## Step 3: Fill In Context

Based on the answers, update:
1. `brain/context.md` — Fill in "Who I Am", "This Week", "Quick Reference"
2. `brain/contexts/work.md` — Fill in deals/clients table if they have any
3. `brain/contexts/projects.md` — Fill in projects table
4. `brain/contexts/content.md` — Fill in schedule and voice notes if they create content

## Step 4: Confirm

Show the user their filled-in `brain/context.md` and ask:
"Does this look right? Anything to add or change?"

## Step 5: First Commit

After user confirms, suggest:
```
git add brain/ CLAUDE.md && git commit -m "Initial context setup"
```

## Rules

- Ask questions one at a time
- Use their exact words — don't rephrase into corporate speak
- If they say "I don't have clients" or "I don't create content", mark those areas as "Paused"
- Keep context.md under 60 lines
'@
$setupSkill | Out-File -FilePath "$ProjectPath\.claude\skills\setup.md" -Encoding UTF8

$startSkill = @'
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
| Anything else | Ask: "Is this work, building, or content?" |

**Never load all context files at once.**

## Step 5: Work
Proceed with the task. You now have the right context loaded.
'@
$startSkill | Out-File -FilePath "$ProjectPath\.claude\skills\start.md" -Encoding UTF8

$closeSkill = @'
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
'@
$closeSkill | Out-File -FilePath "$ProjectPath\.claude\skills\close.md" -Encoding UTF8

$briefSkill = @'
# Daily Brief

Generate a quick status overview:

## Step 1: Load Context
1. Read `brain/context.md`
2. Read the latest `notes/daily-summaries/closing-*.md`

## Step 2: Generate Brief

## Brief — [Today's Date]

**Focus:** [Main area from context]

### Yesterday
- [Key completions from last closing report, or "No prior sessions" if none exist]

### Today's Priorities
1. [Most urgent from "This Week"]
2. [Second priority]
3. [Third priority]

### Blockers
- [Anything stuck or waiting, or "None"]

## Rules
- Max 20 lines total. Glance, not a report.
- If no closing report exists, skip "Yesterday"
- Don't load area context files — brief uses index only
- If no numerical data in context, omit numbers rather than guessing
'@
$briefSkill | Out-File -FilePath "$ProjectPath\.claude\skills\brief.md" -Encoding UTF8

$planSkill = @'
# Plan

Create a structured plan for a task:

## Step 1: Understand
- What is the desired outcome?
- What do we know? What don't we know?

## Step 2: Break Down

Split into phases (max 5):

### Phase N: [Name]
**Goal:** [One sentence]
**Steps:**
1. [Concrete action]
2. [Concrete action]
**Verify:** [How to know it's done]

## Step 3: Present
Ask: **"Does this look right? Should I start with Phase 1?"**

## Rules
- Max 5 phases. More = task too big, split it.
- Each step = concrete action, not "figure out how to..."
- If the task fits in 3 steps or fewer, skip formal phases and list steps inline
- Don't execute until user approves
'@
$planSkill | Out-File -FilePath "$ProjectPath\.claude\skills\plan.md" -Encoding UTF8

$reviewSkill = @'
# Code Review

## Step 1: Identify Changes
Look at modified files in this session (or files the user points to).

## Step 2: Review Checklist
- [ ] **Security** — No hardcoded secrets, no injection, inputs validated at boundaries
- [ ] **Simplicity** — Could this be simpler? Dead code? Unnecessary abstraction?
- [ ] **Edge cases** — Empty input? Null? Very large data?
- [ ] **Naming** — Do names explain what they do?
- [ ] **Error handling** — Handled at boundaries (user input, external APIs)?

For non-code files (markdown, JSON, shell scripts): focus on Naming and Simplicity.

## Step 3: Output

## Review: [filename]
**Verdict:** LGTM / Needs Changes / Blocking Issues

### Issues
1. [LINE] [SEVERITY] — Description + fix

### Good
- [At least one positive observation]

## Rules
- Be specific. Not "could be better" but "Line 42: SQL injection — use parameterized queries"
- Bugs and security first, style last
- If everything looks good, say so
'@
$reviewSkill | Out-File -FilePath "$ProjectPath\.claude\skills\review.md" -Encoding UTF8

$weeklySkill = @'
# Weekly Review

Generate a weekly retrospective from your closing reports.

## Step 1: Gather Data

Read all `notes/daily-summaries/closing-*.md` files from the past 7 days.
Also read `brain/context.md` for current priorities.

If no closing reports exist, say: "No sessions recorded this week. Run /close at the end of each session to start tracking."

## Step 2: Generate Review

## Week Review — [Date Range]

### Shipped
- [Completed items across all sessions this week]

### Decided
- [Key decisions made]

### Blocked
- [Things stuck or waiting]

### Numbers
- Sessions: [count]
- Areas touched: [list]

### Next Week
1. [Top priority]
2. [Second priority]
3. [Third priority]

### Patterns
- [Recurring themes — time allocation, blockers, drift from priorities]

## Step 3: Update Context

Ask: "Should I update brain/context.md with next week's priorities?"

## Rules
- "Patterns" is the most valuable section — be honest about what didn't get done
- Max 30 lines total
'@
$weeklySkill | Out-File -FilePath "$ProjectPath\.claude\skills\weekly.md" -Encoding UTF8

Write-Host "  + .claude/skills/ (7 skills)" -ForegroundColor Green

# ============================================
# Hooks (3 hooks)
# ============================================
$fileGuardHook = @'
#!/usr/bin/env python3
"""
Hook: File Guard
Trigger: PreToolUse
Purpose: Prevents writing to credential files, warns on CLAUDE.md edits.
"""
import json
import sys
import os

def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({"continue": True}))
        return

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})

    if tool_name not in ("Write", "Edit", "MultiEdit"):
        print(json.dumps({"continue": True}))
        return

    if not isinstance(tool_input, dict):
        print(json.dumps({"continue": True}))
        return

    file_path = tool_input.get("file_path", "")
    basename = os.path.basename(file_path)

    blocked_extensions = {".pem", ".key"}
    blocked_names = {".env", ".env.local", ".env.production", ".env.staging", "MASTER.env", "credentials.json"}

    _, ext = os.path.splitext(basename)
    if ext in blocked_extensions or basename in blocked_names:
        print(json.dumps({"continue": False, "message": f"BLOCKED: Cannot write to '{basename}' -- credential file."}))
        return

    if ".credentials" in file_path.replace("\\", "/").split("/"):
        print(json.dumps({"continue": False, "message": "BLOCKED: Cannot write to .credentials/ directory."}))
        return

    if basename == "CLAUDE.md":
        print(json.dumps({"continue": True, "message": "NOTE: Editing CLAUDE.md (master instructions). Make sure this is intentional."}))
        return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
'@
$fileGuardHook | Out-File -FilePath "$ProjectPath\.claude\hooks\file-guard.py" -Encoding UTF8

$agentCallHook = @'
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
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({"continue": True}))
        return

    message = hook_input.get("message", "").lower()

    patterns = [
        r"call\s+([\w-]+)",
        r"chiama\s+([\w-]+)",
        r"use\s+([\w-]+)\s+agent",
        r"load\s+([\w-]+)\s+agent",
        r"switch\s+to\s+([\w-]+)",
    ]

    stop_words = {"the", "a", "an", "my", "our", "this", "that", "it", "me", "you", "us", "back", "him", "her", "them"}

    for pattern in patterns:
        match = re.search(pattern, message)
        if match:
            agent_name = match.group(1)
            if agent_name in stop_words:
                continue
            print(json.dumps({"continue": True, "message": f"REQUIRED: Read agents/{agent_name}.md before responding. Do NOT improvise agent behavior."}))
            return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
'@
$agentCallHook | Out-File -FilePath "$ProjectPath\.claude\hooks\agent-call-enforcer.py" -Encoding UTF8

$contextAutoSaveHook = @'
#!/usr/bin/env python3
"""
Hook: Context Auto-Save Reminder
Trigger: Stop
Purpose: Reminds to update context when running /close.
Only fires when /close is detected.
"""
import json
import sys

def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({"continue": True}))
        return

    should_remind = False
    close_indicators = ["/close", "session close", "close session"]

    message = hook_input.get("message", "")
    if isinstance(message, str) and any(ind in message.lower() for ind in close_indicators):
        should_remind = True

    transcript = hook_input.get("transcript_so_far", hook_input.get("transcript", ""))
    if isinstance(transcript, str) and any(ind in transcript.lower() for ind in close_indicators):
        should_remind = True
    elif isinstance(transcript, list):
        for entry in transcript:
            text = entry if isinstance(entry, str) else (entry.get("content", "") if isinstance(entry, dict) else str(entry))
            if any(ind in text.lower() for ind in close_indicators):
                should_remind = True
                break

    if should_remind:
        print(json.dumps({"continue": True, "message": "REMINDER: Update brain/context.md -- remove completed items, add new priorities."}))
    else:
        print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
'@
$contextAutoSaveHook | Out-File -FilePath "$ProjectPath\.claude\hooks\context-auto-save.py" -Encoding UTF8

Write-Host "  + .claude/hooks/ (3 hooks)" -ForegroundColor Green

# ============================================
# settings.json (3 hooks wired)
# ============================================
$settingsJson = @'
{
  "permissions": {
    "allow": []
  },
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 .claude/hooks/file-guard.py"
          }
        ]
      }
    ],
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
'@
$settingsJson | Out-File -FilePath "$ProjectPath\.claude\settings.json" -Encoding UTF8

Write-Host "  + .claude/settings.json" -ForegroundColor Green

# ============================================
# Agents (4 agents)
# ============================================
$ctoAgent = @'
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

---

**When to use this agent:** Any task involving code, debugging, integrations, APIs, infrastructure, or architecture decisions.
'@
$ctoAgent | Out-File -FilePath "$ProjectPath\agents\cto.md" -Encoding UTF8

$contentAgent = @'
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

---

**When to use this agent:** Blog posts, LinkedIn posts, Twitter threads, newsletters, email copy, content strategy, and editorial planning.
'@
$contentAgent | Out-File -FilePath "$ProjectPath\agents\content-strategist.md" -Encoding UTF8

$growthAgent = @'
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

---

**When to use this agent:** Acquisition strategy, outreach campaigns, funnel optimization, experiment design, and pipeline building.
'@
$growthAgent | Out-File -FilePath "$ProjectPath\agents\growth-hacker.md" -Encoding UTF8

$warCouncilAgent = @'
# War Council Agent

## Identity

You are the **War Council** — a structured deliberation framework that attacks a decision from multiple angles before recommending action. You're not one voice. You're three.

## Personality

- Structured and methodical. Every decision gets the same rigorous process.
- No consensus-seeking. Disagreement is the point.
- Output is a recommendation, not a committee report.
- Fast. The whole council runs in one response.

## Core Protocol

When the user brings a decision, problem, or strategic question:

### Round 1: Three Perspectives

**The Operator** — Thinks about execution, speed, and what's practical right now.
- What's the fastest path to results?
- What are the real constraints (time, money, energy)?

**The Strategist** — Thinks about positioning, long-term leverage, and second-order effects.
- What does this look like in 6 months?
- What doors does this open or close?

**The Critic** — Finds the holes. Assumes the plan will fail and asks why.
- What's the most likely way this fails?
- What assumption, if wrong, kills the whole plan?

### Round 2: Synthesis

```
VERDICT: [One clear recommendation]
CONFIDENCE: [High / Medium / Low]
KEY RISK: [The one thing that could make this wrong]
NEXT ACTION: [The first concrete step]
```

## Decision Rules

| Situation | Action |
|-----------|--------|
| All 3 agree | High confidence. Move fast. |
| 2 agree, 1 dissents | Medium confidence. Note the dissent as a risk. |
| All 3 disagree | Low confidence. Need more information. |
| User says "quick council" | One-line reasoning per perspective, straight to verdict. |

## Hard Limits

1. **Never** give a wishy-washy "it depends" without a concrete recommendation
2. **Never** let the Critic win by default — skepticism without alternatives is useless
3. **Always** end with a single clear action, not a list of options
4. **Always** name the key assumption that could invalidate the recommendation

---

**When to use this agent:** Pricing decisions, build vs buy, whether to take on a client, channel/strategy pivots, any decision where you keep going back and forth.
'@
$warCouncilAgent | Out-File -FilePath "$ProjectPath\agents\war-council.md" -Encoding UTF8

Write-Host "  + agents/ (4 agents: cto, content-strategist, growth-hacker, war-council)" -ForegroundColor Green

# ============================================
# Examples (3 files)
# ============================================
$exampleContext = @'
# Context Index — Example (Filled In)

> This is what context.md looks like after 2 weeks of use.

**Last Updated:** 06/03/2026

---

## Who I Am

- **Name:** Alex Chen
- **Role:** Solo founder + freelance growth consultant
- **Company:** LaunchKit (dev tools SaaS) + consulting clients

---

## Active Areas

| Area | Context File | Status |
|------|-------------|--------|
| Work | `contexts/work.md` | Active |
| Projects | `contexts/projects.md` | Active |
| Content | `contexts/content.md` | Active |

---

## This Week

- [ ] Ship onboarding email sequence (3 emails, Resend)
- [ ] Acme Corp: send proposal v2 (adjusted scope)
- [x] Fix auth bug (JWT expiry — deployed Tue)
- [ ] LinkedIn post: "What I learned building in public for 30 days"

---

## Quick Reference

| Key | Value |
|-----|-------|
| Main tool | Claude Code (Max plan) |
| Stack | Next.js, Supabase, Vercel, Resend |
| CRM | HubSpot (free tier) |
| Domain | launchkit.dev |
| MRR | $3,200 |
| Target | $5,000 by end of Q1 |
'@
$exampleContext | Out-File -FilePath "$ProjectPath\examples\context-filled.md" -Encoding UTF8

$exampleClosing = @'
# Closing 06/03/2026 — Example

> This is what a closing report looks like. /close generates these automatically.

## TL;DR
- **Done**: Fixed onboarding email sequence. Auth bug patched. Acme proposal v2 drafted.
- **Pending**: Acme proposal needs pricing review. LinkedIn post half-written.
- **Next**: Send Acme proposal tomorrow AM. Finish LinkedIn post.

## Session 1: Email + Auth Fix

Fixed two bugs in the onboarding flow:
1. Welcome email not sending — Resend API key expired, rotated and updated on Vercel
2. Users logged out after 1 hour — JWT expiry was 3600s, changed to 604800s (7 days)

## Session 2: Acme Proposal

Drafted v2. Reduced scope from 6 to 3 months. Added milestone billing. Removed social media management (they have in-house).

## Files Created/Modified

| File | Action |
|------|--------|
| `src/lib/auth.ts` | Modified — JWT expiry fix |
| `src/emails/welcome.tsx` | Modified — Resend API fix |
| `docs/proposals/acme-v2.md` | Created — revised proposal |

## Key Decisions

| Decision | Why |
|----------|-----|
| JWT 7 days not 30 | Balance UX and security |
| Milestone billing for Acme | They burned on a retainer before |

---
**Session Status**: Completed
'@
$exampleClosing | Out-File -FilePath "$ProjectPath\examples\closing-report.md" -Encoding UTF8

$exampleWarCouncil = @'
# War Council Output — Example

> This is what you get when you say "call war-council"

---

## Question: Should I launch a free tier for LaunchKit?

### The Operator

Launch it. 3 days to implement. Limit to 1 project, no team features, no API.
Risk is low — free users cost nothing on Supabase free tier.

**Recommendation:** Ship this week. Cap it hard.

### The Strategist

Wait. Free tiers attract "free forever" users, not buyers. At $3.2K MRR you don't have a conversion problem — you have a traffic problem. 2% of 500 visitors = 10 signups. Fix traffic first.

**Recommendation:** 14-day free trial instead. Creates urgency.

### The Critic

Both assume the product is ready for more users. Onboarding just got fixed this week — tested with real users? Who handles free user support? You're solo.

**Recommendation:** Waitlist 2 weeks. 100+ signups = green light.

---

## VERDICT: 14-day free trial (not free tier)

**CONFIDENCE:** Medium — the Critic's readiness point is valid.

**KEY RISK:** If onboarding is still buggy, trial users churn.

**NEXT ACTION:** Test onboarding yourself as a new user. Fix friction. Launch trial Monday.
'@
$exampleWarCouncil | Out-File -FilePath "$ProjectPath\examples\war-council-output.md" -Encoding UTF8

Write-Host "  + examples/ (3 examples)" -ForegroundColor Green

# ============================================
# Scripts (morning brief)
# ============================================
$morningBrief = @'
#!/bin/bash

# Morning Brief — Automated Daily Status
# Usage: ./scripts/morning-brief.sh
# Cron:  30 8 * * * cd /path/to/cortex && ./scripts/morning-brief.sh

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORKSPACE_DIR"

if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code not found. Install with: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

if [ ! -f "brain/context.md" ]; then
    echo "Error: brain/context.md not found. Run /setup first."
    exit 1
fi

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "Error: ANTHROPIC_API_KEY not set. Non-interactive mode requires an API key."
    echo "Get one at https://console.anthropic.com"
    exit 1
fi

TODAY=$(date '+%Y%m%d')
BRIEF_FILE="notes/daily-summaries/brief-${TODAY}.md"

BRIEF=$(claude -p "Read brain/context.md and the latest file in notes/daily-summaries/ (if any exist). Generate a morning brief: Focus, Yesterday (or 'First brief'), Today's top 3 priorities, Blockers. Max 20 lines." 2>&1) || {
    echo "Error: Claude failed to generate brief"
    echo "$BRIEF"
    exit 1
}

echo "$BRIEF"

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
'@
$morningBrief | Out-File -FilePath "$ProjectPath\scripts\morning-brief.sh" -Encoding UTF8

Write-Host "  + scripts/ (morning-brief)" -ForegroundColor Green

# ============================================
# PATTERNS.md
# ============================================
$patternsMd = @'
# Patterns & Recipes

Proven patterns for getting the most out of your Claude Code workspace.

---

## Context Patterns

### The 60-Line Rule

Your `brain/context.md` should never exceed ~60 lines. Move details to area files.

### Context Layering

```
brain/context.md          <- Always loaded (~60 lines)
brain/contexts/work.md    <- Loaded for clients/sales
brain/contexts/projects.md <- Loaded for building/coding
brain/contexts/content.md  <- Loaded for content creation
```

### The Snapshot Principle

Context files describe NOW. History lives in `notes/daily-summaries/`.

---

## Agent Patterns

### Agent vs Protocol

Ask: "Does this need its own personality that would conflict with another agent?"
- Yes -> It's an agent (separate file in `agents/`)
- No -> It's a protocol (a skill or section in an existing agent)

### The War Council Pattern

For important decisions, use three perspectives in one response:
1. **The Operator** — What's fastest?
2. **The Strategist** — What's the long-term play?
3. **The Critic** — How does this fail?

Then synthesize into one recommendation. See `agents/war-council.md`.

---

## Skill Patterns

### Skill Structure

Every skill should have: Steps, Output format, Rules.

### Auto-Loading

Add routing rules to CLAUDE.md so agents load automatically for matching tasks.

---

## Hook Patterns

### Hook Types

| Trigger | Fires When | Use For |
|---------|-----------|---------|
| `PreToolUse` | Before any tool runs | Block dangerous operations |
| `PostToolUse` | After any tool runs | Log actions |
| `UserPromptSubmit` | User sends a message | Inject context, enforce protocols |
| `Stop` | Assistant finishes responding | Reminders |

### Hook Template

```python
#!/usr/bin/env python3
import json, sys

def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except Exception:
        print(json.dumps({"continue": True}))
        return

    # Your logic here
    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
```

---

## Session Patterns

### The Session Loop

```
/start -> understand context -> do work -> /close
```

### Multi-Session Days

`/close` appends to the same daily file as `## Session N: [Topic]`.

### The Weekly Rhythm

```
Monday    -> /start + /brief (orient)
Daily     -> /start -> work -> /close
Friday    -> /close + /weekly (retrospective)
```

---

## Common Mistakes

1. **Loading everything** — Only load the context file for what you're doing
2. **Context as history** — Context is current state, not a changelog
3. **Too many agents** — Start with 3-4, add only when you feel a real gap
4. **Skills without rules** — "Write a blog post" is useless. Add frameworks, word limits, constraints.
5. **Hooks that block everything** — Start with warnings, then add blocks

---

## Scaling Up

### MCP Integrations

```json
{
  "mcpServers": {
    "your-tool": {
      "command": "npx",
      "args": ["-y", "your-mcp-server"]
    }
  }
}
```

### Local AI (Ollama)

```bash
brew install ollama
ollama pull mistral:7b-instruct
```

### Multiple Projects

Each project gets its own context file in `brain/contexts/` and folder in `projects/`.

---

*These patterns come from running a real business with this system — 36 agents, 9 projects, 160+ tasks shipped in the author's own instance. This template ships with 4 agents and 7 skills to get you started.*
'@
$patternsMd | Out-File -FilePath "$ProjectPath\PATTERNS.md" -Encoding UTF8

Write-Host "  + PATTERNS.md" -ForegroundColor Green

# ============================================
# LICENSE
# ============================================
$licenseTxt = @'
MIT License

Copyright (c) 2026 Matteo Lombardi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'@
$licenseTxt | Out-File -FilePath "$ProjectPath\LICENSE" -Encoding UTF8

Write-Host "  + LICENSE" -ForegroundColor Green

# ============================================
# .gitignore
# ============================================
$gitignore = @'
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
*.p12
*.pfx
id_rsa
id_ed25519
.env
.env.*
MASTER.env
credentials.json

# Claude Code local settings
.claude/settings.local.json

# Large data files (uncomment if needed)
# data/*.csv
# data/*.xlsx

# Temporary files
*.tmp
*.temp
'@
$gitignore | Out-File -FilePath "$ProjectPath\.gitignore" -Encoding UTF8

Write-Host "  + .gitignore" -ForegroundColor Green

# ============================================
# STEP 5: Initialize git
# ============================================
Write-Host ""
Write-Host "[5/5] Initializing git..." -ForegroundColor Yellow

$gitExists = Get-Command git -ErrorAction SilentlyContinue
if ($gitExists) {
    Set-Location $ProjectPath
    if (Test-Path ".git") {
        Write-Host "  + Git already initialized" -ForegroundColor Green
    } else {
        git init --quiet
        git add -A
        git commit -m "Initial setup -- Cortex" --quiet
        Write-Host "  + Git initialized" -ForegroundColor Green
    }
} else {
    Write-Host "  ! Git not found — skipping. Install from https://git-scm.com" -ForegroundColor Yellow
}

# ============================================
# DONE!
# ============================================
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   CORTEX SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your workspace is ready:" -ForegroundColor White
Write-Host "  $ProjectPath" -ForegroundColor Blue
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. cd $ProjectPath"
Write-Host "  2. claude"
Write-Host "  3. /setup     (guided onboarding -- fills in your context)"
Write-Host ""
Write-Host "Available agents:" -ForegroundColor Yellow
Write-Host "  call cto               -- Technical decisions, debugging"
Write-Host "  call content-strategist -- Content creation, planning"
Write-Host "  call growth-hacker      -- Growth experiments, outreach"
Write-Host "  call war-council        -- Multi-perspective decisions"
Write-Host ""
Write-Host "Available skills:" -ForegroundColor Yellow
Write-Host "  /setup  /start  /close  /brief  /plan  /review  /weekly"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Repo:   github.com/matteo-stratega/claude-cortex" -ForegroundColor Blue
Write-Host "  Author: Matteo Lombardi" -ForegroundColor Blue
Write-Host ""

$openFolder = Read-Host "Open folder now? (y/n)"
if ($openFolder -eq "y" -or $openFolder -eq "Y") {
    explorer $ProjectPath
}

Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
