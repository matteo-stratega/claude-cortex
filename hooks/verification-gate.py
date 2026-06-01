#!/usr/bin/env python3
"""
Hook: Verification Gate
Trigger: Stop
Purpose: When Claude claims it JUST completed something, block unless it
         included verification evidence (build/test output, HTTP status, a
         grep/read of the result, etc.).

Only fires on ACTIVE completion claims ("I just deployed", "it's done"),
NOT on status reports, lists, or references to past/pending work.
"""
import json
import sys
import re

# Claude claiming it JUST did something (first-person / active voice).
ACTIVE_COMPLETION = [
    r"\bi (?:just |have )?(?:done|completed|finished|deployed|published|implemented|configured|shipped|fixed)\b",
    r"\bit'?s (?:done|ready|live|deployed|working)\b(?!.*(?:from |in the |previous|session|context))",
    r"\bjust (?:finished|completed|deployed|shipped|pushed)\b",
    r"\b(?:all )?(?:set|done)\b[.!](?!.*(?:pending|todo|next))",
]

VERIFICATION_EVIDENCE = [
    r"build (?:succeeded|passed|output|log)",
    r"npm run build",
    r"test(?:s)? (?:passed|pass|result|output|green)",
    r"HTTP[_ ]?(?:200|201|204|301|302)",
    r"status[: ]+(?:200|201|204)",
    r"curl .+(?:200|OK)",
    r"[✓✅]|PASS",
    r"verified|confirmed",
    r"output (?:shows|confirms)",
    r"result:",
    r"(?:line) \d+",
    r"(?:file|snippet|html) contains",
    r"tested (?:with|by|via)",
    r"screenshot",
    r"log shows",
    r"WebFetch (?:confirms|shows|returned)",
    r"Grep (?:found|confirms|shows)",
    r"Read .*line \d+",
    r"exit (?:code )?0",
]

# Signals that this is a status report, not a fresh completion claim.
STATUS_REPORT_INDICATORS = [
    r"from context",
    r"previous session",
    r"closing report",
    r"pending",
    r"(?:needs|requires|still to)",
    r"^\d+\.\s",        # numbered lists
    r"^[-•]\s",    # bullet lists
    r"\|\s*\w+\s*\|",   # markdown tables
]


def is_active_completion(text):
    text_lower = text.lower()
    for indicator in STATUS_REPORT_INDICATORS:
        if re.search(indicator, text_lower, re.MULTILINE):
            return False
    for pattern in ACTIVE_COMPLETION:
        if re.search(pattern, text_lower):
            return True
    return False


def has_verification(text):
    for pattern in VERIFICATION_EVIDENCE:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    return False


def main():
    try:
        hook_input = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, Exception):
        print(json.dumps({}))
        return

    if hook_input.get("stop_hook_active"):
        print(json.dumps({}))
        return

    message = hook_input.get("last_assistant_message", "")
    if not message or len(message) <= 30:
        print(json.dumps({}))
        return

    if is_active_completion(message) and not has_verification(message):
        print(json.dumps({
            "decision": "block",
            "reason": (
                "STOP — you claimed you just completed something but included NO verification. "
                "Before reporting it as done: (1) run the build/test, (2) check the output, "
                "(3) include the evidence. Go verify now."
            ),
        }))
        return

    print(json.dumps({}))


if __name__ == "__main__":
    main()
