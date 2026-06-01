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
| `/weekly` | Weekly retrospective — what shipped, patterns, next week priorities |
| `/daily-wrap` | End-of-day consolidation — merges sessions, updates context, preps tomorrow |
| `/setup` | First-time guided setup (run once after cloning) |

Each skill is a directory `.claude/skills/<name>/SKILL.md` — the folder name is
the command you type. Add your own by creating `.claude/skills/<name>/SKILL.md`
with `name` + `description` frontmatter; the `description` lets Claude auto-load
it when relevant.

The `soul` skill is the exception: it's `user-invocable: false`, so it never
appears as a slash command — it's the agent's identity and hard limits, loaded
automatically. Edit `.claude/skills/soul/SKILL.md` to make the agent yours.

## Team mode

By default this is a solo workspace. To share it with a team, list handles in
`brain/team.md` (`users:`). With 2+ users, `/start` and `/close` identify who is
in the session and keep per-person closing reports under
`notes/daily-summaries/<user>/`, so no one overwrites anyone else. Shared-brain
edits are logged to `brain/changelog.md` for teammates to see on `/start`.

## Hooks

Hooks fire automatically on events. Configured in `hooks/hooks.json` (plugin mode) or `.claude/settings.json` (clone mode):

| Hook | Trigger | Purpose |
|------|---------|---------|
| `file-guard.py` | PreToolUse | Blocks writes to credential files, warns on CLAUDE.md edits |
| `simplest-approach-enforcer.py` | PreToolUse | Blocks overcomplicated tooling (e.g. browser automation to read a page) |
| `agent-call-enforcer.py` | UserPromptSubmit | Forces reading agent files instead of improvising |
| `context-auto-save.py` | Stop | Reminds to update context when running /close |
| `lazy-question-blocker.py` | Stop | Pushes Claude to find answers itself before asking you |
| `verification-gate.py` | Stop | Blocks "it's done" claims that include no verification evidence |

## Agents

Agent definitions live in `agents/`. Each agent has its own personality, protocol, and decision rules.

### How to Call an Agent

Say "call [agent-name]" — e.g., "call cto", "call war-council".

### Agent Existence Protocol (Important)

When an agent is called:
1. Read the agent file from `agents/` **silently**
2. **BE** that agent immediately — no transition announcements
3. Respond as the agent, with its own voice
4. If the agent file doesn't exist, say so — **never improvise an agent from scratch**

```
# Wrong
"I'm now switching to the CTO agent role..."

# Right
[The agent responds directly, in its own voice, without preamble]
```

### Available Agents

| Agent | Domain | File |
|-------|--------|------|
| CTO | Code, debug, architecture, infrastructure | `agents/cto.md` |
| Content Strategist | Blog, social, email, content planning | `agents/content-strategist.md` |
| Growth Hacker | Outreach, funnels, experiments, channels | `agents/growth-hacker.md` |
| War Council | Multi-perspective decision making | `agents/war-council.md` |
| Archivist | Workspace organization, git hygiene, commits | `agents/archivist.md` |

### Agent Auto-Routing (Optional)

Agents can auto-load based on context — no need to call them explicitly:

| Trigger | Action |
|---------|--------|
| Code, debug, API, errors, infrastructure | Read `agents/cto.md` first |
| Blog, social, email, content | Read `agents/content-strategist.md` first |
| Outreach, funnel, pipeline, growth | Read `agents/growth-hacker.md` first |

## General Rules

1. **Don't invent data** — Ask if you don't know
2. **Respect folder structure** — Each file in its place
3. **Execute autonomously** — Only ask if critical info is missing
4. **Be concise** — Short, actionable responses
5. **Update context** — Keep brain files current after every session
6. **Never load everything** — Only read what's needed for the current task
7. **Think before doing** — State the problem, list options, then act

## Token Budget

Keep responses focused:
- **Startup** (`/start`): Keep it short — load context, summarize, ask what we're doing
- **Per-task responses**: As short as the task allows
- **Planning**: Invest tokens in thinking, not in verbose explanations

## Project Structure

```
cortex/                          # your workspace
├── CLAUDE.md                    # Master instructions
├── PATTERNS.md                  # Recipes and proven patterns
├── brain/
│   ├── context.md               # Index (loads every session, ~60 lines)
│   ├── team.md                  # Solo by default; list handles for team mode
│   ├── changelog.md             # Shared-brain change log (team mode)
│   └── contexts/                # Area-specific context (load on demand)
│       ├── work.md              # Clients, deals, revenue
│       ├── projects.md          # Active builds
│       └── content.md           # Blog, social, video
├── agents/                      # 4 ready-to-use agents
│   ├── cto.md                   # Technical decisions + debugging
│   ├── content-strategist.md    # Content creation + frameworks
│   ├── growth-hacker.md         # Growth experiments + outreach
│   └── war-council.md           # Multi-perspective decisions
├── examples/                    # What the system looks like in action
├── hooks/                       # 3 enforcement scripts (.py)
├── scripts/
│   ├── morning-brief.sh         # Automated daily brief (cron/launchd)
│   └── com.cortex.morning-brief.plist  # macOS launchd config
├── notes/daily-summaries/       # Session reports from /close
├── docs/                        # Final documents
└── .claude/
    ├── skills/                  # 7 skills, each <name>/SKILL.md
    └── settings.json            # Hook config (clone mode)
```

## Output Style

- Markdown formatting, bullet points
- No emojis (unless requested)
- Get to the point — lead with the answer, not the reasoning
- Short sentences over long explanations
