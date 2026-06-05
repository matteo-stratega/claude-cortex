# Security Policy

Cortex is a local-first operating system for Claude Code. Two facts shape its
threat model, and you should understand both before installing:

1. **Cortex ships enforcement hooks that execute on your machine.** The hooks in
   `hooks/` and `.githooks/` are Python/shell scripts that Claude Code runs
   locally (on `PreToolUse`, `Stop`, `UserPromptSubmit`, and on `git commit`).
   They are intentionally small and dependency-free so you can read every line
   before trusting them. Read them.
2. **Cortex never transmits your data.** There is no telemetry, no analytics, no
   phone-home. The only outbound network call in the whole project is the
   optional `scripts/morning-brief.sh`, which calls the Anthropic API **with your
   own `ANTHROPIC_API_KEY`** — nothing is sent anywhere else.

Cortex also actively *blocks* a class of mistakes: the `file-guard` hook denies
writes to credential files (`.env`, `*.pem`, `*.key`, `.credentials/`, etc.) so
the agent can never commit a secret on your behalf.

## Supported versions

Only the latest tagged release receives fixes.

| Version | Supported |
| ------- | --------- |
| latest `v2.x` | ✅ |
| older | ❌ |

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Email **matteo@stratega.co** with:

- a description of the issue and its impact,
- steps to reproduce (a minimal hook payload or repo state is ideal),
- the version / commit you found it on.

You'll get an acknowledgement within a few days. Once a fix is out, you're
credited in the release notes unless you prefer to stay anonymous.
