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
users:
  - you
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
