---
name: memory
description: How this workspace keeps long-term memory. Auto-loads whenever you are about to write to, organize, or recall persistent memory across sessions.
user-invocable: false
---

# Memory

Claude Code ships **auto memory** (on by default, v2.1.59+): notes Claude writes
for itself that persist across sessions. They live in
`~/.claude/projects/<project>/memory/` — machine-local, per repository, never
committed. `MEMORY.md` (its index) loads at the start of every session; topic
files load on demand. This file is the **house style** for that memory: keep it
organized and it becomes a real asset; let it sprawl and it becomes noise.

## The shape

- **`MEMORY.md` is an index, not a dump.** One short line per stored fact, each
  pointing to a topic file: `- [Title](topic-file.md) — one-line hook`. Keep it
  lean (it loads every session). Small, high-frequency facts can live inline.
- **One fact per topic file.** A topic file holds a single durable thing, with
  frontmatter:

  ```markdown
  ---
  name: <short-kebab-slug>
  description: <one line — used to judge relevance on recall>
  type: user | feedback | project | reference
  ---

  <the fact. For feedback/project, follow with **Why:** and **How to apply:** lines.>
  ```
- **Link related memories** with `[[other-slug]]`. Link liberally; a link to a
  file that doesn't exist yet just marks one worth writing.

## What each type is for

- **user** — who the user is: role, expertise, durable preferences.
- **feedback** — guidance on how you should work (corrections and confirmed approaches). Include the **Why**.
- **project** — ongoing work, goals, or constraints not derivable from the code or git. Convert relative dates to absolute.
- **reference** — pointers to external resources (URLs, dashboards, tickets, docs).

## When NOT to save

Don't store what the repo already records — code structure, past fixes, git
history, or anything in CLAUDE.md — nor what only matters to the current
conversation. If asked to "remember" one of those, save the *non-obvious* part
(why it mattered), not the fact itself.

## Hygiene

- **Before saving, check for an existing file** on the topic and update it
  rather than duplicating. Delete memories that turn out to be wrong.
- **Never put credentials in memory.** Secrets go in a dedicated, gitignored
  file (`.credentials/`), never in a memory note.
- **Recall is background, not instruction.** A recalled memory reflects what was
  true when it was written. If it names a file, flag, or command, verify that
  still exists before acting on it.

Browse or edit memory any time with `/memory`.
