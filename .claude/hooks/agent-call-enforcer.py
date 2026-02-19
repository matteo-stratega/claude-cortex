#!/usr/bin/env python3
"""
Hook: Agent Call Enforcer
Trigger: UserPromptSubmit
Purpose: When user says "call [agent]" or "use [agent]", forces reading the agent file first.

Setup: Add to .claude/settings.json under hooks.UserPromptSubmit
"""
import json
import sys
import re

def main():
    hook_input = json.loads(sys.stdin.read())
    message = hook_input.get("message", "").lower()

    # Check for agent call patterns — add your language patterns here
    patterns = [
        r"call\s+(\w+)",
        r"use\s+(\w+)\s+agent",
        r"load\s+(\w+)\s+agent",
        r"switch to\s+(\w+)",
    ]

    for pattern in patterns:
        match = re.search(pattern, message)
        if match:
            agent_name = match.group(1)
            result = {
                "continue": True,
                "message": f"REQUIRED: Read agents/{agent_name}.md before responding. Do NOT improvise agent behavior."
            }
            print(json.dumps(result))
            return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
