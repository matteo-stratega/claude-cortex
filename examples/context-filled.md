# Context Index — Example (Filled In)

> This is what context.md looks like after 2 weeks of use. Copy this structure, replace with your data.

**Last Updated:** 06/03/2026

---

## Who I Am

- **Name:** Alex Chen
- **Role:** Solo founder + freelance growth consultant
- **Company:** LaunchKit (dev tools SaaS) + consulting clients

---

## Active Areas

| Area | Context File | Status |
|------|-------------|--------|
| Work | `contexts/work.md` | Active |
| Projects | `contexts/projects.md` | Active |
| Content | `contexts/content.md` | Active |

---

## This Week

- [ ] Ship onboarding email sequence (3 emails, Resend)
- [ ] Acme Corp: send proposal v2 (adjusted scope)
- [x] Fix auth bug (JWT expiry — deployed Tue)
- [ ] LinkedIn post: "What I learned building in public for 30 days"

---

## Quick Reference

| Key | Value |
|-----|-------|
| Main tool | Claude Code (Max plan) |
| Stack | Next.js, Supabase, Vercel, Resend |
| CRM | HubSpot (free tier) |
| Domain | launchkit.dev |
| MRR | $3,200 |
| Target | $5,000 by end of Q1 |

---

## How This Works

1. `/start` reads this index
2. I say what I'm working on
3. Claude loads only the relevant context file
4. `/close` saves a report and cleans up this file

**Rule: never load all context files at once.**
