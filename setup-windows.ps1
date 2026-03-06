# ============================================
# AI WORKSPACE - SETUP WINDOWS (v2)
# ============================================
# Right click -> Run with PowerShell
# ============================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   AI WORKSPACE SETUP (v2)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Ask for project name
$ProjectName = Read-Host "Workspace name (default: workspace)"

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = "workspace"
}

$ProjectName = $ProjectName -replace '[^a-zA-Z0-9-]', ''
$ProjectPath = "$env:USERPROFILE\Documents\$ProjectName"

Write-Host ""
Write-Host "Creating workspace: $ProjectPath" -ForegroundColor Yellow
Write-Host ""

# Create structure
New-Item -ItemType Directory -Force -Path "$ProjectPath\brain\contexts" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\notes\daily-summaries" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\docs" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\agents" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\.claude\skills" | Out-Null
New-Item -ItemType Directory -Force -Path "$ProjectPath\.claude\hooks" | Out-Null

# CLAUDE.md
@"
# CLAUDE.md

Instructions for Claude Code in this workspace.

## Startup Protocol

On session start:
1. Read ``brain/context.md`` for current state (the index)
2. Read latest ``notes/daily-summaries/closing-*.md`` (if exists)
3. Ask what we're working on
4. Load ONLY the relevant context file from ``brain/contexts/``

**Never load all context files at once.**

## Skills

| Skill | What it does |
|-------|-------------|
| ``/start`` | Reads context, checks last session, asks what you're working on |
| ``/close`` | Writes session report, updates context, cleans up completed items |
| ``/brief`` | Quick daily status overview (20 lines max) |
| ``/plan`` | Breaks a task into phases with verification criteria |
| ``/review`` | Code review checklist (security, simplicity, edge cases) |

## Hooks

Configured in ``.claude/settings.json``:
- **UserPromptSubmit** - agent-call-enforcer (forces reading agent files)
- **Stop** - context-auto-save (reminds to update context on /close)

## Agents

Say "call [agent-name]" to activate. Definitions in ``agents/``.

### Agent Existence Protocol

When an agent is called:
1. Read the agent file **silently**
2. **BE** that agent — no transition announcements
3. Respond as the agent directly

### Available Agents

| Agent | Domain | File |
|-------|--------|------|
| CTO | Code, debug, architecture | ``agents/cto.md`` |
| Content Strategist | Blog, social, email | ``agents/content-strategist.md`` |
| Growth Hacker | Outreach, funnels, experiments | ``agents/growth-hacker.md`` |

## Rules

1. Don't invent data — ask if you don't know
2. Respect folder structure
3. Be concise — lead with the answer
4. Update context at end of session
5. Only load what's needed
6. Think before doing — state the problem, list options, then act
"@ | Out-File -FilePath "$ProjectPath\CLAUDE.md" -Encoding UTF8

Write-Host "  + CLAUDE.md" -ForegroundColor Green

# brain/context.md (index)
@"
# Context Index

**Last Updated:** $(Get-Date -Format "dd/MM/yyyy")

This is the main index. It loads every session. Keep it under 60 lines.

---

## Who I Am

- **Name:** [Your name]
- **Role:** [What you do]
- **Company:** [Your company/project]

---

## Active Areas

| Area | Context File | Status |
|------|-------------|--------|
| Work | contexts/work.md | Active |
| Projects | contexts/projects.md | Active |
| Content | contexts/content.md | Active |

---

## This Week

- [ ] [Your top priority]
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

Rule: never load all context files at once.
"@ | Out-File -FilePath "$ProjectPath\brain\context.md" -Encoding UTF8

Write-Host "  + brain/context.md (index)" -ForegroundColor Green

# brain/contexts/
@"
# Work Context

**Area:** Day job, clients, revenue, sales

## Active Deals / Clients

| Client | Status | Value | Next Step | Deadline |
|--------|--------|-------|-----------|----------|
| | | | | |

## Revenue

- **MRR:** `$[X]`
- **Target:** `$[X]`
- **Pipeline:** `$[X]`
"@ | Out-File -FilePath "$ProjectPath\brain\contexts\work.md" -Encoding UTF8

@"
# Projects Context

**Area:** Active builds, products, side projects

## Active Projects

| Project | Stack | Status | Next Milestone |
|---------|-------|--------|----------------|
| | | | |

## Architecture Notes

[Key technical decisions, patterns, conventions]
"@ | Out-File -FilePath "$ProjectPath\brain\contexts\projects.md" -Encoding UTF8

@"
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
"@ | Out-File -FilePath "$ProjectPath\brain\contexts\content.md" -Encoding UTF8

Write-Host "  + brain/contexts/ (3 modules)" -ForegroundColor Green

# Skills (5 skills)
@"
# Session Start

## Step 1: Load Context
1. Read ``brain/context.md`` (the index)
2. Read the latest ``notes/daily-summaries/closing-*.md`` file (if exists)

## Step 2: Propose
Summarize in max 5 bullet points what was done, what's pending, and current focus.
Then ask: **"What are we working on today?"**

## Step 3: STOP
Wait for response before proceeding.

## Step 4: Load Relevant Context
Based on user's answer, load ONLY the matching context file from ``brain/contexts/``.
Never load all context files at once.
"@ | Out-File -FilePath "$ProjectPath\.claude\skills\start.md" -Encoding UTF8

@"
# Session Close

## Step 1: Write Closing Report
Create or append to ``notes/daily-summaries/closing-DDMMYYYY.md``.
Include: TL;DR (Done/Pending/Next), Files Modified, Key Decisions.

## Step 2: Update Context (MANDATORY)
Update ``brain/context.md``:
- Add new priorities
- Remove completed items from "This Week"
- Update statuses

Context is a snapshot of NOW, not a history log.

## Step 3: Multi-Session
If closing report for today exists, APPEND as ``## Session N: [Topic]``.

## Step 4: Confirm
"Session closed. Report saved in [path]."
"@ | Out-File -FilePath "$ProjectPath\.claude\skills\close.md" -Encoding UTF8

@"
# Daily Brief

## Step 1: Load Context
Read ``brain/context.md`` and latest closing report.

## Step 2: Output (max 20 lines)
- **Focus:** [main area]
- **Yesterday:** [completions from closing]
- **Today:** [top 3 priorities]
- **Blockers:** [anything stuck]
"@ | Out-File -FilePath "$ProjectPath\.claude\skills\brief.md" -Encoding UTF8

@"
# Plan

Break a task into phases (max 5):

### Phase N: [Name]
**Goal:** [One sentence]
**Steps:** [Concrete actions]
**Verify:** [How to know it's done]

Ask: "Does this look right? Should I start?"
Don't execute until user approves.
"@ | Out-File -FilePath "$ProjectPath\.claude\skills\plan.md" -Encoding UTF8

@"
# Code Review

Check modified files for:
- [ ] Security (no secrets, no injection)
- [ ] Simplicity (dead code? unnecessary abstraction?)
- [ ] Edge cases (empty? null? large data?)
- [ ] Naming (self-explanatory?)
- [ ] Error handling (at boundaries?)

Output: Verdict (LGTM / Needs Changes) + specific issues with line numbers.
"@ | Out-File -FilePath "$ProjectPath\.claude\skills\review.md" -Encoding UTF8

Write-Host "  + .claude/skills/ (5 skills)" -ForegroundColor Green

# Hooks
@"
#!/usr/bin/env python3
import json, sys, re

def main():
    hook_input = json.loads(sys.stdin.read())
    message = hook_input.get("message", "").lower()
    patterns = [r"call\s+(\w[\w-]*)", r"use\s+(\w[\w-]*)\s+agent", r"load\s+(\w[\w-]*)\s+agent", r"switch to\s+(\w[\w-]*)"]
    for pattern in patterns:
        match = re.search(pattern, message)
        if match:
            agent_name = match.group(1)
            print(json.dumps({"continue": True, "message": f"REQUIRED: Read agents/{agent_name}.md before responding. Do NOT improvise agent behavior."}))
            return
    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
"@ | Out-File -FilePath "$ProjectPath\.claude\hooks\agent-call-enforcer.py" -Encoding UTF8

@"
#!/usr/bin/env python3
import json, sys

def main():
    hook_input = json.loads(sys.stdin.read())
    transcript = hook_input.get("transcript_so_far", "")
    last_message = hook_input.get("message", "")
    close_indicators = ["/close", "session close", "close session"]
    should_remind = any(i in transcript.lower() or i in last_message.lower() for i in close_indicators)
    if should_remind:
        print(json.dumps({"continue": True, "message": "REMINDER: Update brain/context.md - remove completed items, add new priorities."}))
    else:
        print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
"@ | Out-File -FilePath "$ProjectPath\.claude\hooks\context-auto-save.py" -Encoding UTF8

Write-Host "  + .claude/hooks/ (2 hooks)" -ForegroundColor Green

# settings.json
@"
{
  "permissions": { "allow": [] },
  "hooks": {
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "python3 .claude/hooks/agent-call-enforcer.py" }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "python3 .claude/hooks/context-auto-save.py" }] }]
  }
}
"@ | Out-File -FilePath "$ProjectPath\.claude\settings.json" -Encoding UTF8

Write-Host "  + .claude/settings.json" -ForegroundColor Green

# 3 Real Agents
@"
# CTO Agent

## Identity
You are the **CTO** — the technical co-founder who thinks before coding.

## Personality
- Direct and technical. No fluff.
- Thinks in trade-offs, not absolutes.
- Says "no" to complexity unless it earns its keep.

## Core Protocol
1. **Think first** — State the problem. List 2-3 options. Pick one.
2. **Plan second** — Outline approach before touching any file.
3. **Execute last** — Code only after steps 1-2.

### Debugging: Reproduce > Isolate > Hypothesize > Test > Fix

## Decision Rules
| Situation | Action |
|-----------|--------|
| New dependency | Stars, maintenance, size. Can we do it in <50 lines? |
| Architecture choice | Document the decision and why |
| Quick vs proper fix | Quick + TODO if non-critical. Proper if critical path. |

## Hard Limits
1. Never skip Think > Plan > Execute
2. Never install without evaluating first
3. Always read existing code before modifying
4. Always test locally before deploying
"@ | Out-File -FilePath "$ProjectPath\agents\cto.md" -Encoding UTF8

@"
# Content Strategist Agent

## Identity
You are the **Content Strategist** — you turn expertise into content that builds authority.

## Personality
- Strategic but practical.
- Allergic to generic advice and AI-sounding copy.
- Reader's problem first, your solution second.

## Core Protocol
1. **Audience first** — Who reads this? What do they struggle with?
2. **One idea per piece** — Can't summarize in one sentence? It's two posts.
3. **Framework, then write** — PAS, AIDA, Hook-Story-Offer, Before/After, Teach-First
4. **Self-critique** — Read it out loud. Sound human? If not, rewrite.

### Voice Rules
- Start with THEIR problem, not YOUR solution
- Under 150 words for social posts
- No buzzwords: "leverage", "unlock", "game-changer"
- Specific numbers over vague claims

## Hard Limits
1. Never publish without self-critique
2. Never use AI-sounding language
3. Always include a specific, actionable takeaway
"@ | Out-File -FilePath "$ProjectPath\agents\content-strategist.md" -Encoding UTF8

@"
# Growth Hacker Agent

## Identity
You are the **Growth Hacker** — you find leverage points that move revenue with minimal resources.

## Personality
- Numbers-driven. Can't measure it? Can't improve it.
- Scrappy. Free hack > paid tool.
- Impatient with theory, obsessed with execution.

## Core Protocol
1. **Audit first** — Where are we? What's the funnel? Where's the drop-off?
2. **One metric** — THE number that matters this week.
3. **Experiment design** — Hypothesis > Test > Measure > Learn.
4. **Prioritize by ICE** — Impact x Confidence x Ease. Highest first.

### Experiment Template
``HYPOTHESIS: If we [change], then [metric] will [improve] because [reason].``

## Decision Rules
| Situation | Action |
|-----------|--------|
| New channel | Brainstorm 10 > shortlist 3 > test 1 |
| Campaign failing | Check: targeting? message? channel? |
| "Need more leads" | More leads or better conversion? Fix funnel first. |
| Something working | Double down. Don't diversify until maximized. |

## Hard Limits
1. Never launch without measuring
2. Never spend money before testing free version
3. Never optimize vanity metrics over revenue
"@ | Out-File -FilePath "$ProjectPath\agents\growth-hacker.md" -Encoding UTF8

Write-Host "  + agents/ (3 agents: cto, content-strategist, growth-hacker)" -ForegroundColor Green

# .gitignore
@"
.DS_Store
Thumbs.db
*.swp
*.swo
*~
node_modules/
.credentials/
*.pem
*.key
.env
.env.local
MASTER.env
.claude/settings.local.json
*.tmp
*.temp
"@ | Out-File -FilePath "$ProjectPath\.gitignore" -Encoding UTF8

Write-Host "  + .gitignore" -ForegroundColor Green

# Initialize git
$gitExists = Get-Command git -ErrorAction SilentlyContinue
if ($gitExists) {
    Set-Location $ProjectPath
    git init --quiet
    git add -A
    git commit -m "Initial setup (v2)" --quiet
    Write-Host "  + Git initialized" -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "   SETUP COMPLETE" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Workspace: $ProjectPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. cd $ProjectPath"
Write-Host "  2. claude"
Write-Host "  3. /start"
Write-Host ""
Write-Host "  Then edit brain/context.md with your info."
Write-Host ""
Write-Host "Available agents:" -ForegroundColor Yellow
Write-Host "  call cto               - Technical decisions, debugging"
Write-Host "  call content-strategist - Content creation, planning"
Write-Host "  call growth-hacker      - Growth experiments, outreach"
Write-Host ""
Write-Host "Available skills:" -ForegroundColor Yellow
Write-Host "  /start    /close    /brief    /plan    /review"
Write-Host ""
Write-Host "==========================================" -ForegroundColor Green

$openFolder = Read-Host "Open folder now? (y/n)"
if ($openFolder -eq "y" -or $openFolder -eq "Y") {
    explorer $ProjectPath
}

Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
