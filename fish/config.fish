# Utilities function
set -U fish_greeting ""
function has
    command -v $argv >/dev/null ^&1
end

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

has zoxide; and zoxide init fish --cmd cd | source
has direnv; and eval (direnv hook fish)
has uv; and eval (uv generate-shell-completion fish)

# Common aliases
alias l 'ls'
alias ll 'ls -l'
alias la 'ls -a'
alias grep 'grep --color=auto'
alias fgrep 'fgrep --color=auto'
alias egrep 'egrep --color=auto'
alias mkdir 'mkdir -p'
alias df 'df -h'
alias du 'du -h'
alias sctl 'systemctl'
alias jctl 'journalctl'
alias ssr 'sudo systemctl restart'
alias sst 'sudo systemctl start'
alias sss 'sudo systemctl status'
alias ssj 'sudo journalctl -xeu'
alias ssp 'sudo systemctl stop'
has code; and alias c "code"
has cursor; and alias c "cursor"
has nvim; and alias vim "nvim"
has docker-compose; and alias dc "docker-compose"

# Initialize plugins
has zoxide; and zoxide init fish --cmd cd | source
has eza; and alias ls 'eza'; and alias tree 'eza --tree'
has fzf; and fzf --fish | source
test -f ~/.fzf.fish; and source ~/.fzf.fish
has direnv; and direnv hook fish | source
has uv; and uv generate-shell-completion fish | source
has uvx; and uvx --generate-shell-completion fish | source
has vim; and set -x EDITOR "vim"
has nvim; and set -x EDITOR "nvim"
has batcat; and alias bat "batcat"
has starship; and starship init fish | source

# tx function

function tx
    if test -n "$TMUX"
        return 0
    end

    if test (count $argv) -eq 0
        tmux new -As (basename $PWD)
    else
        set window_name "run_$argv[1]_"(random)
        tmux new-session -s $window_name "$argv; $SHELL"
    end
end