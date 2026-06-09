#!/usr/bin/env bash
#
# Cortex selfcheck — fixture tests for every hook + a reference lint.
#
# Run it after editing a hook, a skill, or an agent. It feeds each hook a
# known input and asserts the expected output, then checks that the things the
# repo references actually exist. This is what catches a hook that silently
# became a no-op.
#
# Usage:  bash scripts/selfcheck.sh
#
set -u
cd "$(dirname "$0")/.."
PY=$(command -v python3 || command -v python || true)

pass=0; fail=0
ok()   { echo "  PASS  $1"; pass=$((pass + 1)); }
bad()  { echo "  FAIL  $1"; fail=$((fail + 1)); }

# run <hook> <fixture-json> -> echoes hook stdout
run() { printf '%s' "$2" | "$PY" "hooks/$1" 2>/dev/null; }

# expect_contains <name> <hook> <fixture> <needle>
expect_contains() { case "$(run "$2" "$3")" in *"$4"*) ok "$1";; *) bad "$1";; esac; }
# expect_absent <name> <hook> <fixture> <needle>
expect_absent()   { case "$(run "$2" "$3")" in *"$4"*) bad "$1";; *) ok "$1";; esac; }

echo "Hooks:"
if [ -z "$PY" ]; then echo "  (no python found — skipping hook tests)"; else

# file-guard: deny credential writes (PreToolUse permissionDecision), allow normal
expect_contains "file-guard denies .env"        file-guard.py \
  '{"tool_name":"Write","tool_input":{"file_path":"/p/.env"}}' '"permissionDecision": "deny"'
expect_absent   "file-guard allows source file" file-guard.py \
  '{"tool_name":"Write","tool_input":{"file_path":"/p/src/app.js"}}' 'deny'

# size-guard: deny an over-ceiling brain index write, allow a small one, ignore the rest.
# BIG is larger than both ceilings (12KB context.md, 35KB context-<handle>.md).
BIG=$(printf 'x%.0s' $(seq 1 40000))
expect_contains "size-guard denies bloated context.md"      size-guard.py \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"brain/context.md\",\"content\":\"$BIG\"}}" '"permissionDecision": "deny"'
expect_contains "size-guard denies bloated context-<user>"  size-guard.py \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"brain/context-tester.md\",\"content\":\"$BIG\"}}" '"permissionDecision": "deny"'
expect_absent   "size-guard allows small context.md"        size-guard.py \
  '{"tool_name":"Write","tool_input":{"file_path":"brain/context.md","content":"small snapshot"}}' 'deny'
expect_absent   "size-guard ignores deep context file"      size-guard.py \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"brain/contexts/work.md\",\"content\":\"$BIG\"}}" 'deny'
expect_absent   "size-guard ignores Edit (prune path)"      size-guard.py \
  "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"brain/context.md\"}}" 'deny'
expect_contains "size-guard survives non-string content"    size-guard.py \
  '{"tool_name":"Write","tool_input":{"file_path":"brain/context.md","content":null}}' '{}'

# simplest-approach: deny browser automation, allow normal
expect_contains "simplest denies browser-automation" simplest-approach-enforcer.py \
  '{"tool_name":"Bash","tool_input":{"command":"npx playwright test"}}' '"permissionDecision": "deny"'
expect_absent   "simplest allows plain command"      simplest-approach-enforcer.py \
  '{"tool_name":"Bash","tool_input":{"command":"ls -la"}}' 'deny'

# agent-call-enforcer: reads prompt, injects additionalContext
expect_contains "agent-call fires on 'call cto'"  agent-call-enforcer.py \
  '{"prompt":"call cto please"}' 'additionalContext'
expect_absent   "agent-call ignores old 'message' field" agent-call-enforcer.py \
  '{"message":"call cto please"}' 'additionalContext'

# context-auto-save: remind on /close
expect_contains "context-auto-save reminds on /close" context-auto-save.py \
  '{"message":"running /close now"}' 'systemMessage'

# lazy-question-blocker: block lazy question
expect_contains "lazy-question blocks lazy ask" lazy-question-blocker.py \
  '{"last_assistant_message":"Can you check the logs and confirm?"}' '"decision": "block"'

# verification-gate: block claim w/o evidence, allow w/ evidence
expect_contains "verification blocks unverified claim" verification-gate.py \
  '{"last_assistant_message":"All done! I shipped the landing page."}' '"decision": "block"'
expect_absent   "verification allows verified claim"   verification-gate.py \
  '{"last_assistant_message":"Shipped it. Verified: curl returned HTTP 200 and the build passed."}' 'block'
fi

echo "References:"
# every skill directory has a SKILL.md
for d in skills/*/; do
  [ -f "${d}SKILL.md" ] && ok "skill ${d}SKILL.md" || bad "skill ${d}SKILL.md missing"
done
# .claude/skills mirror matches skills/ (run sync.sh if this fails)
if diff -r skills .claude/skills >/dev/null 2>&1; then ok ".claude/skills mirror in sync"; else bad ".claude/skills out of sync — run scripts/sync.sh"; fi
# every agent named in the CLAUDE.md table has a file
while IFS= read -r a; do
  [ -f "$a" ] && ok "ref $a" || bad "ref $a missing"
done < <(grep -oE 'agents/[a-z-]+\.md' CLAUDE.md | sort -u)

echo ""
echo "Result: ${pass} passed, ${fail} failed."
[ "$fail" -eq 0 ]
