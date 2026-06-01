# Contributing to Cortex

Thanks for helping. Cortex is a small, opinionated codebase — these rules keep
it that way.

## The one rule that trips everyone up

Skills are authored in **`skills/<name>/SKILL.md`** (the canonical source).
`.claude/skills/` is a **generated mirror** — Claude Code reads project skills
only from there, so a direct clone needs it. After editing anything under
`skills/`:

```bash
bash scripts/sync.sh
```

Never hand-edit `.claude/skills/` — your change will be overwritten on the next
sync. CI fails if the mirror is out of date.

## Before you open a PR

```bash
bash scripts/selfcheck.sh     # hook fixtures + reference lint — must be green
bash scripts/sync.sh          # skill mirror in sync
```

Both run in CI too. If you touched a hook, add or update its fixture in
`scripts/selfcheck.sh` — a hook with no test is how the flagship one silently
became a no-op once.

## Conventions

- **Skills**: `skills/<name>/SKILL.md` with `name` + `description` frontmatter. The directory name is the command.
- **Agents**: `agents/<name>.md` — Identity, Personality, Core protocol, Decision rules, Hard limits. Register it in `CLAUDE.md` and the README table.
- **Hooks**: Python in `hooks/`, wired in *both* `hooks/hooks.json` (plugin) and `.claude/settings.json` (clone). Use the correct output schema per event — `permissionDecision: "deny"` for PreToolUse, `decision: "block"` for Stop, `hookSpecificOutput.additionalContext` for UserPromptSubmit. `{"continue": false}` does **not** block a single tool.
- **Keep it neutral.** No personal names, client names, or business-specific data — this is a template anyone clones. Use placeholders (`alice`, `Acme`).
- **Brain stays lean.** `brain/context.md` is a snapshot, not a log. The pre-commit tripwire enforces it (`git config core.hooksPath .githooks`).

## Adding a dependency

Don't, unless there's a strong reason. Cortex's pitch is zero-dependency
(Node + Python + Claude Code, nothing else). A PR that adds an npm/pip package
needs to justify the cost.

## Scope

Cortex is the skeleton, not the muscle. Business logic, niche integrations, and
personal workflows belong in *your* fork, not here. PRs that make the core
sharper, simpler, or more reliable are the ones that get merged.
