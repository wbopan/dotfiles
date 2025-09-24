# Plugin initialization
has zoxide; and zoxide init fish --cmd cd | source
has direnv; and eval (direnv hook fish)
has uv; and eval (uv generate-shell-completion fish)

# Additional plugin initializations
has eza; and alias ls 'eza'; and alias tree 'eza --tree'
has fzf; and fzf --fish | source
test -f ~/.fzf.fish; and source ~/.fzf.fish
has direnv; and direnv hook fish | source
has uv; and uv generate-shell-completion fish | source
has uvx; and uvx --generate-shell-completion fish | source
has vim; and set -x EDITOR "vim"
has nvim; and set -x EDITOR "nvim"
has cursor; and set -x EDITOR "cursor"
has batcat; and alias bat "batcat"
# has starship; and starship init fish | source
