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

Update `brain/context.md`:

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

Also update the relevant `brain/contexts/*.md` file if project statuses changed.

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
