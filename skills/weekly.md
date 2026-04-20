# Weekly Review

Generate a weekly retrospective from your closing reports.

## Step 1: Gather Data

Read all `notes/daily-summaries/closing-*.md` files from the past 7 days.
Also read `brain/context.md` for current priorities.

## Step 2: Generate Review

Output this format:

```markdown
## Week Review — [Date Range]

### Shipped
- [Completed items across all sessions this week]

### Decided
- [Key decisions made — from "Key Decisions" sections]

### Blocked
- [Things that are stuck or waiting on someone]

### Numbers
- Sessions: [count]
- Areas touched: [list]

### Next Week
Based on what's done and what's pending:
1. [Top priority for next week]
2. [Second priority]
3. [Third priority]

### Patterns
- [Any recurring theme — e.g., "spent 60% of time on client work, only 10% on product"]
- [Anything that kept coming up as blocked]
```

## Step 3: Update Context

Ask: "Should I update brain/context.md with next week's priorities?"

If yes, update the "This Week" section.

## Rules

- If fewer than 3 closing reports exist, say so and give a shorter review
- "Patterns" section is the most valuable part — look for time allocation, recurring blockers, drift from stated priorities
- Be honest about what didn't get done, not just what did
- Max 30 lines total
