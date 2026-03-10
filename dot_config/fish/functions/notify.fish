function notify --description 'Send desktop notification via OSC or ntfy'
    set -l title $argv[1]
    set -l message $argv[2]

    # Normalize newlines to spaces
    set title (string replace -a \n ' ' -- $title)
    set message (string replace -a \n ' ' -- $message)

    # What terminal are we talking to?
    set -l termprog (string lower -- $TERM_PROGRAM)

    # Build the raw OSC payload
    set -l osc
    switch $termprog
        case 'iterm.app'
            if test -n "$message"
                set osc (printf '\e]9;%s\a' "$title: $message")
            else
                set osc (printf '\e]9;%s\a' "$title")
            end
        case '*'
            set osc (printf '\e]777;notify;%s;%s\a' "$title" "$message")
    end

    # If in tmux, check if session is attached
    if set -q TMUX
        set -l attached (tmux display-message -p -t $TMUX_PANE '#{session_attached}' 2>/dev/null)
        if test -z "$attached"
            set attached 1
        end

        if test $attached -eq 0
            # Detached: send ntfy push
            command curl -s \
                -H "Title: $title" \
                -H "X-Markdown: yes" \
                -d "$message" \
                ntfy.sh/wenbo-R2osKWmlKv7gQh2m >/dev/null 2>&1
            return
        end
    end

    # Emit OSC (wrap for tmux passthrough)
    if set -q TMUX
        set -l safe (string replace -a \e \e\e -- $osc)
        printf '\ePtmux;%s\e\\' $safe
    else
        printf '%s' $osc
    end
end
