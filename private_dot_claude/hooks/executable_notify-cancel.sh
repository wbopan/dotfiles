#!/bin/bash
PANE_KEY=$(echo "${TMUX_PANE:-$$}" | tr -d '%')
DIR="/tmp/claude-notify"
PIDFILE="$DIR/${PANE_KEY}.pid"
[ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null || true
rm -f "$PIDFILE" "$DIR/${PANE_KEY}.pending"
