#!/usr/bin/env python3
"""
Hook: Context Auto-Save Reminder
Trigger: Stop (end of assistant turn)
Purpose: Reminds Claude to update context when closing a session.

Only fires when the conversation involves /close — doesn't spam on every response.

Setup: Add to .claude/settings.json under hooks.Stop
"""
import json
import sys

def main():
    hook_input = json.loads(sys.stdin.read())

    # Get the transcript or recent messages to check if /close was mentioned
    # The stop_reason helps determine if this is a natural end
    transcript = hook_input.get("transcript_so_far", "")
    last_message = hook_input.get("message", "")

    # Only remind if /close was mentioned in the conversation
    close_indicators = ["/close", "session close", "chiudi sessione", "close session"]
    should_remind = any(indicator in transcript.lower() or indicator in last_message.lower()
                       for indicator in close_indicators)

    if should_remind:
        result = {
            "continue": True,
            "message": "REMINDER: Update brain/context.md — remove completed items, add new priorities, update statuses. Context is a snapshot, not a log."
        }
    else:
        result = {"continue": True}

    print(json.dumps(result))

if __name__ == "__main__":
    main()
