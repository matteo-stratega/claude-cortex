#!/usr/bin/env python3
"""
Hook: Simplest Approach Enforcer
Trigger: PreToolUse
Purpose: Blocks overcomplicated tool usage when a simpler built-in exists.
         Catches the classic "spin up a browser to read a web page" reflex.
"""
import json
import sys
import re

BLOCKED_PATTERNS = {
    "Bash": [
        {
            "pattern": r"playwright|puppeteer|cypress|selenium",
            "reason": "Browser automation detected. To read a web page use WebFetch. "
                      "To edit files use Edit. To check built HTML use Read on the output file.",
            "suggestion": "WebFetch (read pages), Edit (modify files), Read (check output)",
        },
        {
            # Anchored to LAUNCHING a browser, not the word "chrome" anywhere
            # (so `grep chrome` or a container named chromium is not blocked).
            "pattern": r"open\s+-a\s+['\"]?(google chrome|chromium|safari)|\bgoogle-chrome\b|\bchromium-browser\b|chromium\s+--",
            "reason": "Opening a browser is almost never needed. To read web content use WebFetch. "
                      "To check built HTML use Read.",
            "suggestion": "WebFetch or Read",
        },
    ]
}


def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({}))
        return

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})

    if tool_name in BLOCKED_PATTERNS:
        check_text = tool_input.get("command", "") if tool_name == "Bash" else ""
        if check_text:
            for rule in BLOCKED_PATTERNS[tool_name]:
                if re.search(rule["pattern"], check_text, re.IGNORECASE):
                    print(json.dumps({
                        "hookSpecificOutput": {
                            "hookEventName": "PreToolUse",
                            "permissionDecision": "deny",
                            "permissionDecisionReason": (
                                f"Overcomplicated approach. {rule['reason']} "
                                f"Use instead: {rule['suggestion']}. "
                                f"Rule: always reach for the SIMPLEST tool first."
                            ),
                        }
                    }))
                    return

    print(json.dumps({}))


if __name__ == "__main__":
    main()
