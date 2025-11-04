function prune_vsct_tmux --description "Prune detached vsct* tmux sessions without active foreground jobs"
    if not type -q tmux
        echo "tmux command not found" >&2
        return 1
    end

    set -l sessions (tmux list-sessions -F "#{session_name}::#{session_attached}" 2>/dev/null)
    if test $status -ne 0
        # No server or unable to query sessions; nothing to prune.
        return 0
    end

    # Treat panes running only interactive shells as idle foreground state.
    set -l idle_commands fish bash zsh sh
    set -l killed 0

    for session in $sessions
        set -l parts (string split '::' $session)
        if test (count $parts) -lt 2
            continue
        end

        set -l name $parts[1]
        set -l attached $parts[2]

        if not string match -q 'vsct*' $name
            continue
        end

        if test -z "$attached"
            continue
        end

        if test $attached -gt 0
            continue
        end

        set -l panes (tmux list-panes -t "$name" -F "#{pane_current_command}" 2>/dev/null)
        if test $status -ne 0
            # Session disappeared between list and prune; skip.
            continue
        end

        set -l has_active 0
        for pane_cmd in $panes
            if test -z "$pane_cmd"
                # Empty command means shell waiting for input; treat as idle.
                continue
            end

            set -l lower_cmd (string lower $pane_cmd)
            if not contains -- $lower_cmd $idle_commands
                set has_active 1
                break
            end
        end

        if test $has_active -eq 0
            tmux kill-session -t "$name"
            if test $status -eq 0
                set killed (math $killed + 1)
            end
        end
    end
end
