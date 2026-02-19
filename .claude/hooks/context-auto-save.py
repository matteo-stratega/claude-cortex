#!/usr/bin/env python3
"""
Hook: Context Auto-Save Reminder
Trigger: Stop (end of assistant turn)
Purpose: Reminds Claude to update context when closing a session.

Setup: Add to .claude/settings.json under hooks.Stop
"""
import json
import sys

def main():
    hook_input = json.loads(sys.stdin.read())

    result = {
        "continue": True,
        "message": "REMINDER: If this is a /close, make sure to update brain/context.md with any status changes, new decisions, or completed tasks."
    }
    print(json.dumps(result))

if __name__ == "__main__":
    main()
