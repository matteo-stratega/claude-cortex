---
name: close
description: Session close ritual. Writes the closing report and updates the brain context. Use when the user ends a work session — says "close", "wrap up", "end of day", or "done for today".
---

# Session Close

Execute the session close protocol.

## Step 0: Solo or team?

Read `brain/team.md` and count the entries under `users:`.

- **0 or 1 user (SOLO):** the report path is `notes/daily-summaries/closing-DDMMYYYY.md`. Skip Step 1a.
- **2 or more users (TEAM):** run Step 1a to identify the owner first.

If `brain/team.md` does not exist, treat it as SOLO.

## Step 1a: Identify the owner (TEAM only)

Ask: **"Who is closing this session?"** and match the answer to a handle in
`brain/team.md`. Skip the question if it is already obvious from the session.
If it matches no handle, stop and ask again — closing under the wrong name
overwrites someone else's work, which is exactly what the split prevents.

The report path becomes `notes/daily-summaries/<user>/closing-DDMMYYYY.md`.
Create the `<user>/` folder if it does not exist.

## Step 1: Write the closing report

Create or append to the report path from Step 0/1a:

```markdown
# Closing [DATE]

## TL;DR
- **Done**: [what completed today]
- **Pending**: [what remains]
- **Next**: [next priority action]

## Details
[Brief summary of main activities — 3-5 sentences max]

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

## Step 2: Update context (MANDATORY)

**Team with `state_isolation: per-user` (check `brain/team.md`):** write your own
state to `brain/context-<user>.md` (create it if it does not exist yet). Touch the shared `brain/context.md` only for
shared-header items — this-week priorities you own, or a new cross-person
handoff/blocker. Never edit another operator's `context-<handle>.md`. The Add /
Remove rules below apply to whichever file you are updating.

Update `brain/context.md` (or `brain/context-<user>.md` in per-user mode):

### Add
- New priorities or decisions
- Status changes on projects/deals
- New pending tasks

### Remove (this is not optional)

| Section | Rule |
|---------|------|
| This Week | Check off completed items. Remove items done >3 days ago. |
| Active Areas | Update status if anything changed |
| Quick Reference | Update if key info changed |

**Principle:** `context.md` is a SNAPSHOT of current state, not a history log. The history lives in closing reports.

**Hard rule — keep `context.md` lean.** Target ~60 lines; hard ceiling ~80 lines / 12KB.
Never append session narrative or a running log to it — that belongs in
`notes/daily-summaries/`. The same goes for `brain/contexts/*` files (keep each well
under ~35KB), and for each `brain/context-<handle>.md` in per-user mode (~35KB).
Two guards enforce this: the `size-guard` hook blocks an over-ceiling write the
moment it happens, and the brain tripwire (`git config core.hooksPath .githooks`)
blocks a bloated commit. Don't bypass either — trim instead.

Also update the relevant `brain/contexts/*.md` file if project statuses changed.

## Step 2b: Persist durable learnings (auto memory)

If this session produced something worth remembering across sessions — a
correction the user gave you, a preference, a non-obvious project constraint, a
useful reference — save it to auto memory following the `memory` skill's house
style (typed topic file + a one-line index entry in `MEMORY.md`). Skip anything
derivable from the code, git, or CLAUDE.md, and anything that only mattered
today. Most sessions save nothing; that's fine.

## Step 2a: Log shared-brain changes (TEAM only)

If you edited any shared brain file this session (`brain/context.md`,
`brain/contexts/*`, agents, hooks, skills), append one dated line per change to
`brain/changelog.md` so teammates see it on their next `/start`. Create the file
from the template header if it does not exist. Routine per-person work
(your own closing report) does not go here.

Format:

```markdown
## YYYY-MM-DD — <user>
- `brain/contexts/work.md` — [one-line summary of what changed and why it matters to others]
```

## Step 3: Multi-session handling

If a closing report for today already exists (at the same path):
- **APPEND** as `## Session N: [Topic]`.
- Do NOT overwrite earlier sessions.

## Step 4: Confirm

Tell the user: "Session closed. Report saved in `<the report path>`."

---

Don't ask for confirmation — just write the report and update context.
