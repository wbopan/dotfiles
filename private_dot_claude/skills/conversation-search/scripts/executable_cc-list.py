#!/usr/bin/env python3
"""List recent Claude Code sessions with summaries."""

import argparse
import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path


def decode_project_path(dirname: str) -> str:
    """Decode project dir name back to absolute path.

    Claude Code encodes paths by replacing / with - and prepending -.
    E.g. -Users-panwenbo-Repos-gepa -> /Users/panwenbo/Repos/gepa

    This is lossy if directory names contain hyphens, but it's the best we can do.
    We verify the decoded path exists and fall back to raw dirname if not.
    """
    candidate = "/" + dirname.lstrip("-").replace("-", "/")
    if os.path.isdir(candidate):
        return candidate
    # Fallback: try progressively merging segments with hyphens
    parts = dirname.lstrip("-").split("-")
    for i in range(len(parts) - 1, 0, -1):
        candidate = "/" + "/".join(parts[:i]) + "/" + "-".join(parts[i:])
        if os.path.isdir(candidate):
            return candidate
    return "/" + dirname.lstrip("-").replace("-", "/")


def parse_date_arg(date_str: str) -> datetime:
    """Parse date argument: 'yesterday', 'today', or YYYY-MM-DD."""
    if date_str == "today":
        return datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    elif date_str == "yesterday":
        return (datetime.now() - timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
    else:
        return datetime.strptime(date_str, "%Y-%m-%d")


def get_summary(filepath: Path) -> str:
    """Extract session summary from JSONL file.

    Fast path: check last 4KB for type=summary line.
    Fallback: scan forward for first type=user message content.
    """
    # Fast path: summary is usually the last line
    try:
        with open(filepath, "rb") as f:
            f.seek(0, 2)
            size = f.tell()
            f.seek(max(0, size - 4096))
            tail = f.read().decode("utf-8", errors="replace")
        for line in reversed(tail.strip().split("\n")):
            try:
                d = json.loads(line)
                if d.get("type") == "summary" and d.get("summary"):
                    return d["summary"][:120]
            except (json.JSONDecodeError, ValueError):
                continue
    except OSError:
        pass

    # Fallback: first user message
    try:
        with open(filepath, encoding="utf-8", errors="replace") as f:
            for line in f:
                try:
                    d = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if d.get("type") == "user":
                    msg = d.get("message", {})
                    content = msg.get("content", "")
                    text = ""
                    if isinstance(content, str):
                        text = content
                    elif isinstance(content, list):
                        for block in content:
                            if isinstance(block, dict) and block.get("type") == "text":
                                text = block.get("text", "")
                                break
                    # Skip XML-wrapped system messages
                    if text.startswith("<"):
                        continue
                    text = text.replace("\n", " ")[:120]
                    if text:
                        return text
    except OSError:
        pass

    return "(no summary)"


def main():
    parser = argparse.ArgumentParser(description="List recent Claude Code sessions")
    parser.add_argument("--days", type=int, default=7, help="Show sessions from last N days (default: 7)")
    parser.add_argument("--date", type=str, help="Specific date: yesterday, today, or YYYY-MM-DD")
    parser.add_argument("--limit", type=int, default=20, help="Max results (default: 20)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    projects_dir = Path.home() / ".claude" / "projects"
    if not projects_dir.exists():
        print("No conversations found: ~/.claude/projects/ does not exist", file=sys.stderr)
        sys.exit(1)

    # Determine time filter
    if args.date:
        date_start = parse_date_arg(args.date)
        date_end = date_start + timedelta(days=1)
        cutoff = date_start.timestamp()
        max_ts = date_end.timestamp()
    else:
        cutoff = (datetime.now() - timedelta(days=args.days)).timestamp()
        max_ts = None

    # Collect session files
    sessions = []
    for project_dir in projects_dir.iterdir():
        if not project_dir.is_dir():
            continue
        project_path = decode_project_path(project_dir.name)

        for f in project_dir.glob("*.jsonl"):
            mtime = f.stat().st_mtime
            if mtime < cutoff:
                continue
            if max_ts and mtime >= max_ts:
                continue

            sessions.append({
                "file": str(f),
                "session_id": f.stem,
                "project_path": project_path,
                "mtime": mtime,
            })

    # Sort by mtime descending
    sessions.sort(key=lambda s: s["mtime"], reverse=True)
    sessions = sessions[:args.limit]

    # Extract summaries
    results = []
    for s in sessions:
        dt = datetime.fromtimestamp(s["mtime"])
        summary = get_summary(Path(s["file"]))
        s["date"] = dt.strftime("%Y-%m-%d %H:%M")
        s["summary"] = summary
        results.append(s)

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        for r in results:
            print(f"{r['session_id']}  {r['project_path']}  {r['date']}  {r['summary']}")


if __name__ == "__main__":
    main()
