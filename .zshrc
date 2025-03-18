## Install Zinit if not already installed
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship

zi ice from"gh-r" as"program" mv"docker* -> docker-compose" bpick"*linux*"
zi light docker/compose
zi ice wait lucid
zi light oconnor663/zsh-sensible
zi ice wait lucid
zi light zsh-users/zsh-completions

# Load completions
autoload -Uz compinit && compinit
zi cdreplay -q

### Custom functions
has() { (( $+commands[$1] )) }
# Healthcheck function for zsh
healthcheck() {
    local plugins=(zoxide direnv fzf bat eza fd tmux uv rg nvim)
    for plugin in "${plugins[@]}"; do
        echo -n "    $plugin: "
        has "$plugin" && echo "✅" || echo "❌"
    done
}

### Common aliases
alias l="ls"
alias ll="ls -l"
alias la="ls -a"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
alias sctl='systemctl'
alias jctl='journalctl'
alias ssr='sudo systemctl restart'
alias sst='sudo systemctl start'
alias sss='sudo systemctl status'
alias ssj='sudo journalctl -xeu'
alias ssp='sudo systemctl stop'
has code && alias c="code"
has cursor && alias c="cursor"
has tmux && alias tmc='tmux new -As ${PWD:t}'
has nvim && alias vim="nvim"
has docker-compose && alias dc="docker-compose"

### Initialize plugins
has zoxide && eval "$(zoxide init zsh --cmd cd)"
has eza && alias ls='eza' && alias tree='eza --tree'
has fzf && source <(fzf --zsh)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
has direnv && eval "$(direnv hook zsh)"
has uv && eval "$(uv generate-shell-completion zsh)"
has uvx && eval "$(uvx --generate-shell-completion zsh)"
has vim && export EDITOR="vim" 
has nvim && export EDITOR="nvim"
