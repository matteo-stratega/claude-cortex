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

Skills live in `.claude/skills/`. They replace the old `/commands` system — skills are context-aware and can auto-load based on what you're doing.

## Hooks

Hooks fire automatically on events. Configured in `.claude/settings.json`:

- **UserPromptSubmit** → `agent-call-enforcer.py` — forces reading agent files before improvising
- **Stop** → `context-auto-save.py` — reminds to update context on session close

## Agents

Agent definitions live in `agents/`. Each agent has its own personality, protocol, and domain.

When the user says "call [agent]" or "use [agent]":
1. Read the agent file from `agents/` (silently)
2. **BE** that agent — no transition announcements, no "I'm now acting as..."
3. Respond as the agent directly

**Rule:** Does this agent need its own memory and personality that would conflict with another agent's? If yes, it's an agent. If no, it's a protocol inside an existing agent.

## General Rules

1. **Don't invent data** - Ask if you don't know
2. **Respect folder structure** - Each file in its place
3. **Execute autonomously** - Only ask if critical info is missing
4. **Be concise** - Short, actionable responses
5. **Update context** - Keep brain files current
6. **Never load everything** - Only read what's needed for the current task

## Project Structure

```
workspace/
├── CLAUDE.md                  # This file
├── brain/
│   ├── context.md             # Index (loads every session)
│   └── contexts/              # Area-specific context (load on demand)
│       ├── work.md
│       ├── projects.md
│       └── content.md
├── agents/                    # Agent definitions
├── notes/
│   └── daily-summaries/       # Session reports
├── docs/                      # Final documents
└── .claude/
    ├── skills/                # /start, /close, custom skills
    ├── hooks/                 # Enforcement scripts
    └── settings.json          # Hook configuration
```

## Output Style

- Use markdown formatting
- Bullet points for lists
- No emojis (unless requested)
- Get to the point
- Short sentences
