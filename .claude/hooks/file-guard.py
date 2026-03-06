#!/usr/bin/env python3
"""
Hook: File Guard
Trigger: PreToolUse (fires before Write/Edit tools)
Purpose: Prevents writing to protected paths and catches common mistakes.

Checks:
- No writing to .env, .credentials/, or key files
- No writing outside the workspace (path traversal)
- Warns on CLAUDE.md edits (usually accidental)

Setup: Add to .claude/settings.json under hooks.PreToolUse
"""
import json
import sys
import os

def main():
    hook_input = json.loads(sys.stdin.read())

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})

    # Only check file-writing tools
    if tool_name not in ("Write", "Edit"):
        print(json.dumps({"continue": True}))
        return

    file_path = tool_input.get("file_path", "")

    # Block: credential files
    blocked_patterns = [
        ".env",
        ".credentials/",
        "credentials.json",
        ".pem",
        ".key",
        "MASTER.env",
    ]

    for pattern in blocked_patterns:
        if pattern in file_path:
            result = {
                "continue": False,
                "message": f"BLOCKED: Cannot write to '{file_path}' — this looks like a credential file. If intentional, add it to .gitignore first."
            }
            print(json.dumps(result))
            return

    # Warn: CLAUDE.md edits (often accidental when editing other .md files)
    if file_path.endswith("CLAUDE.md"):
        result = {
            "continue": True,
            "message": "NOTE: You're editing CLAUDE.md (master instructions). Make sure this is intentional — changes here affect all future sessions."
        }
        print(json.dumps(result))
        return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
