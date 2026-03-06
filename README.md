<p align="center">
  <h1 align="center">Cortex</h1>
  <p align="center">An operating system for Claude Code.<br/>Persistent memory, specialized agents, auto-loading skills, enforcement hooks.</p>
</p>

<p align="center">
  <a href="https://github.com/matteo-stratega/claude-cortex/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-825af5" alt="License"></a>
  <a href="https://github.com/matteo-stratega/claude-cortex/stargazers"><img src="https://img.shields.io/github/stars/matteo-stratega/claude-cortex?color=825af5" alt="Stars"></a>
  <a href="https://github.com/matteo-stratega/claude-cortex/commits/main"><img src="https://img.shields.io/github/last-commit/matteo-stratega/claude-cortex?color=825af5" alt="Last Commit"></a>
</p>

<p align="center">
  <a href="https://youtu.be/FxcAz0oRD7A">Video Walkthrough</a> · <a href="https://stratega.co/blog/my-ai-brain-behind-the-scenes">Blog Part 1</a> · <a href="https://stratega.co/blog/my-ai-brain-part-2-one-month-later">Blog Part 2</a>
</p>

---

**This is the skeleton. You add the muscle.**

I use this exact architecture to run my solo consultancy — 9 projects, 160+ tasks shipped, 36 agents. The repo is the business. [Full story here.](https://stratega.co/blog/my-ai-brain-part-2-one-month-later)

## Quick Start

```bash
git clone https://github.com/matteo-stratega/claude-cortex.git cortex
cd cortex
claude
/setup
```

`/setup` walks you through filling in your context. Takes about 5 minutes.

<details>
<summary><b>One-liner install (Mac/Linux)</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/matteo-stratega/claude-cortex/main/setup.sh -o setup.sh
bash setup.sh
```
</details>

<details>
<summary><b>Windows (PowerShell)</b></summary>

```powershell
irm https://raw.githubusercontent.com/matteo-stratega/claude-cortex/main/setup-windows.ps1 | iex
```
</details>

**Prerequisites:** [Node.js](https://nodejs.org) (LTS) + [Claude Code](https://claude.ai) (Pro $20/mo or Max $100/mo)

## What's Inside

```
cortex/
├── CLAUDE.md                    # Master instructions (routing, rules, structure)
├── PATTERNS.md                  # Recipes and proven patterns
├── brain/
│   ├── context.md               # Index — loads every session (~60 lines)
│   └── contexts/                # Area-specific context (loaded on demand)
│       ├── work.md              # Clients, deals, revenue
│       ├── projects.md          # Active builds
│       └── content.md           # Blog, social, video
├── agents/                      # 4 ready-to-use agents
│   ├── cto.md                   # Think > Plan > Execute, debugging protocol
│   ├── content-strategist.md    # Framework-first writing, voice rules
│   ├── growth-hacker.md         # ICE scoring, funnel audits
│   └── war-council.md           # Multi-perspective decision making
├── examples/                    # What it looks like in action
│   ├── context-filled.md        # Brain after 2 weeks of real use
│   ├── closing-report.md        # What /close generates
│   └── war-council-output.md    # War council decision example
├── scripts/
│   ├── morning-brief.sh         # Automated daily brief (cron/launchd)
│   └── com.cortex.morning-brief.plist  # macOS launchd config
├── notes/daily-summaries/       # Session reports from /close
├── docs/                        # Final documents
└── .claude/
    ├── skills/                  # 7 skills
    ├── hooks/                   # 3 enforcement hooks
    └── settings.json            # Hook config
```

## How It Works

### Brain — Modular Context

Your context is split into an **index** (loads always, ~60 lines) and **area files** (loaded on demand).

Why? One monolithic context file means Claude processes your deal pipeline when you're writing a blog post. Splitting it cuts noise and improves output quality.

**Rule: never load all context files at once.**

### Agents — AI Personalities

Agents are markdown files with distinct personalities, protocols, and decision rules. Say "call [name]" to activate one.

| Agent | What It Does |
|-------|-------------|
| **CTO** | Think > Plan > Execute. 5-step debugging protocol. Evaluates dependencies before installing. |
| **Content Strategist** | Framework-first writing (PAS, AIDA, Hook-Story-Offer). Self-critique before publishing. Voice rules that kill AI-sounding copy. |
| **Growth Hacker** | ICE scoring for experiments. Funnel audits. Experiment templates with hypothesis + success criteria. |
| **War Council** | Three perspectives on any decision: Operator (speed), Strategist (long-term), Critic (failure modes). One clear recommendation. |

Each agent has hard limits and decision rules. They don't just answer differently — they *think* differently.

> **See it in action:** Check `examples/war-council-output.md` for a real War Council decision.

### Skills — Smart Commands

| Skill | What it does |
|-------|-------------|
| `/setup` | **First-time guided onboarding** — fills in your context in 5 minutes |
| `/start` | Reads context, checks last session, asks what you're working on |
| `/close` | Writes session report, updates context, cleans up completed items |
| `/brief` | Quick daily status overview — priorities, blockers, key numbers (20 lines) |
| `/plan` | Breaks any task into phases with verification criteria |
| `/review` | Code review checklist — security, simplicity, edge cases |
| `/weekly` | Weekly retrospective — what shipped, time patterns, next week priorities |

Add your own: drop a markdown file in `.claude/skills/`.

### Hooks — Invisible Enforcement

Hooks fire on events. You don't invoke them. They just run.

| Hook | Trigger | Purpose |
|------|---------|---------|
| `file-guard.py` | PreToolUse | **Blocks** writes to `.env`, credentials, key files. Warns on CLAUDE.md edits. |
| `agent-call-enforcer.py` | UserPromptSubmit | Forces reading agent files instead of improvising |
| `context-auto-save.py` | Stop | Reminds to update context when running /close |

### Morning Brief — Automated Daily Status

Run your brief on autopilot. The script calls Claude non-interactively, reads your context, and generates a 20-line status report.

```bash
# Run manually
./scripts/morning-brief.sh

# Cron (every day at 8:30 AM)
crontab -e
30 8 * * * cd /path/to/cortex && ./scripts/morning-brief.sh

# macOS launchd (edit paths in the plist first)
cp scripts/com.cortex.morning-brief.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.cortex.morning-brief.plist
```

Output goes to `notes/daily-summaries/brief-YYYYMMDD.md` and stdout.

## Examples

The `examples/` folder shows what the system looks like after real use:

- **`context-filled.md`** — A brain/context.md after 2 weeks, with real priorities, metrics, and tech stack
- **`closing-report.md`** — What `/close` generates: TL;DR, files modified, key decisions
- **`war-council-output.md`** — A real War Council deliberation on "should I launch a free tier?"

## Patterns & Recipes

**[Read PATTERNS.md](PATTERNS.md)** — a reference guide covering:

- Context patterns (60-line rule, snapshot principle, context layering)
- Agent patterns (agent vs protocol, decision tables, War Council pattern)
- Skill patterns (structure, auto-loading, chaining)
- Hook patterns (types, templates, ideas for custom hooks)
- Session patterns (the session loop, multi-session days, weekly rhythm)
- Common mistakes and how to avoid them
- Scaling up (MCP integrations, local AI, multiple projects)

## What I Built With This

This isn't a demo. It's the architecture behind a real business:

- Online academy (auth, admin dashboard, 7 email automations, real students)
- Fashion trend analysis pipeline (my dad runs it, one command)
- Competitive intelligence system (7 agents research prospects before calls)
- CRM cleanup (450 → 74 companies in one afternoon)
- 3 websites deployed
- Prospecting pipelines (research → verify → enrich → CRM)
- Newsletter + content production system

36 agents. 6 MCP integrations. 25 auto-loading skills. 4 enforcement hooks. ~$100/mo.

## Customization

<details>
<summary><b>Add a brain module</b></summary>

1. Create `brain/contexts/your-area.md`
2. Add it to the routing table in `brain/context.md`
3. Add a matching row to the `/start` skill routing table
</details>

<details>
<summary><b>Create an agent</b></summary>

1. Create `agents/your-agent.md`
2. Include: Identity, Personality, Core Protocol, Decision Rules, Hard Limits
3. Add it to the agents table in `CLAUDE.md`
4. Call it with "call [agent-name]" in any session

**Tips:**
- "Professional" means nothing. "Direct, no filler, never says 'great question'" means something.
- Give it decision rules, not just personality. "When X happens, do Y."
- Hard limits prevent the agent from doing things you'll regret.
- **The test:** Does this agent need its own personality that would conflict with another? If yes, agent. If no, it's a protocol inside an existing agent.
</details>

<details>
<summary><b>Add a skill</b></summary>

1. Create `.claude/skills/your-skill.md`
2. Structure: Step 1 → Step 2 → Step 3 → Output format → Rules
3. Call it with `/your-skill` in any session

Skills work best with: clear steps, a specific output format, and rules for edge cases.
</details>

<details>
<summary><b>Add a hook</b></summary>

1. Write a Python script in `.claude/hooks/`
2. Read stdin (JSON), write stdout (JSON with `continue: true/false` and optional `message`)
3. Add it to `.claude/settings.json` under the right trigger
4. Available triggers: `PreToolUse`, `PostToolUse`, `UserPromptSubmit`, `Stop`

Start with warnings (permissive) before blocks (restrictive). See `PATTERNS.md` for hook templates and ideas.
</details>

<details>
<summary><b>Add local AI (Ollama)</b></summary>

```bash
brew install ollama
ollama pull mistral:7b-instruct
ollama run mistral:7b-instruct
```

Use for: batch classification, large document summarization, tasks that don't need Claude's full reasoning.
</details>

## Troubleshooting

<details>
<summary><b>Xcode Command Line Tools (Mac)</b></summary>

```bash
xcode-select --install
```
</details>

<details>
<summary><b>Permission Error (EACCES) on Mac</b></summary>

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```
</details>

## Learn More

- [Video: My AI Brain — 1-Click Setup](https://www.youtube.com/watch?v=FxcAz0oRD7A)
- [Blog: I Built an AI Brain That Runs My Entire Business](https://stratega.co/blog/my-ai-brain-behind-the-scenes)
- [Blog: My AI Brain, One Month Later: What Changed](https://stratega.co/blog/my-ai-brain-part-2-one-month-later)

---

Built by [Matteo Lombardi](https://linkedin.com/in/matteolombardi9) — solo growth operator, building in public.

**MIT License** — Use it, modify it, share it.
