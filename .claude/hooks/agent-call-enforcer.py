#!/usr/bin/env python3
"""
Hook: Agent Call Enforcer
Trigger: UserPromptSubmit
Purpose: Forces reading agent files when user calls an agent.

Setup: Add to .claude/settings.json under hooks.UserPromptSubmit
"""
import json
import sys
import re

def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({"continue": True}))
        return

    message = hook_input.get("message", "").lower()

    patterns = [
        r"call\s+([\w-]+)",
        r"use\s+([\w-]+)\s+agent",
        r"load\s+([\w-]+)\s+agent",
        r"switch\s+to\s+([\w-]+)",
    ]

    # Filter out common stop words that aren't agent names
    stop_words = {"the", "a", "an", "my", "our", "this", "that", "it"}

    for pattern in patterns:
        match = re.search(pattern, message)
        if match:
            agent_name = match.group(1)
            if agent_name in stop_words:
                continue
            result = {
                "continue": True,
                "message": f"REQUIRED: Read agents/{agent_name}.md before responding. Do NOT improvise agent behavior."
            }
            print(json.dumps(result))
            return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
