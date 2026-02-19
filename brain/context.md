# Context Index

**Last Updated:** [DATE]

This is the main index. It loads every session. Keep it under 60 lines.
Detailed context lives in `brain/contexts/` — load only what's relevant.

---

## Who I Am

- **Name:** [Your name]
- **Role:** [What you do]
- **Company:** [Your company/project]

---

## Active Areas

| Area | Context File | Status |
|------|-------------|--------|
| Work | `contexts/work.md` | [Active/Paused] |
| Projects | `contexts/projects.md` | [Active/Paused] |
| Content | `contexts/content.md` | [Active/Paused] |

---

## This Week

- [ ] Priority 1
- [ ] Priority 2
- [ ] Priority 3

---

## Quick Reference

| Key | Value |
|-----|-------|
| Main tool | Claude Code |
| Subscription | [Claude Pro / Max] |
| Stack | [Your tech stack] |

---

## How This Works

1. `/start` reads this index (always)
2. You say what you're working on
3. Claude loads only the relevant context file
4. End of session: `/close` saves a report

**Rule: never load all context files at once.**

---

*Add your areas to the table above. Create matching files in `contexts/`.*
