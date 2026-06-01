# Session Start

Execute the session start protocol.

## Step 0: Solo or team?

Read `brain/team.md` and count the entries under `users:`.

- **0 or 1 user (SOLO):** run the Solo protocol below. Do not ask who is here.
- **2 or more users (TEAM):** run the Team protocol below.

If `brain/team.md` does not exist, treat it as SOLO.

---

## Solo protocol

### Step 1: Load context
1. Read `brain/context.md` (the index — always loaded).
2. Read the latest `notes/daily-summaries/closing-*.md` file (if any).

### Step 2: Propose
Summarize in max 5 bullet points:
- What was done last session (from the closing report).
- What is pending.
- Current focus from the context index.

Then ask: **"What are we working on today?"**

### Step 3: STOP
Wait for the response before proceeding.

### Step 4: Load relevant context
Based on the answer, load ONLY the matching file from `brain/contexts/`:

| User says... | Load |
|--------------|------|
| Work, clients, sales, deals | `brain/contexts/work.md` |
| Building, coding, projects | `brain/contexts/projects.md` |
| Content, blog, social, video | `brain/contexts/content.md` |
| Anything else | Ask: "Is this work, building, or content?" |

**Never load all context files at once.** One area per session.

### Step 5: Work
Proceed with the task — the right context is loaded.

---

## Team protocol

The brain (`brain/context.md`, `brain/contexts/*`, agents, hooks) is shared.
Only the session reports are per-person, so two people can work and close on
the same day without overwriting each other.

### Step 1: Identify the user
Ask: **"Who is starting this session?"** and match the answer to a handle in
`brain/team.md`.

Skip the question if the user already named themselves in this message, or the
context makes it obvious. If the answer matches no handle, stop and ask again —
never guess. Below, `<user>` is the matched handle.

### Step 2: Load context
1. Read `brain/context.md` (the shared index — always loaded).
2. Read the latest `notes/daily-summaries/<user>/closing-*.md` (this person's own last close).
3. Read the most recent dated entries in `brain/changelog.md` (if it exists) to
   see what teammates changed in shared brain files since this user last worked.

### Step 2.5: Surface only relevant teammate activity
Scan the latest closing report of each *other* user
(`notes/daily-summaries/<other>/closing-*.md`). Surface an item ONLY if it is
one of these — otherwise skip it:

1. **Blocker:** a teammate is waiting on `<user>`, or `<user>` is blocked waiting on them. Flag as a P0 callout.
2. **Area overlap:** the teammate touched something in `<user>`'s area (same client, deal, project, or topic).
3. **Cross-cutting decision:** a teammate made a call that changes how `<user>` should approach today's work.

**Skip routine work** that does not affect `<user>`: internal refactors, doc
maintenance, hooks/scripts, brain housekeeping, and work in areas `<user>` does
not own. If a teammate's last close is older than 3 days, skip them entirely.
If nothing is relevant, say nothing — no filler lines.

### Step 3: Propose
Summarize in max 5 bullet points:
- What `<user>` did last session (from their closing report).
- What is pending on `<user>`'s plate.
- Current focus from the context index, filtered to `<user>`'s areas.

Then ask: **"What are we working on today?"**

### Step 4: STOP
Wait for the response before proceeding.

### Step 5: Load relevant context
Same routing table as the Solo protocol (Step 4). Load ONLY the one matching
file from `brain/contexts/`. Never load all context files at once.

### Step 6: Work
Proceed with the task.
