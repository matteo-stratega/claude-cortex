# Session Close

Execute the session close protocol:

## Step 1: Write Closing Report

Create or append to `notes/daily-summaries/closing-DDMMYYYY.md`:

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

## Step 2: Update Context (MANDATORY)

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

## Step 3: Multi-Session Handling

If closing report for today already exists:
- **APPEND** as `## Session N: [Topic]`
- Do NOT overwrite earlier sessions

## Step 4: Confirm

Tell user: "Session closed. Report saved in `notes/daily-summaries/closing-DDMMYYYY.md`."

---

Don't ask for confirmation — just write the report and update context.
