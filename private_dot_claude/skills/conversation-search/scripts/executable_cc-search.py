#!/usr/bin/env python3
"""Search Claude Code conversation content using rg + JSON parsing."""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from datetime import datetime, timedelta
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


def parse_date_arg(date_str: str) -> datetime:
    """Parse date argument: 'yesterday', 'today', or YYYY-MM-DD."""
    if date_str == "today":
        return datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    elif date_str == "yesterday":
        return (datetime.now() - timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
    else:
        return datetime.strptime(date_str, "%Y-%m-%d")


def extract_text(content) -> str:
    """Extract plain text from message content (string or content block array)."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict):
                if block.get("type") == "text":
                    parts.append(block.get("text", ""))
                elif block.get("type") == "tool_use":
                    parts.append(f"[Tool: {block.get('name', '')}]")
        return "\n".join(parts)
    return ""


def rg_prefilter(query: str, projects_dir: Path, cutoff_ts: float = 0, max_ts: float = 0) -> list[str]:
    """Use rg to quickly find files containing the query."""
    cmd = [
        "rg", "-l", "-F", "--no-messages",
        "--glob", "*.jsonl",
        "--glob", "!**/subagents/**",
        query,
        str(projects_dir),
    ]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        files = [f for f in result.stdout.strip().split("\n") if f]
    except (subprocess.TimeoutExpired, FileNotFoundError):
        # Fallback: no pre-filter, scan all
        files = [str(f) for f in projects_dir.rglob("*.jsonl") if "/subagents/" not in str(f)]

    # Apply time filter
    if cutoff_ts or max_ts:
        filtered = []
        for f in files:
            try:
                mtime = os.path.getmtime(f)
                if cutoff_ts and mtime < cutoff_ts:
                    continue
                if max_ts and mtime >= max_ts:
                    continue
                filtered.append(f)
            except OSError:
                continue
        files = filtered

    return files


def search_file(filepath: str, query: str, user_only: bool) -> list[dict]:
    """Search a JSONL file for messages containing the query."""
    matches = []
    query_lower = query.lower()

    try:
        f = open(filepath, encoding="utf-8", errors="replace")
    except OSError:
        return matches

    with f:
        for line in f:
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg_type = d.get("type")
            if msg_type not in ("user", "assistant"):
                continue
            if user_only and msg_type != "user":
                continue

            content = extract_text(d.get("message", {}).get("content", ""))
            if query_lower not in content.lower():
                continue

            # Find match position for snippet
            idx = content.lower().find(query_lower)
            start = max(0, idx - 40)
            end = min(len(content), idx + len(query) + 40)
            snippet = content[start:end].replace("\n", " ")
            if start > 0:
                snippet = "..." + snippet
            if end < len(content):
                snippet = snippet + "..."

            ts = d.get("timestamp", "")
            try:
                dt = datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone()
                date_str = dt.strftime("%Y-%m-%d %H:%M")
            except (ValueError, AttributeError):
                date_str = ts[:16] if ts else "unknown"

            matches.append({
                "session_id": d.get("sessionId", Path(filepath).stem),
                "project_path": decode_project_path(Path(filepath).parent.name),
                "timestamp": date_str,
                "role": msg_type,
                "snippet": snippet,
                "uuid": d.get("uuid", ""),
            })

    return matches


def main():
    parser = argparse.ArgumentParser(description="Search Claude Code conversations")
    parser.add_argument("query", help="Search query")
    parser.add_argument("--days", type=int, default=30, help="Search last N days (default: 30)")
    parser.add_argument("--date", type=str, help="Specific date: yesterday, today, or YYYY-MM-DD")
    parser.add_argument("--user-only", action="store_true", help="Only search user messages")
    parser.add_argument("--limit", type=int, default=20, help="Max results (default: 20)")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    args = parser.parse_args()

    projects_dir = Path.home() / ".claude" / "projects"
    if not projects_dir.exists():
        print("No conversations found: ~/.claude/projects/ does not exist", file=sys.stderr)
        sys.exit(1)

    # Time filter
    if args.date:
        date_start = parse_date_arg(args.date)
        date_end = date_start + timedelta(days=1)
        cutoff = date_start.timestamp()
        max_ts = date_end.timestamp()
    else:
        cutoff = (datetime.now() - timedelta(days=args.days)).timestamp()
        max_ts = 0

    # Pre-filter with rg
    files = rg_prefilter(args.query, projects_dir, cutoff, max_ts)

    if not files:
        if args.json:
            print("[]")
        else:
            print(f"No matches for '{args.query}'", file=sys.stderr)
        sys.exit(0)

    # Search each file
    all_matches = []
    for filepath in files:
        matches = search_file(filepath, args.query, args.user_only)
        all_matches.extend(matches)
        if len(all_matches) >= args.limit:
            break

    all_matches = all_matches[:args.limit]

    if args.json:
        print(json.dumps(all_matches, indent=2))
    else:
        for m in all_matches:
            role_icon = "U" if m["role"] == "user" else "A"
            print(f"{m['session_id'][:8]}  {m['timestamp']}  [{role_icon}]  {m['snippet']}")


if __name__ == "__main__":
    main()
