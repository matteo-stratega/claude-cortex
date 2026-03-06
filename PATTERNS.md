# Patterns & Recipes

Proven patterns for getting the most out of your Claude Code workspace. Copy what works, skip what doesn't.

---

## Context Patterns

### The 60-Line Rule

Your `brain/context.md` should never exceed ~60 lines. If it's growing, you're logging history instead of maintaining a snapshot. Move details to area files.

```
Too much:
- [23-Feb] Fixed auth bug in login.js
- [24-Feb] Added password reset flow
- [25-Feb] Deployed to staging

Right:
- Auth: working (deployed 25-Feb)
```

### Context Layering

```
brain/context.md          ← Always loaded (~60 lines, index only)
brain/contexts/work.md    ← Loaded when working on clients/sales
brain/contexts/projects.md ← Loaded when building/coding
brain/contexts/content.md  ← Loaded when creating content
```

**Why it works:** Claude processes everything in context. If your deal pipeline is loaded when you're debugging CSS, it wastes tokens and adds noise. Split = better output.

**Add your own areas:** Create `brain/contexts/finance.md`, `brain/contexts/hiring.md`, whatever your work needs. Add the routing to `/start`.

### The Snapshot Principle

Context files describe NOW, not history. History lives in `notes/daily-summaries/`.

| Context file says... | Closing report says... |
|---------------------|----------------------|
| "Auth: working" | "25-Feb: Fixed auth bug (root cause: expired JWT)" |
| "Pipeline: $5K" | "Closed Acme for $2K, lost Beta Corp (budget)" |

---

## Agent Patterns

### Agent vs Protocol

Before creating a new agent, ask: "Does this need its own personality and decision framework that would conflict with another agent?"

- **CTO agent** debugs cautiously, evaluates dependencies → conflicts with a "move fast" personality
- **Content agent** writes casually, uses frameworks → conflicts with technical documentation style
- A "code reviewer" is NOT a separate agent — it's a protocol (skill) the CTO can follow

### Agent Decision Tables

The most powerful part of an agent isn't personality — it's decision rules:

```markdown
| Situation | Action |
|-----------|--------|
| New dependency needed | Check stars, last commit, open issues before installing |
| Bug report | Reproduce first, never guess at fixes |
```

These rules prevent Claude from improvising. Without them, agents are just vibes.

### The War Council Pattern

For important decisions, use multiple perspectives in one response:

1. **The Operator** — What's fastest and most practical?
2. **The Strategist** — What's the long-term play?
3. **The Critic** — How does this fail?

Then synthesize into one recommendation. See `agents/war-council.md`.

---

## Skill Patterns

### Skill Structure

Every skill should have:

```markdown
# Skill Name

## Step 1: [Input/Gather]
What information to collect or read.

## Step 2: [Process]
What to do with it.

## Step 3: [Output]
Exact format of the result.

## Rules
- Edge cases
- What NOT to do
```

### Auto-Loading Skills

Some skills should fire automatically based on what you're doing, not just when called explicitly. Add routing rules to CLAUDE.md:

```markdown
## Skill Auto-Loading

| Trigger | Skill |
|---------|-------|
| Code, debug, API | Load CTO agent protocols |
| Email, DM, post | Load copy/content protocols |
| Deploy, release | Load deployment checklist |
```

### Skill Chaining

Skills can reference other skills:
- `/plan` creates a plan → user approves → each phase uses CTO agent
- `/close` writes report → updates context → triggers weekly review if it's Friday

---

## Hook Patterns

### Hook Types

| Trigger | Fires When | Use For |
|---------|-----------|---------|
| `PreToolUse` | Before any tool runs | Block dangerous operations, validate inputs |
| `PostToolUse` | After any tool runs | Log actions, trigger follow-ups |
| `UserPromptSubmit` | User sends a message | Inject context, enforce protocols |
| `Stop` | Assistant finishes responding | Reminders, auto-saves |

### Hook Template

```python
#!/usr/bin/env python3
import json, sys

def main():
    hook_input = json.loads(sys.stdin.read())

    # Your logic here
    should_continue = True
    message = ""  # Optional: inject instructions

    result = {"continue": should_continue}
    if message:
        result["message"] = message
    print(json.dumps(result))

if __name__ == "__main__":
    main()
```

### Hook Ideas

- **Commit message enforcer** — Reject commits without meaningful messages
- **Time tracker** — Log when sessions start/stop
- **Scope guard** — Warn if Claude is about to modify files outside the current project
- **Language enforcer** — Force responses in a specific language

---

## Session Patterns

### The Session Loop

Every productive session follows this pattern:

```
/start → understand context → do work → /close
```

The closing report is the most important artifact. It's what makes the next session productive. Without it, every session starts from zero.

### Multi-Session Days

When you work multiple sessions in a day, `/close` appends to the same file:

```
notes/daily-summaries/closing-06032026.md
├── Session 1: Reddit Monitor Setup
├── Session 2: Content Publishing
└── Session 3: Email Workflow Fix
```

### The Weekly Rhythm

```
Monday    → /start + /brief (orient)
Daily     → /start → work → /close
Friday    → /close + /weekly (retrospective)
```

The `/weekly` review catches patterns: where you spend time vs where you should, recurring blockers, drift from priorities.

---

## Common Mistakes

### 1. Loading Everything

```
# Wrong: loading all context at startup
Read brain/context.md
Read brain/contexts/work.md
Read brain/contexts/projects.md
Read brain/contexts/content.md

# Right: load only what's needed
Read brain/context.md → ask what we're doing → load ONE area file
```

### 2. Context as History

```
# Wrong: context.md as a changelog
- [Mon] Fixed bug X
- [Tue] Added feature Y
- [Wed] Meeting with client Z

# Right: context.md as current state
- Auth: working
- Feature Y: shipped, monitoring for bugs
- Client Z: proposal sent, waiting for response
```

### 3. Too Many Agents

If you have 10 agents and use 3 regularly, you have 7 too many. Start with CTO + Content + Growth. Add only when you feel a real gap — when Claude gives answers that conflict with how a specific domain should work.

### 4. Skills Without Rules

A skill that says "write a blog post" is useless. A skill that says "write a blog post: pick framework (PAS/AIDA), draft under 1000 words, self-critique before output, never use 'game-changer'" is useful.

### 5. Hooks That Block Everything

Start with permissive hooks (warnings) before restrictive hooks (blocks). A hook that blocks too aggressively will frustrate you into disabling it.

---

## Scaling Up

### Adding MCP Integrations

Claude Code supports MCP (Model Context Protocol) servers for external tools:

```json
// .claude/settings.json
{
  "mcpServers": {
    "your-tool": {
      "command": "npx",
      "args": ["-y", "your-mcp-server"]
    }
  }
}
```

Common integrations: Google Workspace, Slack, databases, CRM, analytics.

### Adding Local AI

For tasks that don't need Claude's full power (classification, summarization of large docs):

```bash
brew install ollama
ollama pull mistral:7b-instruct
```

Then delegate from Claude Code: "Use ollama to classify these 500 emails, then give me the summary."

### Multiple Projects

Keep each project in a subfolder with its own context:

```
workspace/
├── brain/contexts/project-a.md
├── brain/contexts/project-b.md
├── projects/
│   ├── project-a/
│   └── project-b/
```

Add project-specific routing to `/start`.

---

*These patterns come from running a real business with this system — 36 agents, 9 projects, 160+ tasks shipped. Take what works, ignore what doesn't.*
