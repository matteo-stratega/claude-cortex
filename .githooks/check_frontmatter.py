#!/usr/bin/env python3
"""
Validate YAML frontmatter in the markdown files passed as arguments.
File paths arrive as argv — never interpolated into code — so filenames with
shell metacharacters are safe. Exits non-zero if any frontmatter is broken.
"""
import sys

try:
    import yaml  # PyYAML, optional
except ImportError:
    yaml = None


def frontmatter(text):
    """Return the YAML block between leading --- fences, or None."""
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 4)
    if end == -1:
        return None
    return text[4:end]


def main():
    rc = 0
    for path in sys.argv[1:]:
        try:
            with open(path, encoding="utf-8") as fh:
                text = fh.read()
        except OSError:
            continue
        block = frontmatter(text)
        if block is None:
            continue
        if yaml is not None:
            try:
                yaml.safe_load(block)
            except yaml.YAMLError as exc:
                print(f"BLOCKED: {path} — broken YAML frontmatter: {exc}")
                rc = 1
        else:
            # No PyYAML: minimal sanity check — top-level lines must be key: value.
            for line in block.splitlines():
                s = line.rstrip()
                if s and not line.startswith((" ", "\t", "-", "#")) and ":" not in s:
                    print(f"BLOCKED: {path} — frontmatter line is not key: value -> {s!r}")
                    rc = 1
    sys.exit(rc)


if __name__ == "__main__":
    main()
