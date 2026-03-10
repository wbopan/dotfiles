function health --description 'Check if recommended tools are installed'
    set -l deps \
        "brew|brew|/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"" \
        "zoxide|zoxide|brew install zoxide" \
        "direnv|direnv|brew install direnv" \
        "fzf|fzf|brew install fzf" \
        "bat|bat|brew install bat" \
        "eza|eza|brew install eza" \
        "fd|fd|brew install fd" \
        "tmux|tmux|brew install tmux" \
        "uv|uv|brew install uv" \
        "rg|rg|brew install ripgrep" \
        "nvim|nvim|brew install neovim" \
        "starship|starship|brew install starship" \
        "tpm|dir:$HOME/.tmux/plugins/tpm|git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" \
        "op|op|brew install --cask 1password-cli" \
        "gh|gh|brew install gh"

    for dep in $deps
        set -l parts (string split '|' -- $dep)
        set -l name $parts[1]
        set -l check $parts[2]
        set -l install_cmd $parts[3]

        set -l ok 0
        if string match -q 'dir:*' -- $check
            set -l dir (string replace 'dir:' '' -- $check)
            test -d $dir; and set ok 1
        else
            command -q $check; and set ok 1
        end

        if test $ok -eq 1
            printf "  [x] %s\n" $name
        else
            printf "  [ ] %s  ->  %s\n" $name $install_cmd
        end
    end
end
