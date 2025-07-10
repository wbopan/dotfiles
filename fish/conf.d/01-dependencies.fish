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

function _fish_deps_has_cargo
    command -v cargo >/dev/null 2>&1
end

# Homebrew installation helper for Linux
function _fish_deps_install_brew_linux
    echo "Installing Homebrew for Linux..."
    
    # Check if we already have brew
    if _fish_deps_has_brew
        echo "Homebrew is already installed."
        return 0
    end
    
    # Detect Linux distribution and install prerequisites
    if command -v apt-get >/dev/null 2>&1
        # Debian/Ubuntu
        echo "Installing prerequisites for Debian/Ubuntu..."
        sudo apt-get update
        sudo apt-get install -y build-essential procps curl file git
    else if command -v dnf >/dev/null 2>&1
        # Fedora/RHEL/CentOS
        echo "Installing prerequisites for Fedora/RHEL/CentOS..."
        sudo dnf group install -y 'Development Tools'
        sudo dnf install -y procps-ng curl file git
    else if command -v pacman >/dev/null 2>&1
        # Arch Linux
        echo "Installing prerequisites for Arch Linux..."
        sudo pacman -S --noconfirm base-devel procps-ng curl file git
    else if command -v zypper >/dev/null 2>&1
        # openSUSE
        echo "Installing prerequisites for openSUSE..."
        sudo zypper install -y -t pattern devel_basis
        sudo zypper install -y curl file git
    else
        echo "Warning: Could not detect package manager. Please install build tools, curl, file, and git manually."
    end
    
    # Install Homebrew
    echo "Running Homebrew installation script..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if test -d ~/.linuxbrew
        eval "$(~/.linuxbrew/bin/brew shellenv)"
    else if test -d /home/linuxbrew/.linuxbrew
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    end
    
    # Add Homebrew to fish config if not already there
    set -l brew_init_file "$HOME/.config/fish/conf.d/homebrew.fish"
    if not test -f "$brew_init_file"
        echo "Adding Homebrew to fish configuration..."
        echo '# Homebrew initialization' > "$brew_init_file"
        echo 'if test -d ~/.linuxbrew' >> "$brew_init_file"
        echo '    eval "$(~/.linuxbrew/bin/brew shellenv)"' >> "$brew_init_file"
        echo 'else if test -d /home/linuxbrew/.linuxbrew' >> "$brew_init_file"
        echo '    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$brew_init_file"
        echo 'end' >> "$brew_init_file"
    end
    
    # Verify installation
    if _fish_deps_has_brew
        echo "Homebrew installed successfully!"
        brew --version
        return 0
    else
        echo "Error: Homebrew installation failed. Please check the output above."
        return 1
    end
end

# Package check functions
function _fish_deps_check_package
    set -l package $argv[1]
    
    switch $package
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install zoxide
        else
            echo "Error: Failed to install Homebrew."
            return 1
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install direnv
        else
            echo "Error: Failed to install Homebrew."
            return 1
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install fzf
        else
            echo "Error: Failed to install Homebrew."
            return 1
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install bat
        else
            echo "Error: Failed to install Homebrew."
            return 1
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install eza
        else
            echo "Error: Failed to install Homebrew."
            return 1
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install fd
        else
            echo "Error: Failed to install Homebrew."
            return 1
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install tmux
        else
            echo "Error: Failed to install Homebrew."
            return 1
        end
    end
end

function _fish_deps_install_uv
    # uv uses its own installer on all platforms
    curl -LsSf https://astral.sh/uv/install.sh | sh
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install ripgrep
        else
            echo "Error: Failed to install Homebrew."
            return 1
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            brew install neovim
        else
            echo "Error: Failed to install Homebrew."
            return 1
        end
    end
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
        if not _fish_deps_has_brew
            echo "Homebrew not found. Installing Homebrew first..."
            _fish_deps_install_brew_linux
        end
        if _fish_deps_has_brew
            # Check if 1password-cli is available in brew for Linux
            if brew search 1password-cli >/dev/null 2>&1
                brew install 1password-cli
            else
                # Fall back to manual installation for Linux
                echo "1Password CLI not available in Homebrew for Linux. Installing manually..."
                # Detect architecture
                set -l arch (uname -m)
                switch $arch
                    case x86_64
                        set arch amd64
                    case aarch64
                        set arch arm64
                    case armv7l
                        set arch arm
                    case i686
                        set arch 386
                end
                
                # Get latest version
                set -l version "v2.31.1"
                
                # Download and install
                set -l tmp_dir (mktemp -d)
                set -l download_url "https://cache.agilebits.com/dist/1P/op2/pkg/$version/op_linux_"$arch"_"$version".zip"
                
                echo "Downloading 1Password CLI from $download_url..."
                if curl -sSfL "$download_url" -o "$tmp_dir/op.zip"
                    unzip -q "$tmp_dir/op.zip" -d "$tmp_dir"
                    sudo mv "$tmp_dir/op" /usr/local/bin/
                    sudo chmod +x /usr/local/bin/op
                    rm -rf "$tmp_dir"
                    echo "1Password CLI installed successfully."
                else
                    echo "Error: Failed to download 1Password CLI."
                    rm -rf "$tmp_dir"
                    return 1
                end
            end
        else
            echo "Error: Failed to install Homebrew."
            return 1
        end
    end
end

# Package uninstall functions
function _fish_deps_uninstall_zoxide
    if _fish_deps_has_brew
        brew uninstall zoxide
    end
end

function _fish_deps_uninstall_direnv
    if _fish_deps_has_brew
        brew uninstall direnv
    end
end

function _fish_deps_uninstall_fzf
    if _fish_deps_has_brew
        brew uninstall fzf
    end
end

function _fish_deps_uninstall_bat
    if _fish_deps_has_brew
        brew uninstall bat
    end
end

function _fish_deps_uninstall_eza
    if _fish_deps_has_brew
        brew uninstall eza
    end
end

function _fish_deps_uninstall_fd
    if _fish_deps_has_brew
        brew uninstall fd
    end
end

function _fish_deps_uninstall_tmux
    if _fish_deps_has_brew
        brew uninstall tmux
    end
end

function _fish_deps_uninstall_uv
    # Remove uv from common installation locations
    rm -f ~/.cargo/bin/uv
    rm -f /usr/local/bin/uv
    rm -f ~/.local/bin/uv
end

function _fish_deps_uninstall_rg
    if _fish_deps_has_brew
        brew uninstall ripgrep
    end
end

function _fish_deps_uninstall_nvim
    if _fish_deps_has_brew
        brew uninstall neovim
    end
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
        if _fish_deps_has_brew
            # Try to uninstall via brew first
            brew uninstall 1password-cli 2>/dev/null
        end
        # Also remove manual installation
        sudo rm -f /usr/local/bin/op
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
                echo "Available packages: zoxide direnv fzf bat eza fd tmux uv rg nvim tpm op"
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
            
            set -l packages zoxide direnv fzf bat eza fd tmux uv rg nvim tpm op
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
            echo "Available packages: zoxide direnv fzf bat eza fd tmux uv rg nvim tpm op"
            return 1
    end
end