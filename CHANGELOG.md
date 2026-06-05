# Changelog

All notable changes to Cortex are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/).

## [2.2.0] — 2026-06-05

The "star-ready" release: native memory, multi-user support, hardened hooks,
and a distribution model that can't drift from source.

### Added
- **Native memory** — zero-dependency auto-memory plus a `memory` skill
  convention, so the agent persists durable facts across sessions.
- **Multi-user, config-driven setup** — team members live in `brain/team.md`;
  no names are hardcoded anywhere.
- **CI** — GitHub Actions runs shell-syntax, Python-compile, `selfcheck.sh`
  (hook fixtures + reference lint), and a skill-mirror drift check on every
  push and PR. Badge in the README.
- `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, issue/PR templates.

### Changed
- **Drift-proof distribution** — the installer now clones the repo and assembles
  a clean workspace from its files instead of embedding copies (installer
  shrank from 3368 to 286 lines). Canonical skills live in `skills/<name>/`
  and are mirrored into `.claude/skills/` by `scripts/sync.sh`.

### Fixed
- **`file-guard` now actually blocks.** It emits the correct
  `hookSpecificOutput.permissionDecision: "deny"` schema; the previous
  top-level `{"continue": false}` did not deny a tool write.
- `context-auto-save` and other advisory hooks surface notes via
  `systemMessage` instead of the non-existent `message` field.
- Ported tech-debt fixes from the host workspace: `agent-call-enforcer` no-op,
  brain tripwire (`.githooks` blocking context bloat / broken frontmatter),
  deterministic morning-brief context injection.

## [2.1] — 2026-04-20

### Added
- **Plugin format** — Cortex installs as a Claude Code plugin via
  `/plugin install`, with skills namespaced as `/cortex:<name>`.

## [2.0] — 2026-02-19

### Added
- Modular **brain** (`brain/context.md` + sub-contexts), auto-loading **skills**,
  enforcement **hooks**, and specialized **agents**.

## [1.0] — 2026-02-19

- Original setup from the Part 1 video walkthrough.

[2.2.0]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v2.2.0
[2.1]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v2.1
[2.0]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v2.0
[1.0]: https://github.com/matteo-stratega/claude-cortex/releases/tag/v1.0
