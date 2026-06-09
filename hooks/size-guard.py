#!/usr/bin/env python3
"""
Hook: Size Guard
Trigger: PreToolUse (fires before Write/Edit tools)
Purpose: Keeps the brain index lean at WRITE time, not just at commit time.

The .githooks/pre-commit tripwire blocks a bloated context.md, but it only
fires on `git commit`. Teams that sync the brain over a cloud folder (Drive,
iCloud, Syncthing) write and propagate between commits — often from machines
that never run the git hook at all. By then context.md has already grown to
tens of thousands of tokens and every /start pays for it. This hook enforces
the same ceiling the moment the file is written.

Scope: only the brain index files —
  - brain/context.md            (shared snapshot header)   ceiling 12 KB
  - brain/context-<handle>.md   (per-operator state, v2.3) ceiling 35 KB
Everything else is ignored. Deep context files (brain/contexts/*.md) keep
their own commit-time ceiling and are not write-gated here.

Enforcement is on `Write` (full-content replace) only: the new content is in
the payload, so the post-write size is known. `Edit`/`MultiEdit` are allowed
through — they are usually prunes, and computing a post-edit size in a hook is
fragile. The commit-time tripwire and the /close size report are the backstop.

Setup: add to .claude/settings.json under hooks.PreToolUse.
"""
import json
import sys
import os

# Byte ceilings, kept in step with .githooks/pre-commit so the two guards agree.
CONTEXT_MAX_BYTES = 12000   # brain/context.md  (CTX_MAX_BYTES)
PEROWNER_MAX_BYTES = 35000  # brain/context-<handle>.md  (SUB_MAX_BYTES)


def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except Exception:
        print(json.dumps({"continue": True}))
        return

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})

    # Only full-content writes carry the resulting size in the payload.
    if tool_name != "Write" or not isinstance(tool_input, dict):
        print(json.dumps({"continue": True}))
        return

    file_path = tool_input.get("file_path", "")
    parts = file_path.replace("\\", "/").split("/")
    basename = parts[-1] if parts else ""

    # Guard only the brain index files (must live under a `brain/` directory).
    if "brain" not in parts[:-1]:
        print(json.dumps({}))
        return

    if basename == "context.md":
        ceiling = CONTEXT_MAX_BYTES
    elif basename.startswith("context-") and basename.endswith(".md"):
        ceiling = PEROWNER_MAX_BYTES
    else:
        print(json.dumps({}))
        return

    content = tool_input.get("content", "")
    if not isinstance(content, str):
        # A real Write always carries string content. A present-but-non-string
        # value (null, number, list) is a malformed payload — never size it or
        # deny on it, and never crash.
        print(json.dumps({}))
        return
    size = len(content.encode("utf-8"))
    if size <= ceiling:
        print(json.dumps({}))
        return

    # PreToolUse denial schema (same as file-guard.py): a top-level
    # {"continue": false} would stop the whole agent and carries no message.
    reason = (
        f"'{basename}' would be {size} bytes, over the {ceiling}-byte ceiling. "
        f"The brain index is a SNAPSHOT, not a log — move session history into "
        f"notes/daily-summaries/ closings and trim stale items, then save again. "
        f"(roughly {size // 4} tokens; aim well under {ceiling // 4}.)"
    )
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }))


if __name__ == "__main__":
    main()
