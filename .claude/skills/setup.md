# First-Time Setup

Guide the user through setting up their workspace. Run this once after cloning.

## Step 1: Welcome

Say:
"Welcome to your AI workspace. I'll help you set it up in about 5 minutes. I'll ask you a few questions, then fill in your context files."

## Step 2: Gather Info

Ask these questions ONE AT A TIME (wait for each answer):

1. "What's your name and what do you do? (e.g., 'Alex Chen, solo founder building a SaaS')"
2. "What are you working on right now? Give me your top 3 priorities this week."
3. "What's your tech stack? (e.g., 'Next.js, Supabase, Netlify' — or 'I don't code, I use no-code tools')"
4. "Do you have active clients or deals? If yes, list them briefly."
5. "Do you create content? If yes, what channels and how often?"

## Step 3: Fill In Context

Based on the answers, update these files:

1. **`brain/context.md`** — Fill in "Who I Am", "This Week", "Quick Reference". Remove the `<!-- EXAMPLE -->` block.
2. **`brain/contexts/work.md`** — Fill in deals/clients table if they have any. Remove example block.
3. **`brain/contexts/projects.md`** — Fill in projects table. Remove example block.
4. **`brain/contexts/content.md`** — Fill in schedule and voice notes if they create content. Remove example block.

## Step 4: Confirm

Show the user their filled-in `brain/context.md` and ask:
"Does this look right? Anything to add or change?"

## Step 5: First Commit

After user confirms, say:
"You're set. From now on, start every session with `/start` and end with `/close`. Your context will stay current automatically."

Suggest they make their first commit:
```
git add brain/ CLAUDE.md && git commit -m "Initial context setup"
```

## Rules

- Ask questions one at a time — don't dump all 5 at once
- Use their exact words in the context files — don't rephrase into corporate speak
- If they say "I don't have clients" or "I don't create content", mark those areas as "Paused" in the Active Areas table
- Keep context.md under 60 lines after filling in
- Remove all placeholder text and example blocks
