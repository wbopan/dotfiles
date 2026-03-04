#!/bin/sh
# SSH-aware tmux pane splitting.
# Usage: ssh-split.sh <pane_pid> <-v|-h>
#
# Detects the SSH command running in the pane and opens a new split
# with the same SSH connection. Falls back to a plain shell if
# the SSH command can't be determined.
#
# Handles two process tree layouts:
#   1. shell(pane_pid) -> ssh  (normal: user typed ssh in shell)
#   2. ssh(pane_pid)           (split-created: tmux started ssh directly)

pane_pid="$1"
direction="$2"

# Case 1: SSH is a child of the pane's shell
ssh_cmd=$(ps -ww -o args= -p $(pgrep -P "$pane_pid" 2>/dev/null) 2>/dev/null | grep '^ssh' | head -1)

# Case 2: pane_pid itself is the SSH process (e.g., from a previous split)
if [ -z "$ssh_cmd" ]; then
    ssh_cmd=$(ps -ww -o args= -p "$pane_pid" 2>/dev/null | grep '^ssh' | head -1)
fi

if [ -n "$ssh_cmd" ]; then
    tmux split-window "$direction" "$ssh_cmd"
else
    tmux split-window "$direction"
fi
