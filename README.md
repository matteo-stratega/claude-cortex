# Claude Code Workspace Template

A ready-to-use workspace for Claude Code with modular memory, skills, hooks, and agents.

**This is the skeleton. You add the muscle.**

## What's Inside

| Feature | What it does |
|---------|-------------|
| **Modular brain** | Context split into index + area modules. Load only what's relevant. |
| **Skills** | `/start` and `/close` — context-aware session management |
| **Hooks** | Enforcement scripts that fire automatically (agent loader, auto-save reminder) |
| **Agent template** | Pattern for creating AI agents with distinct personalities |
| **Organized structure** | Folders for brain, notes, docs, agents |

## Quick Start

### Prerequisites

- [Node.js](https://nodejs.org) (LTS version)
- [Claude Code subscription](https://claude.ai) (Pro $20/mo or Max $100/mo)

### One-Click Installation

**Mac/Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/matteo-stratega/claude-workspace-template/main/setup.sh -o setup.sh
bash setup.sh
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/matteo-stratega/claude-workspace-template/main/setup-windows.ps1 | iex
```

### Manual Installation

```bash
git clone https://github.com/matteo-stratega/claude-workspace-template.git my-workspace
cd my-workspace
claude
/start
```

## Folder Structure

```
workspace/
├── CLAUDE.md                    # Main instructions for Claude
├── brain/
│   ├── context.md               # Index — loads every session (~60 lines)
│   └── contexts/                # Area-specific context (loaded on demand)
│       ├── work.md              # Clients, deals, revenue
│       ├── projects.md          # Active builds, side projects
│       └── content.md           # Blog, social, video pipeline
├── agents/
│   └── example-agent.md         # Template for creating agents
├── notes/
│   └── daily-summaries/         # Session reports from /close
├── docs/                        # Final documents
└── .claude/
    ├── skills/                  # /start and /close skills
    │   ├── start.md
    │   └── close.md
    ├── hooks/                   # Enforcement scripts
    │   ├── agent-call-enforcer.py
    │   └── context-auto-save.py
    └── settings.json            # Hook configuration
```

## How It Works

### The Brain (Modular Context)

Your context is split into an index and area-specific files:

- `brain/context.md` — The index. 60 lines max. Loads every session.
- `brain/contexts/*.md` — Detailed context per area. Loaded only when relevant.

**Why?** One monolithic context file means Claude processes your deal pipeline when you're writing a blog post. Splitting it cuts noise and improves output quality.

**Rule: never load all context files at once.**

### Skills (Smart Commands)

Skills live in `.claude/skills/` and replace the old `/commands` system:

| Skill | What it does |
|-------|-------------|
| `/start` | Reads context index, checks last session, asks what you're working on, loads the right context file |
| `/close` | Writes session report, updates context, confirms |

To create your own skill, add a markdown file in `.claude/skills/`.

### Hooks (Invisible Enforcement)

Hooks fire on events — before you type, after Claude responds, when a session ends. Configured in `.claude/settings.json`.

| Hook | Trigger | Purpose |
|------|---------|---------|
| `agent-call-enforcer.py` | UserPromptSubmit | Forces reading agent files instead of improvising |
| `context-auto-save.py` | Stop | Reminds Claude to update context on close |

To add your own hook: write a Python/JS script, add it to `.claude/settings.json`.

### Agents (AI Personalities)

Agents are markdown files in `agents/` that define distinct AI personalities with their own protocols, decision rules, and hard limits.

**The test:** Does this agent need its own memory and personality that would conflict with another agent's? If yes, it's an agent. If no, it's a protocol inside an existing agent.

See `agents/example-agent.md` for the pattern.

## What's NOT in This Repo

- **Your agents** — they encode your business, not a template
- **MCP configurations** — they need your own API keys
- **Your brain content** — the structure is here, the data is yours

## Usage

### Starting a Session

```bash
cd ~/workspace
claude
/start
```

Claude will:
1. Load your context index
2. Check your last session report
3. Ask what you're working on
4. Load only the relevant context

### Ending a Session

```
/close
```

Claude will:
1. Write a session report to `notes/daily-summaries/`
2. Update context if needed
3. Confirm closure

## Customization

### Add a Brain Module

1. Create `brain/contexts/your-area.md`
2. Add it to the table in `brain/context.md`
3. Update the routing table in `.claude/skills/start.md`

### Create an Agent

1. Copy `agents/example-agent.md`
2. Rename to `agents/your-agent.md`
3. Fill in identity, personality, protocol, decision rules
4. Call it with "call [agent-name]" in any session

### Add a Hook

1. Write a script in `.claude/hooks/`
2. Add it to `.claude/settings.json` under the right trigger
3. Available triggers: `SessionStart`, `UserPromptSubmit`, `Stop`

## Upgrading from v1

If you installed the template before February 2026:

1. **Backup your context:** `cp brain/context.md brain/context.md.backup`
2. **Pull the update:** `git pull origin main`
3. **Split your context:** Move detailed sections from your old `context.md` into the new `brain/contexts/` files
4. **Move commands to skills:** If you customized `.claude/commands/`, move them to `.claude/skills/`

Your old commands still work — skills are an addition, not a replacement.

## Optional: Add Ollama (Local AI)

For local AI models (free, private, offline):

```bash
brew install ollama
ollama pull mistral:7b-instruct
ollama run mistral:7b-instruct
```

## Troubleshooting

### Xcode Command Line Tools (Mac)

If you see a popup asking to install developer tools:
```bash
xcode-select --install
```

### Permission Error (EACCES) on Mac

**Quick fix:**
```bash
sudo npm install -g @anthropic-ai/claude-code
```

**Proper fix (recommended):**
```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

## Video Tutorials

- [Part 1: My AI Brain — 1-Click Setup](https://www.youtube.com/watch?v=FxcAz0oRD7A)
- Part 2: Coming soon

## Blog Posts

- [I Built an AI Brain That Runs My Entire Business](https://stratega.co/blog/my-ai-brain-behind-the-scenes)
- [My AI Brain, One Month Later: What Changed](https://stratega.co/blog/my-ai-brain-part-2-one-month-later)

## Credits

Created by [Matteo Lombardi](https://linkedin.com/in/matteolombardi9) — Growth Architect building in public.

## License

MIT — Use it, modify it, share it.
