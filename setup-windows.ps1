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

- ``/start`` - Start work session
- ``/close`` - End session with report

## Hooks

Configured in ``.claude/settings.json``:
- **UserPromptSubmit** - agent-call-enforcer (forces reading agent files)
- **Stop** - context-auto-save (reminds to update context on close)

## Agents

Say "call [agent]" to activate. Definitions in ``agents/``.

## Rules

1. Don't invent data
2. Respect folder structure
3. Be concise
4. Update context at end of session
5. Only load what's needed
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

- [ ] Priority 1
- [ ] Priority 2
- [ ] Priority 3

---

Rule: never load all context files at once.
"@ | Out-File -FilePath "$ProjectPath\brain\context.md" -Encoding UTF8

Write-Host "  + brain/context.md (index)" -ForegroundColor Green

# brain/contexts/
@"
# Work Context

## Active Deals / Clients

| Client | Status | Next Step | Deadline |
|--------|--------|-----------|----------|
| | | | |
"@ | Out-File -FilePath "$ProjectPath\brain\contexts\work.md" -Encoding UTF8

@"
# Projects Context

## Active Projects

| Project | Stack | Status | Next Milestone |
|---------|-------|--------|----------------|
| | | | |
"@ | Out-File -FilePath "$ProjectPath\brain\contexts\projects.md" -Encoding UTF8

@"
# Content Context

## Publishing Schedule

| Day | Channel | Type |
|-----|---------|------|
| | | |

## Content Pipeline

| Title | Status | Channel | Due |
|-------|--------|---------|-----|
| | | | |
"@ | Out-File -FilePath "$ProjectPath\brain\contexts\content.md" -Encoding UTF8

Write-Host "  + brain/contexts/ (3 modules)" -ForegroundColor Green

# Skills
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

1. Write closing report in ``notes/daily-summaries/closing-DDMMYYYY.md``
2. Update ``brain/context.md`` if there are significant changes
3. Confirm: "Session closed. Report saved."
"@ | Out-File -FilePath "$ProjectPath\.claude\skills\close.md" -Encoding UTF8

Write-Host "  + .claude/skills/ (start + close)" -ForegroundColor Green

# Hooks
@"
#!/usr/bin/env python3
import json, sys, re

def main():
    hook_input = json.loads(sys.stdin.read())
    message = hook_input.get("message", "").lower()
    patterns = [r"call\s+(\w+)", r"use\s+(\w+)\s+agent", r"load\s+(\w+)\s+agent", r"switch to\s+(\w+)"]
    for pattern in patterns:
        match = re.search(pattern, message)
        if match:
            agent_name = match.group(1)
            print(json.dumps({"continue": True, "message": f"REQUIRED: Read agents/{agent_name}.md before responding."}))
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
    print(json.dumps({"continue": True, "message": "REMINDER: If this is a /close, update brain/context.md with status changes and decisions."}))

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

# Agent template
@"
# Example Agent

> Copy this template. Rename it. Make it yours.

## Identity
You are the **[Role Name]** - [what this agent does].

## Personality
- [Communication style]
- [Tone]

## Core Protocol
1. [First thing this agent always does]
2. [Second thing]

## Hard Limits
1. Never [thing this agent must never do]
2. Always [thing this agent must always do]

---
**The test:** Does this need its own personality that would conflict with another agent? If yes, it's an agent. If no, it's a protocol inside an existing agent.
"@ | Out-File -FilePath "$ProjectPath\agents\example-agent.md" -Encoding UTF8

Write-Host "  + agents/example-agent.md" -ForegroundColor Green

# .gitignore
@"
.DS_Store
Thumbs.db
*.swp
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
Write-Host "==========================================" -ForegroundColor Green

$openFolder = Read-Host "Open folder now? (y/n)"
if ($openFolder -eq "y" -or $openFolder -eq "Y") {
    explorer $ProjectPath
}

Write-Host ""
Write-Host "Press any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
