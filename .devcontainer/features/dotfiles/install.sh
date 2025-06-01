#!/bin/bash

set -e

# Import the specified key-value pairs from the devcontainer-feature.json
REPOSITORY=${REPOSITORY:-"https://github.com/BMPixel/dotfiles.git"}
TARGET_PATH=${TARGETPATH:-"/home/vscode/.dotfiles"}
INSTALL_DEPENDENCIES=${INSTALLDEPENDENCIES:-"true"}

echo "Starting dotfiles installation..."
echo "Repository: $REPOSITORY"
echo "Target path: $TARGET_PATH"
echo "Install dependencies: $INSTALL_DEPENDENCIES"

# Ensure we're running as the vscode user for proper permissions
if [ "$(id -u)" = "0" ]; then
    # We're running as root, switch to vscode user
    USER_HOME="/home/vscode"
    SUDO_USER="vscode"
else
    # We're already running as a regular user
    USER_HOME="$HOME"
    SUDO_USER="$(whoami)"
fi

# Install git if not present
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt-get update
    apt-get install -y git
fi

# Install fish shell if not present
if ! command -v fish &> /dev/null; then
    echo "Installing fish shell..."
    apt-get update
    apt-get install -y fish
fi

# Function to run commands as the target user
run_as_user() {
    if [ "$(id -u)" = "0" ]; then
        sudo -u "$SUDO_USER" "$@"
    else
        "$@"
    fi
}

# Clone dotfiles repository
echo "Cloning dotfiles repository..."
if [ -d "$TARGET_PATH" ]; then
    echo "Target path already exists. Pulling latest changes..."
    run_as_user git -C "$TARGET_PATH" pull
else
    run_as_user git clone "$REPOSITORY" "$TARGET_PATH"
fi

# Make install script executable
chmod +x "$TARGET_PATH/install.sh"

# Run the dotfiles installer in non-interactive mode with only fish
echo "Running dotfiles installer..."
cd "$TARGET_PATH"
run_as_user bash install.sh --yes --fish

# Install additional dependencies if requested
if [ "$INSTALL_DEPENDENCIES" = "true" ]; then
    echo "Installing additional dependencies..."
    
    # Install tmux if not present
    if ! command -v tmux &> /dev/null; then
        echo "Installing tmux..."
        apt-get update
        apt-get install -y tmux
    fi
    
    # Install neovim if not present
    if ! command -v nvim &> /dev/null; then
        echo "Installing neovim..."
        apt-get update
        apt-get install -y neovim
    fi
    
    # Install curl and other common tools
    apt-get update
    apt-get install -y curl wget unzip
fi

# Set fish as the default shell for the vscode user
if command -v fish &> /dev/null; then
    echo "Setting fish as default shell for $SUDO_USER..."
    # Add fish to /etc/shells if not already there
    if ! grep -q "$(which fish)" /etc/shells; then
        echo "$(which fish)" >> /etc/shells
    fi
    # Change default shell
    chsh -s "$(which fish)" "$SUDO_USER"
fi

echo "Dotfiles installation completed successfully!"