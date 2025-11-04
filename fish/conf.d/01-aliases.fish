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

# Conditional aliases based on available commands
has code; and alias c "code"
has cursor; and alias c "cursor"
has open; and alias o "open"
has nvim; and alias vim "nvim"
has nvim; and alias v "nvim"
has nvim; and has fzf; and alias vf "nvim -c 'Telescope find_files'"
has docker-compose; and alias dc "docker-compose"

# Git aliases
alias g 'git'
alias ga 'git add'
alias gaa 'git add --all'
alias gc 'git commit'
alias gcm 'git commit -m'
alias gco 'git checkout'
alias gs 'git status'
alias gl 'git log'
alias glo 'git log --oneline'
alias gp 'git push'
alias gpl 'git pull'
alias gb 'git branch'
alias gd 'git diff'
alias gdc 'git diff --cached'
alias gr 'git reset'
alias grh 'git reset --hard'
alias gf 'git fetch'
alias gm 'git merge'
alias grs 'git restore'
alias gst 'git stash'
alias gstp 'git stash pop'
alias gstl 'git stash list'
alias gwt 'git worktree'
