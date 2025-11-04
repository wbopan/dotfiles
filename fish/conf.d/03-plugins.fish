# Plugin initialization
if has zoxide
    zoxide init fish --cmd cd | source
end

if has direnv
    direnv hook fish | source
end

if has uv
    uv generate-shell-completion fish | source
end

if has uvx
    uvx --generate-shell-completion fish | source
end

# Additional plugin initializations
if has eza
    alias ls eza
    alias tree 'eza --tree'
end

if has fzf
    # Prefer builtin initializer; fall back to legacy script if unavailable.
    set -l __fzf_tmp (mktemp 2>/dev/null)
    if test -n "$__fzf_tmp"
        if fzf --fish > "$__fzf_tmp" 2>/dev/null
            source "$__fzf_tmp"
        else if test -f ~/.fzf.fish
            source ~/.fzf.fish
        end
        rm -f "$__fzf_tmp"
    else if test -f ~/.fzf.fish
        source ~/.fzf.fish
    end
else if test -f ~/.fzf.fish
    source ~/.fzf.fish
end

if has vim
    set -x EDITOR vim
end

if has nvim
    set -x EDITOR nvim
end

if has batcat
    alias bat batcat
end

if has codex
    codex completion fish | source
end

# has starship; and starship init fish | source
