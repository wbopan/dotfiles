# Dependency status reporter with helper commands

function _fish_deps_check_package
    set -l package $argv[1]

    switch $package
        case tpm
            test -d "$HOME/.tmux/plugins/tpm"
        case '*'
            command -v $package >/dev/null 2>&1
    end
end

function _fish_deps_has_manager
    set -l manager $argv[1]

    switch $manager
        case brew
            if command -v brew >/dev/null 2>&1
                return 0
            end
        case cargo
            if command -v cargo >/dev/null 2>&1
                return 0
            end
        case npm
            if command -v npm >/dev/null 2>&1
                return 0
            end
        case apt
            if command -v apt >/dev/null 2>&1
                return 0
            else if command -v apt-get >/dev/null 2>&1
                return 0
            end
    end

    return 1
end

function _fish_deps_install_commands
    set -l package $argv[1]
    set -l commands

    switch $package
        case zoxide
            set commands \
                "brew|brew install zoxide" \
                "cargo|cargo install zoxide" \
                "apt|sudo apt install zoxide"
        case direnv
            set commands \
                "brew|brew install direnv" \
                "apt|sudo apt install direnv"
        case fzf
            set commands \
                "brew|brew install fzf" \
                "apt|sudo apt install fzf"
        case bat
            set commands \
                "brew|brew install bat" \
                "cargo|cargo install bat" \
                "apt|sudo apt install bat"
        case eza
            set commands \
                "brew|brew install eza" \
                "cargo|cargo install eza" \
                "apt|sudo apt install eza"
        case fd
            set commands \
                "brew|brew install fd" \
                "cargo|cargo install fd-find" \
                "apt|sudo apt install fd-find"
        case tmux
            set commands \
                "brew|brew install tmux" \
                "apt|sudo apt install tmux"
        case uv
            set commands \
                "brew|brew install uv" \
                "cargo|cargo install uv"
        case rg
            set commands \
                "brew|brew install ripgrep" \
                "cargo|cargo install ripgrep" \
                "apt|sudo apt install ripgrep"
        case nvim
            set commands \
                "brew|brew install neovim" \
                "npm|npm install -g neovim" \
                "apt|sudo apt install neovim"
        case op
            set commands \
                "brew|brew install --cask 1password-cli" \
                "apt|sudo apt install 1password-cli"
        case gh
            set commands \
                "brew|brew install gh" \
                "apt|sudo apt install gh"
    end

    for cmd in $commands
        echo $cmd
    end
end

function _fish_deps_manual_note
    set -l package $argv[1]

    switch $package
        case tpm
            echo "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
        case uv
            echo "curl -LsSf https://astral.sh/uv/install.sh | sh"
        case op
            echo "See https://developer.1password.com/docs/cli/get-started/#install for detailed Linux instructions"
    end
end

function fish_deps
    if test (count $argv) -gt 0
        echo "fish_deps does not accept subcommands. Ignoring arguments: $argv"
        echo ""
    end

    set -l packages zoxide direnv fzf bat eza fd tmux uv rg nvim tpm op gh
    set -l installed_count 0
    set -l total (count $packages)

    echo "🔍 Dependency status"
    echo "==================="

    for pkg in $packages
        if _fish_deps_check_package $pkg
            echo "✅ $pkg"
            set installed_count (math $installed_count + 1)
        else
            echo "❌ $pkg"
            set -l commands (_fish_deps_install_commands $pkg)
            if test (count $commands) -gt 0
                for entry in $commands
                    set -l parts (string split -m 1 '|' $entry)
                    set -l manager $parts[1]
                    set -l command $parts[2]
                    set -l note ""
                    if not _fish_deps_has_manager $manager
                        set note " (requires $manager)"
                    end
                    printf '    - %s: %s%s\n' $manager $command $note
                end
            end

            set -l manual (_fish_deps_manual_note $pkg)
            if test -n "$manual"
                printf '    - manual: %s\n' "$manual"
            end

            echo ""
        end
    end

    echo "==================="
    printf '📊 Installed %s/%s dependencies\n' $installed_count $total
    if test $installed_count -eq $total
        echo "🎉 All dependencies are available."
    else
        echo "💡 Copy the commands above to install missing tools."
    end
end
