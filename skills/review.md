# Code Review

Execute a focused code review:

## Step 1: Identify Changes

Look at the files that were modified in this session (or the files the user points to).

## Step 2: Review Checklist

For each file, check:

- [ ] **Security** — No hardcoded secrets, no SQL injection, no XSS, inputs validated at boundaries
- [ ] **Simplicity** — Could this be simpler? Is there dead code? Unnecessary abstraction?
- [ ] **Edge cases** — What happens with empty input? Null? Very large data?
- [ ] **Naming** — Do variable/function names explain what they do?
- [ ] **Error handling** — Are errors handled where they should be (boundaries, external calls)?

## Step 3: Output

Format your review as:

```
## Review: [filename]

**Verdict:** LGTM / Needs Changes / Blocking Issues

### Issues (if any)
1. [LINE] [SEVERITY: low/medium/high] — Description + suggested fix

### Good
- [What's well done — always include at least one positive]
```

## Rules

- Be specific. "This could be better" is useless. "Line 42: this SQL query is vulnerable to injection — use parameterized queries" is useful.
- Don't nitpick style unless it hurts readability
- Focus on bugs and security first, style last
- If everything looks good, say so. Don't invent problems.
