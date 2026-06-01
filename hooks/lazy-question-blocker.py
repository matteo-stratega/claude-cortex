#!/usr/bin/env python3
"""
Hook: Lazy Question Blocker
Trigger: Stop
Purpose: Detects when Claude asks the user for something it could find itself,
         and pushes it to search autonomously first (CLAUDE.md rule: "Execute
         autonomously — only ask if critical info is missing").

Tune LAZY_PATTERNS to taste — if Claude should ask more freely in your
workflow, trim the list or remove this hook.
"""
import json
import sys
import re

LAZY_PATTERNS = [
    r"where (?:do I|can I) find",
    r"can you check",
    r"can you verify",
    r"can you confirm",
    r"do you have (?:the|a) link",
    r"could you (?:send|share|give) me",
    r"what plan are you on",
    r"can you (?:look|open|go to)",
    r"could you paste",
    r"what(?:'s| is) the (?:url|path|file name)",
]

TOOL_SUGGESTIONS = {
    "email": "an email/MCP search tool",
    "mail": "an email/MCP search tool",
    "link": "WebFetch or Grep",
    "url": "WebFetch",
    "file": "Glob / Grep / Read",
    "path": "Glob / Grep",
    "doc": "Glob / Read or WebFetch",
    "pricing": "WebFetch on the service's pricing page",
    "plan": "WebFetch on the service's pricing page",
    "api": "WebFetch on the API docs",
}


def find_relevant_tool(text):
    text_lower = text.lower()
    for keyword, tool in TOOL_SUGGESTIONS.items():
        if keyword in text_lower:
            return tool
    return "your available tools (Grep / Glob / Read / WebFetch / MCP)"


def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({}))
        return

    # Prevent infinite loops
    if hook_input.get("stop_hook_active"):
        print(json.dumps({}))
        return

    message = hook_input.get("last_assistant_message", "")
    if not message:
        print(json.dumps({}))
        return

    # Don't fire on meta/reflective statements about the pattern itself
    META_EXCLUSIONS = [
        r"(?:the )?pattern (?:is|was)",
        r"(?:the )?problem (?:is|was)",
        r"instead of",
        r"(?:I) (?:asked|said)",
        r"(?:example) (?:of|:)",
    ]
    for exc in META_EXCLUSIONS:
        if re.search(exc, message, re.IGNORECASE):
            print(json.dumps({}))
            return

    for pattern in LAZY_PATTERNS:
        match = re.search(pattern, message, re.IGNORECASE)
        if match:
            tool_hint = find_relevant_tool(message)
            print(json.dumps({
                "decision": "block",
                "reason": (
                    f"STOP — you just asked the user something you can likely answer yourself. "
                    f"Detected: '{match.group()}'. Use {tool_hint} to find it FIRST, "
                    f"then report what you found. Only ask the user if it is genuinely "
                    f"inaccessible to your tools."
                ),
            }))
            return

    print(json.dumps({}))


if __name__ == "__main__":
    main()
