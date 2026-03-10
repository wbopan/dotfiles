#
# Fish Configuration
#

#
# PATH
#

fish_add_path -gP /usr/bin /bin /usr/sbin /sbin
fish_add_path -gP /opt/homebrew/bin /usr/local/bin
fish_add_path -gP $HOME/.npm-global/bin $HOME/.local/bin $HOME/bin

#
# Environment Variables
#

set -gx PYTHONBREAKPOINT "ipdb.set_trace"

if command -q nvim
    set -gx EDITOR nvim
else if command -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end

#
# Linuxbrew
#

if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)
end

#
# Aliases - Basic
#

alias l 'ls'
alias ll 'ls -l'
alias la 'ls -a'
alias mkdir 'mkdir -p'
alias df 'df -h'
alias du 'du -h'

command -q code; and alias c 'code'
command -q cursor; and alias c 'cursor'
command -q open; and alias o 'open'
command -q nvim; and alias vim 'nvim'
command -q nvim; and alias v 'nvim'
command -q nvim; and alias vf 'nvim -c "Telescope frecency workspace=CWD"'
command -q nvim; and alias vr 'nvim -c "Telescope frecency"'
command -q lazygit; and alias lg 'lazygit'

#
# Aliases - Git
#

alias gs 'git status'
alias gd 'git diff'
alias gds 'git diff --staged'
alias glog 'git log --oneline --graph --decorate -20'
alias ga 'git add'
alias gc 'git commit'
alias gp 'git push'
alias gl 'git pull'
alias gco 'git checkout'
alias gsw 'git switch'
alias gb 'git branch'
command -q docker; and alias dc 'docker compose'
alias claude 'claude --dangerously-skip-permissions'
alias cc 'claude'

#
# batcat alias (for Linux)
#

command -q batcat; and alias bat 'batcat'

#
# Plugin Integrations
#

if command -q zoxide
    zoxide init fish --cmd cd | source
end

if command -q uv
    uv generate-shell-completion fish | source
    uvx --generate-shell-completion fish | source
end

#
# VS Code Integration
#

if test "$TERM_PROGRAM" = vscode
    if command -q code
        set -l _vsc_fish (code --locate-shell-integration-path fish 2>/dev/null)
        if test -n "$_vsc_fish"; and test -r "$_vsc_fish"
            source "$_vsc_fish"
        end
    end
end

#
# Proxy Detection (async to avoid blocking startup)
#

if status is-interactive; and command -q nc
    fish -c '
        for port in 7899 7890 7891 17890
            if nc -z -w 1 localhost $port >/dev/null 2>&1
                set -U PROXY_PORT $port
                set -Ux ALL_PROXY "http://127.0.0.1:$port"
                set -Ux HTTP_PROXY "http://127.0.0.1:$port"
                set -Ux HTTPS_PROXY "http://127.0.0.1:$port"
                set -Ux NO_PROXY "localhost,127.0.0.1,::1"
                set -Ux no_proxy "localhost,127.0.0.1,::1"
                exit
            end
        end
        # No proxy found — clear any stale universal vars
        set -e PROXY_PORT; set -e ALL_PROXY; set -e HTTP_PROXY
        set -e HTTPS_PROXY; set -e NO_PROXY; set -e no_proxy
    ' &
end

#
# Ghostty Tab Commands
#

set -l _ghostty_cmd_file "$TMPDIR/.ghostty_cmd"
if test -f "$_ghostty_cmd_file"
    set -l __ghostty_cmd (cat "$_ghostty_cmd_file")
    rm -f "$_ghostty_cmd_file"
    eval $__ghostty_cmd
end

#
# Starship Prompt
#

if command -q starship
    starship init fish | source
end

#
# Command Timer
#

set -g CMD_NOTIFICATION_THRESHOLD 180
set -g CMD_TIMER_WHITELIST \
    brew npm yarn pnpm pip pip3 poetry bundle rails docker docker-compose \
    kubectl helm terraform ansible-playbook make cmake ninja cargo go gradle \
    mvn pytest tox rake rsync uv python python3 torchrun accelerate deepspeed \
    huggingface-cli conda mamba pipx sbatch srun sleep

function __cmd_timer_start --on-event fish_preexec
    set -g CMD_LAST_STATUS $status
    set -g CMD_LAST_CMD "$argv"
end

function __cmd_timer_end --on-event fish_postexec
    set -l last_status $CMD_LAST_STATUS
    set -l cmd $CMD_LAST_CMD
    set -l duration_sec (math "$CMD_DURATION / 1000")

    if test $duration_sec -ge $CMD_NOTIFICATION_THRESHOLD; and test $last_status -ne 130; and test $last_status -ne 131
        set -l minutes (math "floor($duration_sec / 60)")
        set -l seconds (math "$duration_sec % 60")
        set -l cmd_name (string split ' ' -- $cmd)[1]

        if contains -- $cmd_name $CMD_TIMER_WHITELIST
            if test (string length -- $cmd) -gt 80
                set cmd (string sub -l 77 -- $cmd)"..."
            end
            notify "Command Completed" "`$cmd` finished ($last_status) after {$minutes}m {$seconds}s"
        end
    end
end
