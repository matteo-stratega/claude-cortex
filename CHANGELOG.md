# Changelog

All notable changes to Cortex are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/).

## [2.3.0] — 2026-06-09

Multitenant state. v2.2 isolated multi-user *outputs* (per-person closings) and
routed sessions; the brain *state* stayed shared and bloat was caught only at
commit time. That breaks for a synced team: the shared `context.md` grows past
its ceiling and two people editing it produce a cloud conflicted-copy. This
release isolates per-operator state and enforces the ceiling at write time.

### Added
- **Per-operator state isolation** (opt-in) — set `state_isolation: per-user` in
  `brain/team.md` and each operator's deals/areas live in their own
  `brain/context-<handle>.md`, while `context.md` keeps only the shared header
  (team, this-week priorities, cross-person handoffs). Two people never write the
  same index file, so cloud sync can't conflict it. Names stay config-driven —
  nothing hardcoded. Default is unchanged (`shared`); solo workspaces are untouched.
- **`size-guard` hook** — a PreToolUse guard that blocks an over-ceiling write to
  any `brain/context*.md` the moment it happens (12KB for `context.md`, 35KB per
  `context-<handle>.md`), the write-time complement to the commit-time tripwire.
  Cloud-synced teams write between commits, so the commit hook alone never fired.

### Changed
- `/start` and `/close` honour `state_isolation`: load/write the per-operator file
  in `per-user` mode, shared `context.md` otherwise.
- The `.githooks` brain tripwire now also size-checks `brain/context-<handle>.md`.
- `selfcheck.sh` covers `size-guard` (deny over-ceiling, allow small, ignore the rest).

## [2.2.0] — 2026-06-05

The "star-ready" release: native memory, multi-user support, hardened hooks,
and a distribution model that can't drift from source.

### Added
- **Native memory** — zero-dependency auto-memory plus a `memory` skill
  convention, so the agent persists durable facts across sessions.
- **Config-driven multi-user** — session routing per operator; team members live
  in `brain/team.md` with no names hardcoded anywhere.
- **Upstream Tier 1** — autonomy hooks + `daily-wrap` skill.
- **Upstream Tier 2** — `soul` (template) + `archivist` agent.
- **`selfcheck.sh`** — fixture tests for every hook + a reference lint, run in CI.
- **Brain tripwire** — a `.githooks` pre-commit guardrail that blocks `context.md`
  bloat and broken frontmatter, plus a `/close` hard-rule.
- **CI** — GitHub Actions runs shell-syntax, Python-compile, `selfcheck.sh`, and a
  skill-mirror drift check on every push and PR. Badge in the README.
- `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, and
  issue/PR templates.

### Changed
- **Drift-proof distribution** — installers now clone the repo and assemble a
  clean workspace from its files instead of embedding copies (installers shrank
  from 3368 to 286 lines).
- **Skills moved to `SKILL.md` directory format**; canonical skills live in
  `skills/<name>/` and are mirrored into `.claude/skills/` by a generated
  `scripts/sync.sh`.
- Sharper README hook — tagline + "what you get" + demo slot.

### Fixed
- **`file-guard` now actually blocks.** It emits the correct
  `hookSpecificOutput.permissionDecision: "deny"` schema (live-verified); the
  previous top-level `{"continue": false}` did not deny a tool write.
- **`agent-call-enforcer` was a no-op** — it read the wrong field and emitted the
  wrong output; now it injects the right guidance via `additionalContext`.
- `morning-brief` injects context deterministically + a hollow-output tripwire.
- `daily-wrap` auto-loads (dropped `disable-model-invocation`).
- Forward-slash paths in `setup-windows.ps1` for portability.

## [2.1] — 2026-04-20

Plugin distribution, plus the full v2 build-out and two hardening rounds shipped
in this tag (development through 2026-03-06).

### Added
- **Plugin format** — Cortex installs as a Claude Code plugin via
  `/plugin install` (#1), with skills namespaced as `/cortex:<name>`.
- **Full Cortex v2 build-out** — 4 agents, 7 skills, 3 enforcement hooks, a
  patterns/recipes guide (`PATTERNS.md`), and the automated morning brief.

### Changed
- **Setup-script parity** — `setup.sh` and `setup-windows.ps1` assemble the same
  33 files (eliminated content drift between the two).
- **README glow-up** — badges, collapsible sections, "what I built" section,
  corrected links.

### Fixed
- **25 bugs** caught across two multi-agent review rounds (10 + 15).
- `file-guard` credential coverage; `.gitignore` now matches the file-guard
  blocked names.
- Prerequisites ordered before quickstart; Python 3 listed as a prerequisite;
  Xcode Command Line Tools added to prereqs/troubleshooting.
- `context.md` kept under 60 lines with a realistic token budget.

## [2.0] — 2026-02-19

### Added
- **v2 architecture foundation** — modular brain (`brain/context.md` +
  sub-contexts), auto-loading skills, enforcement hooks, and specialized agents.

## [1.0] — 2026-02-19

The original Claude Code workspace template from the Part 1 video (developed
2026-01-13 → 2026-01-16).

### Added
- **One-click setup** (`setup.sh`) with a two-step install method as the default
  (more reliable); Gemini CLI included in the one-click setup; English-first docs.

### Fixed
- npm `EACCES` permission-error troubleshooting; Xcode Command Line Tools added to
  prerequisites; README fixes (YouTube link, LinkedIn URL).

[2.3.0]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v2.3.0
[2.2.0]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v2.2.0
[2.1]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v2.1
[2.0]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v2.0
[1.0]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v1.0
