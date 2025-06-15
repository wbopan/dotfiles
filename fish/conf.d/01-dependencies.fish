# Platform detection helpers
function _fish_deps_is_macos
    test (uname) = Darwin
end

function _fish_deps_is_linux
    test (uname) = Linux
end

function _fish_deps_has_brew
    command -v brew >/dev/null 2>&1
end

function _fish_deps_has_apt
    command -v apt >/dev/null 2>&1
end

function _fish_deps_has_dnf
    command -v dnf >/dev/null 2>&1
end

function _fish_deps_has_pacman
    command -v pacman >/dev/null 2>&1
end

function _fish_deps_has_cargo
    command -v cargo >/dev/null 2>&1
end

# Package manager helper functions
function _fish_deps_install_via_system_pkg
    set -l package $argv[1]
    set -l apt_name $argv[2]
    set -l dnf_name $argv[3] 
    set -l pacman_name $argv[4]
    
    # Use provided names or default to package name
    if test -z "$apt_name"
        set apt_name $package
    end
    if test -z "$dnf_name"
        set dnf_name $package
    end
    if test -z "$pacman_name"
        set pacman_name $package
    end
    
    if _fish_deps_has_apt
        sudo apt update && sudo apt install -y $apt_name
    else if _fish_deps_has_dnf
        sudo dnf install -y $dnf_name
    else if _fish_deps_has_pacman
        sudo pacman -S --noconfirm $pacman_name
    else
        return 1
    end
end

function _fish_deps_uninstall_via_system_pkg
    set -l package $argv[1]
    set -l apt_name $argv[2]
    set -l dnf_name $argv[3]
    set -l pacman_name $argv[4]
    
    # Use provided names or default to package name
    if test -z "$apt_name"
        set apt_name $package
    end
    if test -z "$dnf_name"
        set dnf_name $package
    end
    if test -z "$pacman_name"
        set pacman_name $package
    end
    
    if _fish_deps_has_apt
        sudo apt remove -y $apt_name
    else if _fish_deps_has_dnf
        sudo dnf remove -y $dnf_name
    else if _fish_deps_has_pacman
        sudo pacman -R --noconfirm $pacman_name
    else
        return 1
    end
end

# Package check functions
function _fish_deps_check_package
    set -l package $argv[1]
    
    switch $package
        case lazyvim
            test -d "$HOME/.config/nvim" -a -f "$HOME/.config/nvim/lua/config/lazy.lua"
        case tpm
            test -d "$HOME/.tmux/plugins/tpm"
        case '*'
            command -v $package >/dev/null 2>&1
    end
end

# Package installation functions
function _fish_deps_install_zoxide
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install zoxide
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg zoxide
            if _fish_deps_has_cargo
                cargo install zoxide --locked
            else
                echo "Error: No supported package manager found for zoxide"
                return 1
            end
        end
    end
end

function _fish_deps_install_direnv
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install direnv
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg direnv
            curl -sfL https://direnv.net/install.sh | bash
        end
    end
end

function _fish_deps_install_fzf
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install fzf
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg fzf
            git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
            ~/.fzf/install --all
        end
    end
end

function _fish_deps_install_bat
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install bat
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg bat
            if _fish_deps_has_cargo
                cargo install bat
            else
                echo "Error: No supported package manager found for bat"
                return 1
            end
        end
    end
end

function _fish_deps_install_eza
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install eza
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg eza
            if _fish_deps_has_cargo
                cargo install eza
            else
                echo "Error: No supported package manager found for eza"
                return 1
            end
        end
    end
end

function _fish_deps_install_fd
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install fd
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg fd fd-find fd-find fd
            if _fish_deps_has_cargo
                cargo install fd-find
            else
                echo "Error: No supported package manager found for fd"
                return 1
            end
        end
    end
end

function _fish_deps_install_tmux
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install tmux
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg tmux
            echo "Error: No supported package manager found for tmux"
            return 1
        end
    end
end

function _fish_deps_install_uv
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install uv
        else
            curl -LsSf https://astral.sh/uv/install.sh | sh
        end
    else if _fish_deps_is_linux
        if _fish_deps_has_apt
            # uv not typically in apt, use pip or curl
            curl -LsSf https://astral.sh/uv/install.sh | sh
        else if _fish_deps_has_dnf
            # uv not typically in dnf, use curl
            curl -LsSf https://astral.sh/uv/install.sh | sh
        else if _fish_deps_has_pacman
            # uv not typically in pacman, use curl
            curl -LsSf https://astral.sh/uv/install.sh | sh
        else
            curl -LsSf https://astral.sh/uv/install.sh | sh
        end
    end
end

function _fish_deps_install_rg
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install ripgrep
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg rg ripgrep ripgrep ripgrep
            if _fish_deps_has_cargo
                cargo install ripgrep
            else
                echo "Error: No supported package manager found for ripgrep"
                return 1
            end
        end
    end
end

function _fish_deps_install_nvim
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install neovim
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if not _fish_deps_install_via_system_pkg nvim neovim neovim neovim
            # Download latest stable release
            curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
            chmod u+x nvim.appimage
            sudo mv nvim.appimage /usr/local/bin/nvim
        end
    end
end

function _fish_deps_install_lazyvim
    if _fish_deps_check_package lazyvim
        echo "LazyVim is already installed."
        return 0
    end

    if not _fish_deps_check_package nvim
        echo "Error: Neovim is required for LazyVim. Install nvim first."
        return 1
    end

    echo "Installing LazyVim..."
    
    # Remove existing configs
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/nvim

    # Clone LazyVim starter
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    
    echo "LazyVim installed successfully."
end

function _fish_deps_install_tpm
    if _fish_deps_check_package tpm
        echo "TPM is already installed."
        return 0
    end

    if not _fish_deps_check_package tmux
        echo "Error: tmux is required for TPM. Install tmux first."
        return 1
    end

    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed successfully."
    echo "Run prefix + I (capital i) inside tmux to install plugins."
end

function _fish_deps_install_op
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew install --cask 1password-cli
        else
            echo "Error: Homebrew not found. Please install Homebrew first."
            return 1
        end
    else if _fish_deps_is_linux
        if _fish_deps_has_apt
            # Set up 1Password official repository for Debian/Ubuntu
            echo "Setting up 1Password repository..."
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" | sudo tee /etc/apt/sources.list.d/1password.list
            sudo apt update && sudo apt install -y 1password-cli
        else if _fish_deps_has_dnf
            # Set up 1Password official repository for Fedora
            echo "Setting up 1Password repository..."
            sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
            sudo sh -c 'echo -e "[1password]\nname=1Password\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
            sudo dnf install -y 1password-cli
        else if _fish_deps_has_pacman
            # For Arch Linux, try AUR or manual installation
            echo "Error: 1Password CLI not available in official Arch repositories."
            echo "Please install manually from AUR or download from https://1password.com/downloads/command-line"
            return 1
        else
            echo "Error: No supported package manager found for 1Password CLI"
            echo "Please install manually from https://1password.com/downloads/command-line"
            return 1
        end
    else
        echo "Error: Unsupported platform for 1Password CLI installation"
        return 1
    end
end

# Package uninstall functions
function _fish_deps_uninstall_zoxide
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall zoxide
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg zoxide
            if _fish_deps_has_cargo
                cargo uninstall zoxide
            end
        end
    end
end

function _fish_deps_uninstall_direnv
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall direnv
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg direnv
            rm -f /usr/local/bin/direnv
        end
    end
end

function _fish_deps_uninstall_fzf
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall fzf
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg fzf
            rm -rf ~/.fzf
        end
    end
end

function _fish_deps_uninstall_bat
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall bat
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg bat
            if _fish_deps_has_cargo
                cargo uninstall bat
            end
        end
    end
end

function _fish_deps_uninstall_eza
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall eza
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg eza
            if _fish_deps_has_cargo
                cargo uninstall eza
            end
        end
    end
end

function _fish_deps_uninstall_fd
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall fd
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg fd fd-find fd-find fd
            if _fish_deps_has_cargo
                cargo uninstall fd-find
            end
        end
    end
end

function _fish_deps_uninstall_tmux
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall tmux
        end
    else if _fish_deps_is_linux
        _fish_deps_uninstall_via_system_pkg tmux
    end
end

function _fish_deps_uninstall_uv
    rm -f ~/.cargo/bin/uv
    rm -f /usr/local/bin/uv
end

function _fish_deps_uninstall_rg
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall ripgrep
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg rg ripgrep ripgrep ripgrep
            if _fish_deps_has_cargo
                cargo uninstall ripgrep
            end
        end
    end
end

function _fish_deps_uninstall_nvim
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall neovim
        end
    else if _fish_deps_is_linux
        if not _fish_deps_uninstall_via_system_pkg nvim neovim neovim neovim
            sudo rm -f /usr/local/bin/nvim
        end
    end
end

function _fish_deps_uninstall_lazyvim
    echo "Removing LazyVim configuration..."
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim
    rm -rf ~/.cache/nvim
    echo "LazyVim uninstalled."
end

function _fish_deps_uninstall_tpm
    echo "Removing TPM..."
    rm -rf ~/.tmux/plugins/tpm
    echo "TPM uninstalled."
end

function _fish_deps_uninstall_op
    if _fish_deps_is_macos
        if _fish_deps_has_brew
            brew uninstall --cask 1password-cli
        end
    else if _fish_deps_is_linux
        if _fish_deps_has_apt
            sudo apt remove -y 1password-cli
            # Optionally remove the repository (commented out to preserve for future installs)
            # sudo rm -f /etc/apt/sources.list.d/1password.list
            # sudo rm -f /usr/share/keyrings/1password-archive-keyring.gpg
        else if _fish_deps_has_dnf
            sudo dnf remove -y 1password-cli
            # Optionally remove the repository (commented out to preserve for future installs)
            # sudo rm -f /etc/yum.repos.d/1password.repo
        else if _fish_deps_has_pacman
            # For manual installations, remove binary
            sudo rm -f /usr/local/bin/op
        else
            # Fallback: remove common manual installation locations
            sudo rm -f /usr/local/bin/op
            sudo rm -f /usr/bin/op
        end
    end
end

# Main fish_deps function
function fish_deps
    set -l command $argv[1]
    set -l package $argv[2]
    
    switch $command
        case check
            if test -z "$package"
                echo "Usage: fish_deps check <package>"
                return 1
            end
            _fish_deps_check_package $package
            
        case install
            if test -z "$package"
                echo "Usage: fish_deps install <package>"
                echo "Available packages: zoxide direnv fzf bat eza fd tmux uv rg nvim lazyvim tpm op"
                return 1
            end
            
            if _fish_deps_check_package $package
                echo "$package is already installed."
                return 0
            end
            
            echo "Installing $package..."
            _fish_deps_install_$package
            
        case uninstall
            if test -z "$package"
                echo "Usage: fish_deps uninstall <package>"
                return 1
            end
            
            if not _fish_deps_check_package $package
                echo "$package is not installed."
                return 0
            end
            
            echo "Uninstalling $package..."
            _fish_deps_uninstall_$package
            
        case health
            echo "🔍 Dependency Health Check"
            echo "========================"
            
            set -l packages zoxide direnv fzf bat eza fd tmux uv rg nvim lazyvim tpm op
            set -l installed 0
            set -l total (count $packages)
            
            for pkg in $packages
                if _fish_deps_check_package $pkg
                    echo "  ✅ $pkg"
                    set installed (math $installed + 1)
                else
                    echo "  ❌ $pkg"
                end
            end
            
            echo "========================"
            echo "📊 Status: $installed/$total packages installed"
            
            if test $installed -eq $total
                echo "🎉 All dependencies are installed!"
            else
                echo "💡 Run 'fish_deps install <package>' to install missing packages"
            end
            
        case '*'
            echo "Usage: fish_deps <command> [package]"
            echo "Commands:"
            echo "  check <package>     Check if package is installed"
            echo "  install <package>   Install package"
            echo "  uninstall <package> Uninstall package"
            echo "  health              Show dependency health status"
            echo ""
            echo "Available packages: zoxide direnv fzf bat eza fd tmux uv rg nvim lazyvim tpm op"
            return 1
    end
end

