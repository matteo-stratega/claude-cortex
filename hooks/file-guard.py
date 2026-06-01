#!/usr/bin/env python3
"""
Hook: File Guard
Trigger: PreToolUse (fires before Write/Edit tools)
Purpose: Prevents writing to protected paths and catches common mistakes.

Checks:
- No writing to .env, .credentials/, or key files
- Warns on CLAUDE.md edits (usually accidental)

Setup: Add to .claude/settings.json under hooks.PreToolUse
"""
import json
import sys
import os

def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({"continue": True}))
        return

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})

    # Only check file-writing tools
    if tool_name not in ("Write", "Edit", "MultiEdit"):
        print(json.dumps({"continue": True}))
        return

    if not isinstance(tool_input, dict):
        print(json.dumps({"continue": True}))
        return

    file_path = tool_input.get("file_path", "")
    basename = os.path.basename(file_path)

    # Block: credential files (check by extension and known names)
    blocked_extensions = {".pem", ".key"}
    blocked_names = {".env", ".env.local", ".env.production", ".env.staging", "MASTER.env", "credentials.json", "secrets.json", "token.json", "service-account.json", "api_keys.json"}

    _, ext = os.path.splitext(basename)

    def deny(reason):
        # PreToolUse denial: hookSpecificOutput.permissionDecision="deny".
        # NOTE: top-level {"continue": false} does NOT deny a tool — it stops
        # the whole agent — and there is no "message" field. Use this schema.
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        }))

    if ext in blocked_extensions or basename in blocked_names:
        deny(f"'{basename}' looks like a credential file. Cortex never writes these. "
             f"If this is intentional, write it yourself and add it to .gitignore.")
        return

    # Block: .credentials/ directory (normalize slashes for cross-platform)
    if ".credentials" in file_path.replace("\\", "/").split("/"):
        deny("Writes to .credentials/ are blocked — credential files should not be managed by Claude.")
        return

    # Warn (but allow): CLAUDE.md edits (often accidental). systemMessage shows
    # the note to the user; "message" is not a real field.
    if basename == "CLAUDE.md":
        print(json.dumps({
            "systemMessage": "Editing CLAUDE.md (master instructions) — changes here affect all future sessions."
        }))
        return

    print(json.dumps({}))

if __name__ == "__main__":
    main()
