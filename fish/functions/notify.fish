function notify --description "Notify: ntfy when tmux detached, else OSC (with tmux passthrough if needed)"
    set -l title $argv[1]
    set -l message $argv[2]

    # Normalize real newlines to spaces so OSC stays one line.
    set -l t (string replace -a \n ' ' -- "$title")
    set -l m (string replace -a \n ' ' -- "$message")

    # What terminal are we ultimately talking to?
    set -l termprog (string lower -- (set -q TERM_PROGRAM; and echo $TERM_PROGRAM; or echo ""))

    # Build the raw OSC payload for the outer terminal.
    set -l osc
    switch $termprog
        case 'iterm.app'
            if test -n "$m"
                set osc (printf '\e]9;%s\a' "$t: $m")
            else
                set osc (printf '\e]9;%s\a' "$t")
            end
        case ghostty
            set osc (printf '\e]777;notify;%s;%s\a' "$t" "$m")
        case vscode
            set osc (printf '\e]777;notify;%s;%s\a' "$t" "$m")
        case '*'
            set osc (printf '\e]777;notify;%s;%s\a' "$t" "$m")
    end

    # Are we running inside tmux?
    set -l in_tmux 0
    if set -q TMUX
        set in_tmux 1
    end

    # If inside tmux, check whether this session has any attached clients.
    if test $in_tmux -eq 1
        set -l attached (tmux display-message -p -t "$TMUX_PANE" '#{session_attached}' 2>/dev/null)
        if test -z "$attached"
            set attached 1
        end

        if test $attached -eq 0
            # Detached: no GUI to receive OSC — send ntfy push and exit.
            command curl -s \
                -H "Title: $t" \
                -H "X-Markdown: yes" \
                -d "$m" \
                ntfy.sh/wenbo-R2osKWmlKv7gQh2m >/dev/null 2>&1
            return
        end
    end

    # We have an attached GUI terminal; emit OSC (wrap for tmux so it passes through).
    if test $in_tmux -eq 1
        set -l esc (printf '\e')
        # Double ESC characters inside the payload so tmux passes them through.
        set -l safe (string replace -a -- "$esc" "$esc$esc" "$osc")
        printf '\ePtmux;%s\e\\' "$safe"
    else
        printf '%s' "$osc"
    end
end
