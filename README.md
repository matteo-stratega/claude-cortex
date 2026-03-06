<p align="center">
  <h1 align="center">Claude Code Workspace Template</h1>
  <p align="center">Run your business from a git repo. Persistent memory, specialized agents, auto-loading skills, enforcement hooks.</p>
</p>

<p align="center">
  <a href="https://github.com/matteo-stratega/claude-workspace-template/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-825af5" alt="License"></a>
  <a href="https://github.com/matteo-stratega/claude-workspace-template/stargazers"><img src="https://img.shields.io/github/stars/matteo-stratega/claude-workspace-template?color=825af5" alt="Stars"></a>
  <a href="https://github.com/matteo-stratega/claude-workspace-template/commits/main"><img src="https://img.shields.io/github/last-commit/matteo-stratega/claude-workspace-template?color=825af5" alt="Last Commit"></a>
</p>

<p align="center">
  <a href="https://youtu.be/FxcAz0oRD7A">Video Walkthrough</a> · <a href="https://stratega.co/blog/my-ai-brain-behind-the-scenes">Blog Part 1</a> · <a href="https://stratega.co/blog/my-ai-brain-part-2-one-month-later">Blog Part 2</a>
</p>

---

**This is the skeleton. You add the muscle.**

I use this exact architecture to run my solo consultancy — 9 projects, 160+ tasks shipped, 36 agents. The repo is the business. [Full story here.](https://stratega.co/blog/my-ai-brain-part-2-one-month-later)

## Quick Start

```bash
git clone https://github.com/matteo-stratega/claude-workspace-template.git my-workspace
cd my-workspace
claude
/start
```

That's it. Claude reads your context, asks what you're working on, loads the right files.

<details>
<summary><b>One-liner install (Mac/Linux)</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/matteo-stratega/claude-workspace-template/main/setup.sh -o setup.sh
bash setup.sh
```
</details>

<details>
<summary><b>Windows (PowerShell)</b></summary>

```powershell
irm https://raw.githubusercontent.com/matteo-stratega/claude-workspace-template/main/setup-windows.ps1 | iex
```
</details>

**Prerequisites:** [Node.js](https://nodejs.org) (LTS) + [Claude Code](https://claude.ai) (Pro $20/mo or Max $100/mo)

## What's Inside

```
workspace/
├── CLAUDE.md                    # Master instructions
├── brain/
│   ├── context.md               # Index — loads every session (~60 lines)
│   └── contexts/                # Area-specific context (loaded on demand)
│       ├── work.md              # Clients, deals, revenue
│       ├── projects.md          # Active builds
│       └── content.md           # Blog, social, video
├── agents/
│   └── example-agent.md         # Agent template
├── notes/
│   └── daily-summaries/         # Session reports from /close
├── docs/                        # Final documents
└── .claude/
    ├── skills/                  # /start, /close
    ├── hooks/                   # Enforcement scripts
    └── settings.json            # Hook config
```

## How It Works

### Brain — Modular Context

Your context is split into an **index** (loads always, ~60 lines) and **area files** (loaded on demand).

Why? One monolithic context file means Claude processes your deal pipeline when you're writing a blog post. Splitting it cuts noise and improves output quality.

**Rule: never load all context files at once.**

### Skills — Smart Commands

| Skill | What it does |
|-------|-------------|
| `/start` | Reads context, checks last session, asks what you're working on, loads the right context |
| `/close` | Writes session report, updates context, confirms |

Add your own: drop a markdown file in `.claude/skills/`.

### Hooks — Invisible Enforcement

Hooks fire on events — before you type, after a session ends. You don't invoke them. They just run.

| Hook | Trigger | Purpose |
|------|---------|---------|
| `agent-call-enforcer.py` | UserPromptSubmit | Forces reading agent files instead of improvising |
| `context-auto-save.py` | Stop | Reminds to update context on close |

### Agents — AI Personalities

Agents are markdown files in `agents/` with distinct personalities, protocols, and decision rules.

**The test:** Does this agent need its own memory and personality that would conflict with another agent's? If yes, it's an agent. If no, it's a protocol inside an existing agent.

Copy `agents/example-agent.md` to get started.

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
3. Update `.claude/skills/start.md`
</details>

<details>
<summary><b>Create an agent</b></summary>

1. Copy `agents/example-agent.md`
2. Rename to `agents/your-agent.md`
3. Fill in identity, personality, protocol, decision rules
4. Call it with "call [agent-name]" in any session
</details>

<details>
<summary><b>Add a hook</b></summary>

1. Write a script in `.claude/hooks/`
2. Add it to `.claude/settings.json` under the right trigger
3. Available triggers: `SessionStart`, `UserPromptSubmit`, `Stop`
</details>

<details>
<summary><b>Add local AI (Ollama)</b></summary>

```bash
brew install ollama
ollama pull mistral:7b-instruct
ollama run mistral:7b-instruct
```
</details>

## Upgrading from v1

If you installed before February 2026:

1. Backup context: `cp brain/context.md brain/context.md.backup`
2. Pull update: `git pull origin main`
3. Split context: move sections into `brain/contexts/` files
4. Move commands to skills: `.claude/commands/` → `.claude/skills/`

Old commands still work — skills are an addition, not a replacement.

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
