#
# Zsh Configuration
#

#
# History
#

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_EXPIRE_DUPS_FIRST

#
# Input/output
#

# Set editor default keymap to emacs
bindkey -e

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

#
# zsh-autosuggestions
#

# Disable automatic widget re-binding on each precmd for performance.
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

#
# zsh-syntax-highlighting
#

# Set what highlighters will be used.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

#
# zsh-nvm
#

# Lazy load nvm to speed up shell startup.
export NVM_LAZY_LOAD=true

#
# Linuxbrew (must be before any `has` checks)
#

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

#
# Zim Framework
#

[[ -f ~/.profile ]] && source ~/.profile
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

#
# Post-init module configuration
#

# zsh-history-substring-search keybindings
zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

#
# Utility Functions
#

has() {
    command -v "$1" >/dev/null 2>&1
}

# Run commands in tmux session named after current directory
tx() {
    if [[ -n "$TMUX" ]]; then
        return 0
    fi

    if [[ $# -eq 0 ]]; then
        tmux new -As "${PWD:t}"
    else
        local window_name="run_${1}_$RANDOM"
        tmux new-session -s "$window_name" "$*; $SHELL"
    fi
}

#
# Aliases - Basic
#

alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'

# Conditional aliases
has code && alias c="code"
has cursor && alias c="cursor"
has open && alias o="open"
has nvim && alias vim="nvim"
has nvim && alias v="nvim"
has nvim && alias vf='nvim -c "Telescope frecency workspace=CWD"'
has nvim && alias vr='nvim -c "Telescope frecency"'
has lazygit && alias lg="lazygit"

#
# Aliases - Git
#

alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias glog='git log --oneline --graph --decorate -20'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gsw='git switch'
alias gb='git branch'
has docker && alias dc="docker compose"

alias claude='claude --allow-dangerously-skip-permissions'
alias cc='claude'

#
# Plugin Integrations
#

if has zoxide; then
    eval "$(zoxide init zsh --cmd cd)"
fi

if has uv; then
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi

export EDITOR=${commands[nvim]:-${commands[vim]:-vi}}

if has batcat; then
    alias bat='batcat'
fi

#
# VS Code Integration
#

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
    _vsc_zsh=$(code --locate-shell-integration-path zsh 2>/dev/null)
    if [[ -r "$_vsc_zsh" ]]; then
        source "$_vsc_zsh"
    fi

    __vsc_tmux_passthrough() {
        local payload="$1"
        local esc=$'\e'
        local doubled="${esc}${esc}"
        local safe="${payload//${esc}/${doubled}}"
        printf '\ePtmux;%s\e\\' "$safe"
    }

    if [[ -n "$TMUX" ]]; then
        __vsc_prompt_marks() {
            __vsc_tmux_passthrough $'\e]633;A\e\\'
            __vsc_tmux_passthrough $'\e]633;B\e\\'
            __vsc_tmux_passthrough "$(printf '\e]7;file://%s%s\e\\' "$(hostname)" "$(pwd)")"
        }
        precmd_functions+=(__vsc_prompt_marks)

        __vsc_pre() {
            __vsc_tmux_passthrough $'\e]633;C\e\\'
        }
        preexec_functions+=(__vsc_pre)

        __vsc_post() {
            __vsc_tmux_passthrough "$(printf '\e]633;D;exit=%d\e\\' "$?")"
        }
        precmd_functions+=(__vsc_post)
    fi
fi

#
# Notifications
#

notify() {
    local title="$1"
    local message="$2"

    # Normalize real newlines to spaces so OSC stays one line.
    local t="${title//$'\n'/ }"
    local m="${message//$'\n'/ }"

    # What terminal are we ultimately talking to?
    local termprog="${TERM_PROGRAM:l}"

    # Build the raw OSC payload for the outer terminal.
    local osc
    case "$termprog" in
        'iterm.app')
            if [[ -n "$m" ]]; then
                osc=$(printf '\e]9;%s\a' "$t: $m")
            else
                osc=$(printf '\e]9;%s\a' "$t")
            fi
            ;;
        ghostty|vscode|*)
            osc=$(printf '\e]777;notify;%s;%s\a' "$t" "$m")
            ;;
    esac

    # Are we running inside tmux?
    local in_tmux=0
    [[ -n "$TMUX" ]] && in_tmux=1

    # If inside tmux, check whether this session has any attached clients.
    if (( in_tmux )); then
        local attached
        attached=$(tmux display-message -p -t "$TMUX_PANE" '#{session_attached}' 2>/dev/null)
        [[ -z "$attached" ]] && attached=1

        if (( attached == 0 )); then
            # Detached: no GUI to receive OSC - send ntfy push and exit.
            command curl -s \
                -H "Title: $t" \
                -H "X-Markdown: yes" \
                -d "$m" \
                ntfy.sh/wenbo-R2osKWmlKv7gQh2m >/dev/null 2>&1
            return
        fi
    fi

    # We have an attached GUI terminal; emit OSC (wrap for tmux so it passes through).
    if (( in_tmux )); then
        local esc=$'\e'
        # Double ESC characters inside the payload so tmux passes them through.
        local safe="${osc//${esc}/${esc}${esc}}"
        printf '\ePtmux;%s\e\\' "$safe"
    else
        printf '%s' "$osc"
    fi
}

#
# Command Timer
#

typeset -g CMD_START_TIME=0
typeset -g CMD_NOTIFICATION_THRESHOLD=180

typeset -ga CMD_TIMER_WHITELIST=(
    brew npm yarn pnpm pip pip3 poetry bundle rails docker docker-compose
    kubectl helm terraform ansible-playbook make cmake ninja cargo go gradle
    mvn pytest tox rake rsync uv python python3 torchrun accelerate deepspeed
    huggingface-cli conda mamba pipx sbatch srun sleep
)

__cmd_timer_start() {
    CMD_START_TIME=$(date +%s)
}
preexec_functions+=(__cmd_timer_start)

__cmd_timer_end() {
    local last_status=$?
    local cmd="$1"

    if (( CMD_START_TIME > 0 )); then
        local end_time=$(date +%s)
        local duration=$((end_time - CMD_START_TIME))

        if (( duration >= CMD_NOTIFICATION_THRESHOLD && last_status != 130 && last_status != 131 )); then
            local minutes=$((duration / 60))
            local seconds=$((duration % 60))

            local cmd_name="${cmd%% *}"

            local is_whitelisted=false
            for whitelisted in "${CMD_TIMER_WHITELIST[@]}"; do
                if [[ "$cmd_name" == "$whitelisted"* ]]; then
                    is_whitelisted=true
                    break
                fi
            done

            if $is_whitelisted; then
                if (( ${#cmd} > 80 )); then
                    cmd="${cmd:0:77}..."
                fi
                notify "Command Completed" "\`$cmd\` finished ($last_status) after ${minutes}m ${seconds}s"
            fi
        fi

        CMD_START_TIME=0
    fi
}
precmd_functions+=(__cmd_timer_end)

#
# Proxy Detection
#

if has nc; then
    for port in 7899 7890 7891 17890; do
        if nc -z -w 2 localhost "$port" >/dev/null 2>&1; then
            export PROXY_PORT="$port"
            export ALL_PROXY="http://127.0.0.1:$port"
            export HTTP_PROXY="$ALL_PROXY"
            export HTTPS_PROXY="$ALL_PROXY"
            export NO_PROXY="localhost,127.0.0.1,::1"
            export no_proxy="$NO_PROXY"
            break
        fi
    done
fi

#
# Tmux Maintenance
#

prune_vsct_tmux() {
    if ! has tmux; then
        echo "tmux command not found" >&2
        return 1
    fi

    local sessions
    sessions=$(tmux list-sessions -F "#{session_name}::#{session_attached}" 2>/dev/null)
    [[ $? -ne 0 ]] && return 0

    # Treat panes running only interactive shells as idle foreground state.
    local idle_commands=(fish bash zsh sh)
    local killed=0

    local line
    while read -r line; do
        [[ -z "$line" ]] && continue
        # Split on :: using parameter expansion
        local name="${line%%::*}"
        local attached="${line##*::}"

        [[ "$name" != vsct* ]] && continue
        [[ -z "$attached" ]] && continue
        (( attached > 0 )) && continue

        local panes
        panes=$(tmux list-panes -t "$name" -F "#{pane_current_command}" 2>/dev/null)
        [[ $? -ne 0 ]] && continue

        local has_active=0
        while read -r pane_cmd; do
            [[ -z "$pane_cmd" ]] && continue
            local lower_cmd="${pane_cmd:l}"
            local is_idle=false
            for idle in "${idle_commands[@]}"; do
                if [[ "$lower_cmd" == "$idle" ]]; then
                    is_idle=true
                    break
                fi
            done
            if ! $is_idle; then
                has_active=1
                break
            fi
        done <<< "$panes"

        if (( has_active == 0 )); then
            tmux kill-session -t "$name" && ((killed++))
        fi
    done <<< "$sessions"
}

# Run on interactive shell startup (async to avoid blocking)
if [[ -o interactive ]]; then
    (prune_vsct_tmux >/dev/null 2>&1 &)
fi

#
# Health Check
#

health() {
    # Format: "name|check|install"
    # check: command to test, or "dir:path" for directory check
    # install: command to install
    local deps=(
        "brew|brew|/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        "zoxide|zoxide|brew install zoxide"
        "direnv|direnv|brew install direnv"
        "fzf|fzf|brew install fzf"
        "bat|bat|brew install bat"
        "eza|eza|brew install eza"
        "fd|fd|brew install fd"
        "tmux|tmux|brew install tmux"
        "uv|uv|brew install uv"
        "rg|rg|brew install ripgrep"
        "nvim|nvim|brew install neovim"
        "starship|starship|brew install starship"
        "tpm|dir:$HOME/.tmux/plugins/tpm|git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
        "op|op|brew install --cask 1password-cli"
        "gh|gh|brew install gh"
    )

    for dep in "${deps[@]}"; do
        IFS='|' read -r name check install <<< "$dep"

        local ok=0
        if [[ "$check" == dir:* ]]; then
            local dir="${check#dir:}"
            [[ -d "$dir" ]] && ok=1
        else
            command -v "$check" >/dev/null 2>&1 && ok=1
        fi

        if (( ok )); then
            printf "  [x] %s\n" "$name"
        else
            printf "  [ ] %s  ->  %s\n" "$name" "$install"
        fi
    done
}

#
# Ghostty Tab Commands
#

# Execute pending command on shell startup (used by ghostty-tab function)
if [[ -f /tmp/.ghostty_cmd ]]; then
    local __ghostty_cmd
    __ghostty_cmd=$(</tmp/.ghostty_cmd)
    rm -f /tmp/.ghostty_cmd
    eval "$__ghostty_cmd"
fi

# Open a new Ghostty tab with an optional command
# Usage: ghostty-tab "command"           # Opens tab in ~, runs command
#        ghostty-tab "command" ~/dir     # Opens tab in ~/dir, runs command
#        ghostty-tab "" ~/dir            # Opens tab in ~/dir, no command
ghostty-tab() {
    local cmd="$1"
    local dir="${2:-$HOME}"

    if [[ -n "$cmd" ]]; then
        printf '%s' "$cmd" > /tmp/.ghostty_cmd
    fi

    open -a Ghostty "$dir"
}

# Open Claude Code in a new Ghostty tab
# Usage: ghostty-claude              # Opens claude in ~/Repos/workspace
#        ghostty-claude "fix the bug" # Opens claude with initial query
ghostty-claude() {
    local query="$1"
    local cmd='clear && claude --dangerously-skip-permissions'

    if [[ -n "$query" ]]; then
        cmd+=" ${(qq)query}"
    fi

    cmd+=' && exit'
    ghostty-tab "$cmd" ~/Repos/workspace
}

# Added by Hugging Face CLI installer
export PATH="/Users/panwenbo/.local/bin:$PATH"

#
# Starship Prompt
#

if has starship; then
    eval "$(starship init zsh)"
fi
export PATH="$HOME/.npm-global/bin:$PATH"
