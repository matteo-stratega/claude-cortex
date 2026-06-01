#!/usr/bin/env bash
#
# Cortex sync — single source of truth.
#
# Canonical skills live in  skills/<name>/SKILL.md  (the plugin location:
# `/plugin install` reads them directly, namespaced as /cortex:<name>).
#
# A directly-cloned repo, however, runs as a normal project, and Claude Code
# only registers project skills from  .claude/skills/<name>/SKILL.md . So we
# mirror the canonical skills into .claude/skills/ as real file copies
# (committed, Windows-safe — no symlinks, which break on Windows clones).
#
# Edit skills under skills/, then run this script. It is idempotent: it wipes
# and rebuilds .claude/skills/ from skills/, so deletions and renames carry
# over. Treat .claude/skills/ as generated output — never hand-edit it.
#
# Usage:  bash scripts/sync.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC="skills"
DEST=".claude/skills"

if [ ! -d "$SRC" ]; then
  echo "error: no $SRC/ directory at repo root" >&2
  exit 1
fi

# Rebuild the mirror from scratch so renames/removals propagate.
rm -rf "$DEST"
mkdir -p "$DEST"

count=0
for skill_md in "$SRC"/*/SKILL.md; do
  [ -e "$skill_md" ] || continue
  name="$(basename "$(dirname "$skill_md")")"
  mkdir -p "$DEST/$name"
  # Copy the whole skill directory (SKILL.md + any supporting files).
  cp -R "$SRC/$name/." "$DEST/$name/"
  count=$((count + 1))
  echo "  + $DEST/$name/  (from $SRC/$name/)"
done

echo "synced $count skill(s): $SRC/ -> $DEST/"
