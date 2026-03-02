#!/usr/bin/env python3
"""Generate claude --resume command from session ID or file path."""

from __future__ import annotations

import os
import sys
from pathlib import Path


def decode_project_path(dirname: str) -> str:
    """Decode project dir name back to absolute path."""
    candidate = "/" + dirname.lstrip("-").replace("-", "/")
    if os.path.isdir(candidate):
        return candidate
    parts = dirname.lstrip("-").split("-")
    for i in range(len(parts) - 1, 0, -1):
        candidate = "/" + "/".join(parts[:i]) + "/" + "-".join(parts[i:])
        if os.path.isdir(candidate):
            return candidate
    return "/" + dirname.lstrip("-").replace("-", "/")


def find_session_file(session_id: str) -> tuple[str, str] | None:
    """Find JSONL file for a session ID (full or prefix).

    Returns (session_id, project_path) or None.
    """
    projects_dir = Path.home() / ".claude" / "projects"
    if not projects_dir.exists():
        return None

    for project_dir in projects_dir.iterdir():
        if not project_dir.is_dir():
            continue
        for f in project_dir.glob("*.jsonl"):
            if f.stem == session_id or f.stem.startswith(session_id):
                project_path = decode_project_path(project_dir.name)
                return (f.stem, project_path)
    return None


def main():
    if len(sys.argv) < 2:
        print("Usage: cc-resume.py <SESSION_ID_OR_FILE_PATH>", file=sys.stderr)
        sys.exit(1)

    arg = sys.argv[1]

    # Check if it's a file path
    if os.path.isfile(arg):
        p = Path(arg)
        session_id = p.stem
        project_path = decode_project_path(p.parent.name)
    else:
        # Treat as session ID (full or prefix)
        result = find_session_file(arg)
        if not result:
            print(f"Session not found: {arg}", file=sys.stderr)
            sys.exit(1)
        session_id, project_path = result

    import shlex
    print(f"cd {shlex.quote(project_path)} && claude --resume {shlex.quote(session_id)}")


if __name__ == "__main__":
    main()
