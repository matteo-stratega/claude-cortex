#!/usr/bin/env python3
"""
Hook: Agent Call Enforcer
Trigger: UserPromptSubmit
Purpose: Forces reading agent files when user calls an agent.

Setup: Add to .claude/settings.json under hooks.UserPromptSubmit
"""
import json
import os
import sys
import re

# Where agent definitions can live: the project clone, a project's .claude/,
# and the plugin install (this file's parent directory).
AGENT_DIRS = [
    os.path.join(os.getcwd(), "agents"),
    os.path.join(os.getcwd(), ".claude", "agents"),
    os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "agents"),
]


def agent_exists(name):
    return any(os.path.isfile(os.path.join(d, f"{name}.md")) for d in AGENT_DIRS)

def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({"continue": True}))
        return

    # UserPromptSubmit delivers the user's text in "prompt" (not "message").
    prompt = hook_input.get("prompt", "").lower()

    patterns = [
        r"\bcall\s+([\w-]+)",
        r"\bchiama\s+([\w-]+)",
        r"\buse\s+([\w-]+)\s+agent",
        r"\bload\s+([\w-]+)\s+agent",
        r"\bswitch\s+to\s+([\w-]+)",
    ]

    # Filter out common stop words that aren't agent names
    stop_words = {"the", "a", "an", "my", "our", "this", "that", "it", "me", "you", "us", "back", "him", "her", "them"}

    for pattern in patterns:
        match = re.search(pattern, prompt)
        if match:
            agent_name = match.group(1)
            if agent_name in stop_words:
                continue
            # Only route to agents that exist. Prompts often carry prose like
            # "each tool call wastes a round-trip"; without this check that
            # becomes an instruction to impersonate a 'wastes' agent.
            if not agent_exists(agent_name):
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
