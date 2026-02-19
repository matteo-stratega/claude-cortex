# Session Start

Execute the session start protocol:

## Step 1: Load Context
1. Read `brain/context.md` (the index — always loaded)
2. Read the latest `notes/daily-summaries/closing-*.md` file (if exists)

## Step 2: Propose
Summarize in max 5 bullet points:
- What was done in last session (from closing report)
- What is pending
- Current focus from context index

Then ask: **"What are we working on today?"**

## Step 3: STOP
**Wait for response before proceeding.**

## Step 4: Load Relevant Context
Based on the user's answer, load ONLY the matching context file from `brain/contexts/`:

| User says... | Load |
|-------------|------|
| Work, clients, sales, deals | `brain/contexts/work.md` |
| Building, coding, projects | `brain/contexts/projects.md` |
| Content, blog, social, video | `brain/contexts/content.md` |

**Never load all context files at once.** One area per session. If the user switches topics, load the new context file then.

## Step 5: Work
Proceed with the task. You now have the right context loaded.
