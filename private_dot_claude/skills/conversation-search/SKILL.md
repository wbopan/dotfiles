---
name: conversation-search
description: Find, search, and resume past Claude Code conversations by topic, keyword, or date. Returns session IDs and project paths for resumption via 'claude --resume'. ALWAYS use this skill when the user wants to recall, find, or review past Claude Code sessions. Triggers on "find that conversation about X", "what did we discuss", "what did we work on yesterday", "show this week's sessions", "resume that session about Y", "how many conversations did I have", "continue where we left off", or any request to locate past work by topic, date, or time period. NOT for file search, code search, or building search features.
---

# Conversation Search

Find past conversations in your Claude Code history and get resume commands. Uses rg + Python scripts directly on the JSONL files. No database, no indexing, no external tools.

**Requires**: Python 3.9+, ripgrep (`rg`). If `rg` is not installed, cc-search.py falls back to pure-Python glob, but search will be slower on large histories.

## Scripts

All scripts are at `~/.claude/skills/conversation-search/scripts/`. Run with python3.

- **cc-list.py** - List recent sessions with summaries
- **cc-search.py** - Search message content across sessions (rg pre-filter + JSON parse)
- **cc-resume.py** - Generate resume command from session ID

## Workflow

### Step 1: Classify the Query

If the query has both temporal and topical signals, default to hybrid. If unsure, run both cc-list and cc-search.

| Type | Signal | Example |
|------|--------|---------|
| **Temporal** | Time reference, no topic | "What did we work on yesterday?" |
| **Topic** | Content keyword, no time | "Find that conversation about GEPA" |
| **Hybrid** | Topic + time | "Yesterday's auth work" |

### Step 2: Execute Search

**Temporal queries:**
```bash
python3 ~/.claude/skills/conversation-search/scripts/cc-list.py --date yesterday
python3 ~/.claude/skills/conversation-search/scripts/cc-list.py --days 7 --limit 10
```

Example output:
```
f827b006-d91f-4d76-a771-701335bdefc3  /Users/panwenbo/Vaults  2026-03-02 17:17  检查一下这个 rap 详细的了解一下它
699f39ee-5b00-4dd2-9bac-7e365b0d4c4a  /Users/panwenbo/Repos/dotfiles  2026-03-02 17:16  现在的 dotfile 使用非常简单的方法来同步和更新
```

**Topic queries:**
```bash
python3 ~/.claude/skills/conversation-search/scripts/cc-search.py "search terms" --days 30
```

Example output:
```
516ddca7  2026-01-31 12:58  [A]  ...自然利用 GEPA 已有的 per-instance Pareto 追踪  ## 3. Curri...
fd3ca41f  2026-02-24 09:30  [A]  ... with:  - `document.md` -- copied from "GEPA-Memory Design.md"...
```

**Hybrid queries:**
```bash
python3 ~/.claude/skills/conversation-search/scripts/cc-search.py "search terms" --date yesterday
```

All scripts support `--json` for structured output and `--limit N`.

### Step 3: Escalate if Needed

The rg pre-filter uses exact literal match, so initial searches can miss case variants or synonyms. If the first search returns nothing:

- **Drop date filter**: remove `--date`, increase `--days`
- **Try synonyms**: "auth" vs "authentication", "db" vs "database"
- **Broaden scope**: `--days 90`
- **Raw rg fallback**: `rg -l -F "keyword" ~/.claude/projects/ --glob '*.jsonl' --glob '!**/subagents/**'`

### Step 4: Generate Resume Command

```bash
python3 ~/.claude/skills/conversation-search/scripts/cc-resume.py SESSION_ID
```

Example output:
```
cd /Users/panwenbo/Vaults && claude --resume 34456c26-e124-486e-9a6c-81f57374eaa4
```

## Present Results

For each found session, present:

```
**Session**: f827b006-d91f-4d76-a771-701335bdefc3
**Project**: /Users/panwenbo/Vaults
**Time**: 2026-03-02 17:17
**Summary**: 检查一下这个 rap 详细的了解一下它

Resume: `cd /Users/panwenbo/Vaults && claude --resume f827b006-d91f-4d76-a771-701335bdefc3`
```

If nothing found after escalation: report that and suggest `--days 90` or manual browsing.

## Tips

**Storage format**: Conversations are JSONL files at `~/.claude/projects/{encoded-path}/{sessionId}.jsonl`. Directory names encode project paths with `-` separators (e.g., `-Users-panwenbo-Repos-gepa` = `/Users/panwenbo/Repos/gepa`). This encoding is lossy for paths containing hyphens; scripts verify against the filesystem and fall back to best-effort decoding.

**Summary coverage**: Only ~30% of session files have an explicit summary line. The scripts fall back to the first user message content.

**Raw rg for quick checks**: When you just need to confirm a keyword exists somewhere. Use `-F` for literal string matching (avoids regex interpretation of special characters like `[`, `(`, `.`):
```bash
rg -l -F "keyword" ~/.claude/projects/ --glob '*.jsonl' --glob '!**/subagents/**'
```

**Context around a match**: Read surrounding lines in a specific file:
```bash
rg -n -C3 "keyword" /path/to/session.jsonl
```

**User-only search**: Use `--user-only` flag on cc-search.py to skip assistant messages (avoids tool output noise).

**Large result sets**: Pipe `--json` output through jq for further filtering:
```bash
python3 ~/.claude/skills/conversation-search/scripts/cc-search.py "keyword" --json | jq '[.[] | select(.role == "user")]'
```
