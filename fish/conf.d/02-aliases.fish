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
has docker-compose; and alias dc "docker-compose"
has claude; and alias cc "claude"
