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
    if tool_name not in ("Write", "Edit"):
        print(json.dumps({"continue": True}))
        return

    if not isinstance(tool_input, dict):
        print(json.dumps({"continue": True}))
        return

    file_path = tool_input.get("file_path", "")
    basename = os.path.basename(file_path)

    # Block: credential files (check by extension and known names)
    blocked_extensions = {".pem", ".key"}
    blocked_names = {".env", ".env.local", ".env.production", ".env.staging", "MASTER.env", "credentials.json"}

    _, ext = os.path.splitext(basename)
    if ext in blocked_extensions or basename in blocked_names:
        result = {
            "continue": False,
            "message": f"BLOCKED: Cannot write to '{basename}' — this looks like a credential file. Add it to .gitignore first if intentional."
        }
        print(json.dumps(result))
        return

    # Block: .credentials/ directory
    if ".credentials" in file_path.split(os.sep):
        result = {
            "continue": False,
            "message": f"BLOCKED: Cannot write to .credentials/ directory. Credential files should not be managed by Claude."
        }
        print(json.dumps(result))
        return

    # Warn: CLAUDE.md edits (often accidental)
    if basename == "CLAUDE.md":
        result = {
            "continue": True,
            "message": "NOTE: You're editing CLAUDE.md (master instructions). Make sure this is intentional — changes here affect all future sessions."
        }
        print(json.dumps(result))
        return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
