# Context Index

**Last Updated:** [DATE]

This is the main index. It loads every session. Keep it under 60 lines.
Detailed context lives in `brain/contexts/` — load only what's relevant.

---

## Who I Am

- **Name:** [Your name]
- **Role:** [What you do — e.g., "Solo founder", "Freelance developer", "Growth marketer"]
- **Company:** [Your company/project name]

---

## Active Areas

| Area | Context File | Status |
|------|-------------|--------|
| Work | `contexts/work.md` | [Active/Paused] |
| Projects | `contexts/projects.md` | [Active/Paused] |
| Content | `contexts/content.md` | [Active/Paused] |

---

## This Week

- [ ] [Your top priority — be specific: "Ship landing page for ProductX" not "work on website"]
- [ ] [Second priority]
- [ ] [Third priority]

---

## Quick Reference

| Key | Value |
|-----|-------|
| Main tool | Claude Code |
| Subscription | [Claude Pro / Max] |
| Stack | [Your tech stack — e.g., "Next.js, Supabase, Netlify"] |

---

## How This Works

1. `/start` reads this index (always)
2. You say what you're working on
3. Claude loads only the relevant context file
4. End of session: `/close` saves a report and cleans up this file

**Rule: never load all context files at once.**

---

*Add your areas to the table above. Create matching files in `contexts/`.*
*See `examples/context-filled.md` for what this looks like after 2 weeks of use.*
