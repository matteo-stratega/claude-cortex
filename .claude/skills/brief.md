# Daily Brief

Generate a quick status overview:

## Step 1: Load Context

1. Read `brain/context.md`
2. Read the latest `notes/daily-summaries/closing-*.md`

## Step 2: Generate Brief

Output this format:

```
## Brief — [Today's Date]

**Focus:** [Main area from context]

### Yesterday
- [Key completions from last closing report]

### Today's Priorities
1. [From "This Week" in context — what's most urgent]
2. [Second priority]
3. [Third priority]

### Blockers
- [Anything waiting on someone else or stuck]

### Quick Numbers
- [Any key metrics from context: MRR, pipeline, deadlines]
```

## Rules

- Max 20 lines total. This is a glance, not a report.
- Priorities come from context.md "This Week" section
- If no closing report exists, skip "Yesterday" section
- Don't load area context files — the brief uses the index only
