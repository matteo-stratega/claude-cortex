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

    # UserPromptSubmit delivers the user's text in "prompt" (not "message").
    prompt = hook_input.get("prompt", "").lower()

    patterns = [
        r"call\s+([\w-]+)",
        r"chiama\s+([\w-]+)",
        r"use\s+([\w-]+)\s+agent",
        r"load\s+([\w-]+)\s+agent",
        r"switch\s+to\s+([\w-]+)",
    ]

    # Filter out common stop words that aren't agent names
    stop_words = {"the", "a", "an", "my", "our", "this", "that", "it", "me", "you", "us", "back", "him", "her", "them"}

    for pattern in patterns:
        match = re.search(pattern, prompt)
        if match:
            agent_name = match.group(1)
            if agent_name in stop_words:
                continue
            # UserPromptSubmit injects guidance via additionalContext, not "message".
            print(json.dumps({
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "additionalContext": (
                        f"The user is calling the '{agent_name}' agent. Read "
                        f"agents/{agent_name}.md first and respond AS that agent. "
                        f"Do NOT improvise its behavior. If the file does not exist, say so."
                    ),
                }
            }))
            return

    print(json.dumps({"continue": True}))

if __name__ == "__main__":
    main()
