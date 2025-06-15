# Healthcheck function adapted for fish
function healthcheck
    for plugin in zoxide direnv fzf bat eza fd tmux uv rg nvim starship
        if has $plugin
            echo "$plugin: ✅"
        else
            echo "$plugin: ❌"
        end
    end
end