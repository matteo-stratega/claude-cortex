#!/usr/bin/env python3
"""
Hook: Context Auto-Save Reminder
Trigger: Stop (end of assistant turn)
Purpose: Reminds Claude to update context when running /close.
Only fires when /close is detected — doesn't spam on every response.

Setup: Add to .claude/settings.json under hooks.Stop
"""
import json
import sys

def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({"continue": True}))
        return

    # Check multiple possible payload shapes for /close indicators
    should_remind = False
    close_indicators = ["/close", "session close", "close session"]

    # Check message field
    message = hook_input.get("message", "")
    if isinstance(message, str) and any(ind in message.lower() for ind in close_indicators):
        should_remind = True

    # Check transcript if available (may be string or list)
    transcript = hook_input.get("transcript_so_far", hook_input.get("transcript", ""))
    if isinstance(transcript, str) and any(ind in transcript.lower() for ind in close_indicators):
        should_remind = True
    elif isinstance(transcript, list):
        for entry in transcript:
            text = entry if isinstance(entry, str) else (entry.get("content", "") if isinstance(entry, dict) else str(entry))
            if any(ind in text.lower() for ind in close_indicators):
                should_remind = True
                break

    if should_remind:
        # systemMessage surfaces the reminder; "message" is not a real field,
        # and we don't want to block the Stop event.
        result = {
            "systemMessage": "Closing: update brain/context.md (remove completed, add priorities) and save durable learnings to memory."
        }
    else:
        result = {}

    print(json.dumps(result))

if __name__ == "__main__":
    main()
