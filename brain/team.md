---
# Cortex team config — controls solo vs multi-user session routing.
#
#   0-1 users  ->  SOLO mode: /start and /close behave exactly as the default.
#   2+ users   ->  TEAM mode: each person gets their own closing folder
#                  (notes/daily-summaries/<handle>/) and /start + /close
#                  identify who is in the session before reading or writing.
#
# Use a short, lowercase, single-word handle per person — it is used as a
# folder name, so keep it filesystem-safe (no spaces, no slashes).
#
# state_isolation (optional, TEAM mode only — default: shared)
#   shared    ->  one brain/context.md for everyone (v2.2 behaviour).
#   per-user  ->  context.md holds only the shared header (team + this-week
#                 priorities + cross-person handoffs); each operator's own
#                 state lives in brain/context-<handle>.md. Two people never
#                 write the same index file, so cloud-sync (Drive/iCloud)
#                 cannot produce a conflicted copy of it. Recommended once a
#                 synced team is past ~60 lines of shared context.
users:
  - you
# state_isolation: per-user
---

# Team

This workspace is configured for the users listed in the frontmatter above.

- **Solo (default):** keep a single user. Sessions write to
  `notes/daily-summaries/closing-DDMMYYYY.md`. No routing, no extra questions —
  identical to a workspace without this file.
- **Team:** add one handle per person. As soon as there are 2+ users,
  `/start` and `/close` become routers: they work out who is in the session,
  then read and write that person's own files. Two people closing on the same
  day never overwrite each other.

To turn a solo workspace into a team, add handles here — the router re-reads
this file at the start of every session, so the change takes effect immediately.
No per-person files to create: one generic `/start` and `/close` serve everyone.

## Shared vs per-user state (`state_isolation`)

By default the brain index (`context.md`) is **shared**: everyone reads and
writes the same file, and the convention "edit only your own sections" keeps
people out of each other's way. That holds while the file stays small.

For a larger synced team it breaks down: the shared file grows past its lean
ceiling, and two people editing it in the same window produce a cloud "conflicted
copy". Set `state_isolation: per-user` in the frontmatter to fix both at once.
Then `context.md` keeps only the shared header (team, this-week priorities, and
cross-person handoffs/blockers), while each operator's deals and areas live in
their own `brain/context-<handle>.md`. `/start` loads the header plus your file;
`/close` writes your file and touches `context.md` only for shared-header items.
The `size-guard` hook enforces a write-time ceiling on every `context*.md` file.
