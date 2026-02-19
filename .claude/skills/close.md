# Session Close

Execute the session close protocol:

## Step 1: Write Closing Report

Create file `notes/daily-summaries/closing-DDMMYYYY.md`:

```
# Closing [DATE]

## TL;DR
- **Done**: [what completed today]
- **Pending**: [what remains]
- **Next**: [next priority action]

## Files Created/Modified
- [list of files touched]

## Decisions Made
- [any key decisions worth remembering]

---
**Session Status**: Completed
```

## Step 2: Update Context

Update `brain/context.md` if there are:
- New priorities to add to "This Week"
- Completed tasks to remove
- Status changes in Active Areas table

Also update the relevant `brain/contexts/*.md` file if project statuses changed.

## Step 3: Confirm

Tell user: "Session closed. Report saved in [path]."

---

Don't ask for confirmation — just write the report and update context.
