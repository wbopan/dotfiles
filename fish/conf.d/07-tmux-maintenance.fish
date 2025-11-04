# Tmux housekeeping: prune leftover VS Code Tunnels sessions on shell start
if status --is-interactive
    if functions -q prune_vsct_tmux
        prune_vsct_tmux
    end
end
