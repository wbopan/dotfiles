#!/bin/bash
set -euo pipefail

INPUT=$(cat)

EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // empty')

# Get pane title from tmux, fallback to cwd basename
PANE_TITLE=""
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
    PANE_TITLE=$(tmux display-message -t "${TMUX_PANE}" -p '#{pane_title}' 2>/dev/null || true)
    # Strip leading spinner characters (e.g. ⠐ )
    PANE_TITLE=$(echo "$PANE_TITLE" | sed 's/^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏⠐⠑⠒⠓⠔⠕⠖⠗⠘⠚⠛⠜⠝⠞⠟ ]*//')
fi
if [ -z "$PANE_TITLE" ] && [ -n "$CWD" ]; then
    PANE_TITLE=$(basename "$CWD")
fi

# Build message based on event
MSG=""
case "$EVENT" in
    Stop)
        [ "$STOP_ACTIVE" = "true" ] && exit 0
        MSG="Task completed"
        ;;
    Notification)
        NOTIF_MSG=$(echo "$INPUT" | jq -r '.message // empty')
        NOTIF_TYPE=$(echo "$INPUT" | jq -r '.notification_type // .type // empty')
        if [ -n "$NOTIF_MSG" ]; then
            MSG="$NOTIF_MSG"
        else
            case "$NOTIF_TYPE" in
                permission_prompt)  MSG="Permission needed" ;;
                elicitation_dialog) MSG="Input requested" ;;
                idle_prompt)        MSG="Waiting for input" ;;
                *)                  MSG="Attention needed" ;;
            esac
        fi
        ;;
    *)
        exit 0
        ;;
esac

TITLE="${PANE_TITLE:-Claude Code}"

# Build tmux switch command for click-to-jump
EXECUTE_CMD=""
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
    TMUX_SOCKET=$(echo "$TMUX" | cut -d, -f1)
    EXECUTE_CMD="tmux -S '${TMUX_SOCKET}' select-window -t '${TMUX_PANE}' && tmux -S '${TMUX_SOCKET}' select-pane -t '${TMUX_PANE}'"
fi

# Detect terminal app bundle ID for -activate (bring terminal to front)
BUNDLE_ID=""
TERM_APP="${TERM_PROGRAM:-}"
if [ -n "${TMUX:-}" ]; then
    TERM_APP=$(tmux show-environment TERM_PROGRAM 2>/dev/null | sed 's/^TERM_PROGRAM=//' || echo "")
fi
case "$TERM_APP" in
    ghostty)        BUNDLE_ID="com.mitchellh.ghostty" ;;
    Apple_Terminal)  BUNDLE_ID="com.apple.Terminal" ;;
    iTerm.app)      BUNDLE_ID="com.googlecode.iterm2" ;;
    WezTerm)        BUNDLE_ID="com.github.wez.wezterm" ;;
    alacritty)      BUNDLE_ID="org.alacritty" ;;
esac

# Delayed notification: wait 30s, cancel if user resumes interaction
NOTIFY_DIR="/tmp/claude-notify"
mkdir -p "$NOTIFY_DIR"
PANE_KEY=$(echo "${TMUX_PANE:-$$}" | tr -d '%')
PENDING="$NOTIFY_DIR/${PANE_KEY}.pending"
PIDFILE="$NOTIFY_DIR/${PANE_KEY}.pid"

# Kill previous pending notification for this pane
if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null || true
    rm -f "$PIDFILE"
fi

# Write notification params to pending file
jq -n --arg t "$TITLE" --arg m "$MSG" --arg b "$BUNDLE_ID" --arg e "$EXECUTE_CMD" \
    '{title:$t,message:$m,bundle_id:$b,execute_cmd:$e}' > "$PENDING"

# Spawn fully detached delayed notifier
(
    sleep 30
    [ -f "$PENDING" ] || exit 0
    DATA=$(cat "$PENDING")
    rm -f "$PENDING" "$PIDFILE"
    N_TITLE=$(echo "$DATA" | jq -r '.title')
    N_MSG=$(echo "$DATA" | jq -r '.message')
    N_BUNDLE=$(echo "$DATA" | jq -r '.bundle_id')
    N_EXEC=$(echo "$DATA" | jq -r '.execute_cmd')
    ARGS=(-title "$N_TITLE" -message "$N_MSG" -sound default)
    [ -n "$N_BUNDLE" ] && ARGS+=(-activate "$N_BUNDLE")
    [ -n "$N_EXEC" ] && ARGS+=(-execute "$N_EXEC")
    terminal-notifier "${ARGS[@]}" >/dev/null 2>&1
) </dev/null >/dev/null 2>&1 &
disown $!

echo $! > "$PIDFILE"
